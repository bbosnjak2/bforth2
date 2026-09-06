$ErrorActionPreference = 'Stop'

$exePath = Join-Path $PSScriptRoot 'RunCPM.exe'
if (-not (Test-Path $exePath)) {
    Write-Error "RunCPM.exe was not found at $exePath. Build RunCPM first and copy RunCPM.exe into this folder."
}

Set-Location $PSScriptRoot
& $exePath
