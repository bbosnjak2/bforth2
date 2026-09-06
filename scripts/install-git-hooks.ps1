param(
    [string]$HookPath = '.githooks'
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot

try {
    $inside = (& git rev-parse --is-inside-work-tree 2>$null)
    if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne 'true') {
        throw 'This script must be run from within a Git repository.'
    }

    if (-not (Test-Path -LiteralPath $HookPath)) {
        throw "Hook path not found: $HookPath"
    }

    & git config core.hooksPath $HookPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to configure core.hooksPath.'
    }

    $effective = (& git config --get core.hooksPath).Trim()
    Write-Host ("Configured git hooks path: {0}" -f $effective)
    Write-Host 'Pre-commit hook is now active for this repository.'
}
finally {
    Pop-Location
}
