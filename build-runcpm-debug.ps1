$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$runCpmSrcDir = Join-Path $root 'tools/RunCPM/RunCPM'
$runtimeDir = Join-Path $root 'RunCPMRuntime'
$srcExe = Join-Path $runCpmSrcDir 'RunCPM.exe'
$dstExe = Join-Path $runtimeDir 'RunCPM.exe'

if (-not (Test-Path $runCpmSrcDir)) {
    throw "RunCPM source directory not found: $runCpmSrcDir"
}

if (Test-Path 'C:/msys64/ucrt64/bin') {
    $env:PATH = 'C:/msys64/ucrt64/bin;' + $env:PATH
}

Set-Location $runCpmSrcDir
mingw32-make mingw DEBUG=1 build

if (-not (Test-Path $runtimeDir)) {
    New-Item -ItemType Directory -Path $runtimeDir | Out-Null
}

Copy-Item -Path $srcExe -Destination $dstExe -Force
Write-Host "Copied $srcExe to $dstExe"
