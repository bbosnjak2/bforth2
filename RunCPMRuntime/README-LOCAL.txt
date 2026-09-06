RunCPM local runtime setup

This folder is prepared for two CP/M drives:
- Drive A: runtime/A/0 (preloaded from DISK/A0.zip)
- Drive B: runtime/B/0 (empty)

RunCPM requirements:
- RunCPM.exe must be in this same runtime folder.
- A, B, CCP-* files must be next to RunCPM.exe.

How to run:
1) Build RunCPM from the repository (Visual Studio or supported Makefile toolchain).
2) Copy RunCPM.exe to this runtime folder.
3) Run: powershell -ExecutionPolicy Bypass -File .\start-runcpm.ps1

Inside CP/M:
- Use "B:" to switch to Drive B.
- Use "USER n" to switch user areas (0..15).
