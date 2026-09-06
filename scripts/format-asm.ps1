param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$ConfigPath = '',
    [string]$FilePath = '',
    [switch]$Write,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $Root 'asm-format.json'
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json

function Get-RelPath([string]$basePath, [string]$fullPath) {
    $base = [System.IO.Path]::GetFullPath($basePath)
    $full = [System.IO.Path]::GetFullPath($fullPath)
    return [System.IO.Path]::GetRelativePath($base, $full).Replace('\', '/')
}

function Match-AnyPattern([string]$path, [object[]]$patterns) {
    foreach ($pattern in $patterns) {
        $glob = $pattern.Replace('\', '/')
        $target = $path

        # A slash-free pattern (e.g., *.asm) is treated as a basename glob
        # and therefore matches files in all subdirectories.
        if (-not $glob.Contains('/')) {
            $target = [System.IO.Path]::GetFileName($path)
        }

        $regexBuilder = New-Object System.Text.StringBuilder
        [void]$regexBuilder.Append('^')

        $i = 0
        while ($i -lt $glob.Length) {
            $ch = $glob[$i]

            if ($ch -eq '*') {
                if (($i + 1) -lt $glob.Length -and $glob[$i + 1] -eq '*') {
                    [void]$regexBuilder.Append('.*')
                    $i += 2
                    continue
                }

                [void]$regexBuilder.Append('[^/]*')
                $i += 1
                continue
            }

            if ($ch -eq '?') {
                [void]$regexBuilder.Append('[^/]')
                $i += 1
                continue
            }

            [void]$regexBuilder.Append([Regex]::Escape([string]$ch))
            $i += 1
        }

        [void]$regexBuilder.Append('$')
        $regex = $regexBuilder.ToString()
        if ($target -match $regex) {
            return $true
        }
    }
    return $false
}

function Should-FormatFile([string]$rootPath, [string]$fullPath, [object]$cfg) {
    $rel = Get-RelPath $rootPath $fullPath

    if (-not (Match-AnyPattern $rel $cfg.include)) {
        return $false
    }

    if (Match-AnyPattern $rel $cfg.exclude) {
        return $false
    }

    return $true
}

function Split-CodeAndComment([string]$line) {
    $idx = $line.IndexOf(';')
    if ($idx -lt 0) {
        return @($line, '')
    }

    $code = $line.Substring(0, $idx)
    $comment = $line.Substring($idx + 1)
    return @($code, $comment)
}

function Normalize-WordCasing([string]$text, [object[]]$words) {
    $result = $text
    foreach ($w in $words) {
        $result = [Regex]::Replace($result, "(?i)\b$([Regex]::Escape($w))\b", $w.ToUpperInvariant())
    }
    return $result
}

function Normalize-Opcode([string]$opcode, [object]$cfg) {
    if ([string]::IsNullOrWhiteSpace($opcode)) {
        return ''
    }

    if ($opcode.StartsWith('.')) {
        return $opcode
    }

    foreach ($p in $cfg.lowercasePseudoOps) {
        if ($opcode.Equals($p, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $p
        }
    }

    if ($cfg.uppercaseOpcodes) {
        return $opcode.ToUpperInvariant()
    }

    return $opcode
}

function Format-AsmLine([string]$line, [object]$cfg) {
    $trimmedRight = $line.TrimEnd()
    if ([string]::IsNullOrWhiteSpace($trimmedRight)) {
        return ''
    }

    $trimmed = $trimmedRight.TrimStart()
    if ($trimmed.StartsWith(';')) {
        $indent = ' ' * [int]$cfg.fullLineCommentIndent
        return $indent + $trimmed
    }

    $parts = Split-CodeAndComment $trimmedRight
    $code = $parts[0].TrimEnd()
    $comment = $parts[1].Trim()

    if ([string]::IsNullOrWhiteSpace($code)) {
        $indent = ' ' * [int]$cfg.fullLineCommentIndent
        return $indent + '; ' + $comment
    }

    $label = ''
    $opcode = ''
    $operands = ''
    $formatted = ''

    $leadingWhitespace = [Regex]::Match($code, '^\s*').Value
    $codeNoLead = $code.Substring($leadingWhitespace.Length)

    # Keep assignment-style constants as label definitions at column 0,
    # e.g. NAME = 80, which zasm expects as non-indented labels.
    $assignment = [Regex]::Match($codeNoLead, '^(?<name>[A-Za-z_.$?@][A-Za-z0-9_.$?@]*)\s*=\s*(?<expr>.+)$')
    if ($assignment.Success) {
        $name = $assignment.Groups['name'].Value
        $expr = $assignment.Groups['expr'].Value.Trim()
        $formatted = "$name = $expr"

        if (-not [string]::IsNullOrWhiteSpace($comment)) {
            if ($formatted.Length -lt [int]$cfg.commentColumn) {
                $formatted += (' ' * ([int]$cfg.commentColumn - $formatted.Length))
            }
            else {
                $formatted += ' '
            }
            $formatted += '; ' + $comment
        }

        return $formatted.TrimEnd()
    }

    $tokens = @($codeNoLead -split '\s+', 3)

    # Recover from previously misformatted lines where label and pseudo-op were
    # glued together (e.g. LABELDEFM "text", 0).
    $splitGluedLabelOpcode = $false
    if ($leadingWhitespace.Length -eq 0 -and $tokens.Count -ge 2 -and $tokens[0] -match '^[A-Za-z_.$?@][A-Za-z0-9_.$?@]*$') {
        $knownGluedOps = @('defm') + @($cfg.lowercasePseudoOps)
        foreach ($candidateOp in ($knownGluedOps | Sort-Object { $_.Length } -Descending -Unique)) {
            if ($tokens[0].Length -le $candidateOp.Length) {
                continue
            }

            if (-not $tokens[0].EndsWith($candidateOp, [System.StringComparison]::OrdinalIgnoreCase)) {
                continue
            }

            $candidateLabel = $tokens[0].Substring(0, $tokens[0].Length - $candidateOp.Length)
            if ($candidateLabel -notmatch '^[A-Za-z_.$?@][A-Za-z0-9_.$?@]*:?$') {
                continue
            }

            $label = $candidateLabel
            $opcode = $candidateOp
            $operands = $tokens[1]
            if ($tokens.Count -ge 3) {
                $operands = "$operands $($tokens[2])"
            }

            $splitGluedLabelOpcode = $true
            break
        }
    }

    if ($splitGluedLabelOpcode) {
        # Parsed by recovery heuristic above.
    }
    elseif ($tokens.Count -eq 1) {
        $single = $tokens[0]
        if ($leadingWhitespace.Length -eq 0 -and -not $single.StartsWith('.') -and $single -match '^[A-Za-z_.$?@][A-Za-z0-9_.$?@]*:?$') {
            $label = $single
        }
        else {
            $opcode = $single
        }
    }
    elseif ($leadingWhitespace.Length -eq 0 -and -not $tokens[0].StartsWith('.') -and $tokens[0] -match '^[A-Za-z_.$?@][A-Za-z0-9_.$?@]*:?$') {
        $label = $tokens[0]
        $opcode = $tokens[1]
        if ($tokens.Count -ge 3) {
            $operands = $tokens[2]
        }
    }
    else {
        $opcode = $tokens[0]
        if ($tokens.Count -ge 2) {
            $operands = $tokens[1]
        }
        if ($tokens.Count -ge 3) {
            $operands = "$operands $($tokens[2])"
        }
    }

    # Support directive tokens that are glued to a quoted operand,
    # e.g. .include"constants/ascii.asm".
    if ([string]::IsNullOrWhiteSpace($operands) -and $opcode -match '^(?<op>\.[A-Za-z_.$?@][A-Za-z0-9_.$?@]*)(?<rest>["''].*)$') {
        $opcode = $Matches.op
        $operands = $Matches.rest
    }

    $opcode = Normalize-Opcode $opcode $cfg
    $operands = Normalize-WordCasing $operands $cfg.uppercaseRegisters
    $operands = Normalize-WordCasing $operands $cfg.uppercaseKeywords

    if (-not [string]::IsNullOrWhiteSpace($label)) {
        if ([string]::IsNullOrWhiteSpace($opcode)) {
            $formatted = $label
        }
        else {
            # Ensure at least one separator space when a label is wider than the label column.
            $labelField = if ($label.Length -ge [int]$cfg.labelColumnWidth) {
                $label + ' '
            }
            else {
                $label.PadRight([int]$cfg.labelColumnWidth)
            }
            $formatted = $labelField + $opcode.PadRight([int]$cfg.opcodeColumnWidth)
        }
    }
    else {
        $indent = ' ' * [int]$cfg.indentWidth
        if (-not [string]::IsNullOrWhiteSpace($opcode)) {
            $formatted = $indent + $opcode.PadRight([int]$cfg.opcodeColumnWidth)
        }
        else {
            $formatted = $indent
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($operands)) {
        if ($formatted.Length -gt 0 -and $formatted[-1] -notmatch '\s') {
            $formatted += ' '
        }
        $formatted += $operands
    }

    if (-not [string]::IsNullOrWhiteSpace($comment)) {
        if ($formatted.Length -lt [int]$cfg.commentColumn) {
            $formatted += (' ' * ([int]$cfg.commentColumn - $formatted.Length))
        }
        else {
            $formatted += ' '
        }
        $formatted += '; ' + $comment
    }

    return $formatted.TrimEnd()
}

function Align-ConsecutiveLabelledPseudos([string[]]$lines) {
    $result = New-Object System.Collections.Generic.List[string]
    foreach ($line in $lines) {
        $result.Add($line)
    }

    $entries = New-Object System.Collections.Generic.List[object]
    for ($i = 0; $i -lt $result.Count; $i += 1) {
        $current = $result[$i]
        if ([string]::IsNullOrWhiteSpace($current)) {
            continue
        }

        $match = [Regex]::Match(
            $current,
            '^(?<indent>\s*)(?:(?<label>[A-Za-z_.$?@][A-Za-z0-9_.$?@]*:?)\s+)?(?<opcode>(?:DEFS|DEF[A-Z0-9]+|(?:\.)?equ))\b(?<rest>.*)$',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
        if (-not $match.Success) {
            continue
        }

        $prefix = $match.Groups['indent'].Value
        if ($match.Groups['label'].Success) {
            $prefix += $match.Groups['label'].Value
        }

        $entries.Add([PSCustomObject]@{
            Index  = $i
            Prefix = $prefix
            Opcode = $match.Groups['opcode'].Value
            Rest   = $match.Groups['rest'].Value
        })
    }

    if ($entries.Count -ge 2) {
        $targetOpcodeColumn = 0
        foreach ($entry in $entries) {
            $candidate = $entry.Prefix.Length + 1
            if ($candidate -gt $targetOpcodeColumn) {
                $targetOpcodeColumn = $candidate
            }
        }

        foreach ($entry in $entries) {
            $spaces = ' ' * [Math]::Max(1, $targetOpcodeColumn - $entry.Prefix.Length)
            $result[$entry.Index] = $entry.Prefix + $spaces + $entry.Opcode + $entry.Rest
        }
    }

    return $result.ToArray()
}

$targetFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

if (-not [string]::IsNullOrWhiteSpace($FilePath)) {
    $candidate = $FilePath
    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path $Root $candidate
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "File not found: $candidate"
    }

    $file = Get-Item -LiteralPath $candidate
    if ($file.PSIsContainer) {
        throw "FilePath must point to a file: $candidate"
    }

    if ($file.Extension -ieq '.asm' -and (Should-FormatFile $Root $file.FullName $config)) {
        $targetFiles.Add($file)
    }
}
else {
    $allAsmFiles = Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object { $_.Extension -ieq '.asm' }

    foreach ($file in $allAsmFiles) {
        if (-not (Should-FormatFile $Root $file.FullName $config)) {
            continue
        }

        $targetFiles.Add($file)
    }
}

if ($targetFiles.Count -eq 0) {
    if (-not [string]::IsNullOrWhiteSpace($FilePath)) {
        Write-Host 'No files matched formatter filters for the provided -FilePath.'
    }
    else {
        Write-Host 'No ASM files matched formatter include/exclude filters.'
    }
    exit 0
}

$changed = New-Object System.Collections.Generic.List[string]

foreach ($file in $targetFiles) {
    $original = Get-Content -LiteralPath $file.FullName
    $formattedLines = foreach ($line in $original) {
        Format-AsmLine $line $config
    }

    $formattedLines = Align-ConsecutiveLabelledPseudos $formattedLines

    # Normalize trailing blank lines and enforce one final blank line
    # containing exactly four spaces.
    $normalizedLines = New-Object System.Collections.Generic.List[string]
    foreach ($line in $formattedLines) {
        $normalizedLines.Add($line)
    }

    while ($normalizedLines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($normalizedLines[$normalizedLines.Count - 1])) {
        $normalizedLines.RemoveAt($normalizedLines.Count - 1)
    }

    if ($normalizedLines.Count -eq 0) {
        $normalizedLines.Add('')
    }

    # Append one trailing line with four spaces and do not append
    # an additional newline after that line.
    $normalizedLines.Add('    ')

    $newText = ($normalizedLines -join "`r`n")
    if ($newText.EndsWith("`r`n")) {
        $newText = $newText.TrimEnd("`r", "`n")
    }

    $oldText = [System.IO.File]::ReadAllText($file.FullName)

    if (-not $newText.Equals($oldText, [System.StringComparison]::Ordinal)) {
        $rel = Get-RelPath $Root $file.FullName
        $changed.Add($rel)

        if ($Write) {
            [System.IO.File]::WriteAllText($file.FullName, $newText)
        }
    }
}

if ($changed.Count -eq 0) {
    Write-Host 'ASM formatting is already up to date.'
    exit 0
}

Write-Host ("ASM files needing formatting: {0}" -f $changed.Count)
$changed | Sort-Object | ForEach-Object { Write-Host (" - {0}" -f $_) }

if ($Check) {
    exit 1
}

if (-not $Write) {
    Write-Host 'Run with -Write to apply changes.'
}
