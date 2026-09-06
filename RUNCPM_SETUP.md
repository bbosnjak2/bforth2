# RUNCPM Setup

For VS Code task usage (build, deploy, launch), see README.md.

Use these instructions from the project root folder.

## 1. Clone RunCPM

Clone the upstream repository into tools/RunCPM:

```powershell
git clone --depth 1 https://github.com/MockbaTheBorg/RunCPM.git tools/RunCPM
```

If tools/RunCPM already exists, refresh it instead:

```powershell
Set-Location .\tools\RunCPM
git pull --ff-only
Set-Location ..\..
```

## 2. Install Build Toolchain (Windows)

Install MSYS2:

```powershell
winget install --id MSYS2.MSYS2 --accept-package-agreements --accept-source-agreements --silent
```

Install GCC and make in MSYS2 (external path outside project root):

```powershell
& "C:\msys64\usr\bin\bash.exe" -lc "pacman -Sy --noconfirm --needed mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-make"
```

## 3. Build RunCPM

Preferred (project task-aligned) build from project root:

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\build-runcpm-debug.ps1
```

This builds tools/RunCPM/RunCPM/RunCPM.exe and deploys it to RunCPMRuntime/RunCPM.exe.

Manual build (if needed):

```powershell
Set-Location .\tools\RunCPM\RunCPM
$env:PATH = "C:\msys64\ucrt64\bin;" + $env:PATH
mingw32-make mingw build
```

Build output:

- tools/RunCPM/RunCPM/RunCPM.exe

## 4. Prompt Tweak (Show A> Instead of A0>)

By default, the internal CCP prompt may show the user area (for example A0>). To show classic drive-only prompts (A>, B>, and so on), edit tools/RunCPM/RunCPM/ccp.h and change the prompt format in the CCP loop:

From:

```c
sprintf((char *)prompt, "\r\n%c%u%c", 'A' + currentDrive, currentUser,
	submitFlag ? '$' : '>');
```

To:

```c
sprintf((char *)prompt, "\r\n%c%c", 'A' + currentDrive,
	submitFlag ? '$' : '>');
```

Then rebuild and redeploy RunCPM.exe:

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\build-runcpm-debug.ps1
```

## 5. Prepare Runtime Folder (A: and B:)

Create runtime folders and seed Drive A user area 0 from the provided disk image:

```powershell
Set-Location .\tools\RunCPM
New-Item -ItemType Directory -Force -Path .\runtime\A\0, .\runtime\B\0 | Out-Null
Expand-Archive -Path .\DISK\A0.zip -DestinationPath .\runtime\A\0 -Force

# Flatten nested A/0 if present in the zip
if (Test-Path .\runtime\A\0\A\0) {
	Move-Item .\runtime\A\0\A\0\* .\runtime\A\0 -Force
	Remove-Item .\runtime\A\0\A -Recurse -Force
}

Copy-Item .\CCP\* .\runtime -Force
Copy-Item .\RunCPM\RunCPM.exe .\runtime\RunCPM.exe -Force
```

## 6. Sync Runtime to Project Root

Sync runtime to project root runtime folder:

```powershell
Set-Location ..\..

# Merge generated runtime content into the existing RunCPMRuntime folder.
robocopy .\tools\RunCPM\runtime .\RunCPMRuntime /E
```

Final runtime folder location:

- RunCPMRuntime

## 7. Run RunCPM

From project root:

```powershell
Set-Location .\RunCPMRuntime
.\start-runcpm.ps1
```

If start-runcpm.ps1 is not present, run RunCPM directly:

```powershell
Set-Location .\RunCPMRuntime
.\RunCPM.exe
```

Expected runtime structure:

- RunCPMRuntime/RunCPM.exe
- RunCPMRuntime/start-runcpm.ps1
- RunCPMRuntime/A/0
- RunCPMRuntime/B/0

## 8. Smoke Test (Non-Interactive)

Use AUTOEXEC.TXT to exit automatically and verify startup:

```powershell
Set-Location .\RunCPMRuntime
Set-Content -Path .\AUTOEXEC.TXT -Value "EXIT"
.\start-runcpm.ps1
$LASTEXITCODE
Remove-Item .\AUTOEXEC.TXT -Force
```

The expected exit code is 0.

## 9. Cleanup Old Runtime Path

After RunCPMRuntime is working, remove the old folder if it still exists:

```powershell
if (Test-Path .\tools\RunCPM\runtime) {
	Remove-Item .\tools\RunCPM\runtime -Recurse -Force
}
```
