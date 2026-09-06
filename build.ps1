param(
    [string]$AssemblerExe = 'C:\Users\boris\Desktop\zasm\zasm.exe',
    [string]$Source = (Join-Path $PSScriptRoot 'bforth2.asm'),
    [string]$OutputBin = '',
    [string]$RuntimeDir = (Join-Path $PSScriptRoot 'RunCPMRuntime')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $AssemblerExe)) {
    throw "zasm was not found at $AssemblerExe"
}

if (-not (Test-Path $Source)) {
    throw "Source file was not found at $Source"
}

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($Source)
if ([string]::IsNullOrWhiteSpace($OutputBin)) {
    $OutputBin = Join-Path $PSScriptRoot ("{0}.bin" -f $baseName)
}

$ListFile = Join-Path $PSScriptRoot ("{0}.lst" -f $baseName)

New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

$assemblyOutput = & $AssemblerExe --casefold --z80 -u -w $Source -l $ListFile -o $OutputBin 2>&1
if ($LASTEXITCODE -ne 0) {
    $assemblyOutput
    exit $LASTEXITCODE
}

if (-not (Test-Path $OutputBin)) {
    throw "Expected binary output was not found at $OutputBin"
}

if (-not (Test-Path $ListFile)) {
    throw "Expected listing output was not found at $ListFile"
}

$breakpoints = foreach ($line in Get-Content -Path $ListFile) {
    if ($line -match '^\s*(?<label>\S+)\s*=\s*\$(?<addr>[0-9A-Fa-f]{1,4})\b') {
        $label = $Matches.label
        $addr = $Matches.addr
        if ($label -like '*breakpoint*') {
            '{0}=${1}' -f $label, $addr.ToUpperInvariant()
        }
    }
}

$breakpointFile = Join-Path $RuntimeDir 'breakpoints.txt'
Set-Content -Path $breakpointFile -Value $breakpoints -NoNewline:$false

$comPath = Join-Path $PSScriptRoot ("{0}.com" -f $baseName)
Copy-Item -Path $OutputBin -Destination $comPath -Force

$runtimeDrive = Join-Path $RuntimeDir 'A\0'
if (-not (Test-Path $runtimeDrive)) {
    New-Item -ItemType Directory -Force -Path $runtimeDrive | Out-Null
}

Copy-Item -Path $comPath -Destination (Join-Path $runtimeDrive ("{0}.com" -f $baseName)) -Force

Write-Host "Wrote $breakpointFile"
Write-Host ("Copied {0}.com to {1}" -f $baseName, $runtimeDrive)