# bforth2 Build and Run Tasks

This project defines VS Code tasks in .vscode/tasks.json.

## Environment Setup

For environment bootstrap and maintenance instructions, use RUNCPM_SETUP.md as the source of truth.

This includes AI-agent-oriented steps for:

1. Installing or updating toolchain dependencies.
2. Cloning or refreshing the RunCPM source.
3. Building and deploying RunCPM runtime artifacts.
4. Applying required RunCPM code customizations.

When preparing a new machine or reconfiguring this workspace, follow RUNCPM_SETUP.md first.

## zasm Setup

This project expects zasm at `C:\Users\boris\Desktop\zasm\zasm.exe` by default.

On Windows, install it from the official zasm distribution page:

1. Open the zasm download page: https://k1.spdns.de/Develop/Projects/zasm/Distributions/
2. Download the latest `win64` archive.
3. Extract the archive to `C:\Users\boris\Desktop\zasm` so that `zasm.exe` sits at `C:\Users\boris\Desktop\zasm\zasm.exe`.
4. Verify the install by running `C:\Users\boris\Desktop\zasm\zasm.exe` from a terminal window, or pass a different absolute path with `-AssemblerExe` to `build.ps1`.

If you prefer source builds, the zasm project is also available at https://github.com/Megatokio/zasm.

## Emulator Build

Task: RunCPM: build runcpm.exe

This task is only needed after initial RunCPM setup when you make changes to the RunCPM source code.

This task runs build-runcpm-debug.ps1. It:

1. Builds RunCPM from tools/RunCPM/RunCPM using mingw32-make with DEBUG=1.
2. Copies tools/RunCPM/RunCPM/RunCPM.exe to RunCPMRuntime/RunCPM.exe.

## Default Build (Ctrl+Shift+B)

Task: Build bforth2.asm

This task runs build.ps1 with bforth2.asm as the source. It:
1. Assembles bforth2.asm.
2. Generates a zasm listing with symbols enabled and uses it to populate RunCPMRuntime/breakpoints.txt from labels containing breakpoint.
3. Produces bforth2.com.
4. Copies bforth2.com to RunCPMRuntime/A/0.

## Breakpoint Export

Breakpoint export is driven by label names that contain `breakpoint`.

Example source pattern:

```asm
start:
	LD C, $02
breakpoint:
	CALL $0005

second_breakpoint:
	CALL $0005
```

When you run the default build task, build.ps1 parses the zasm listing file, extracts matching label addresses, and writes them to RunCPMRuntime/breakpoints.txt in the form `label=$ADDR`.

RunCPM then loads RunCPMRuntime/breakpoints.txt at startup (with DEBUG enabled) and registers those addresses as execution breakpoints.

## ASM Formatting

This workspace includes a project formatter for ASM sources:

- Script: ./scripts/format-asm.ps1
- Style config: ./asm-format.json

Formatting tasks:

1. Task: Format ASM
2. Task: Check ASM formatting

The formatter applies a conservative layout policy aligned with this repo's current zasm-oriented style:

1. Left-aligned labels.
2. Aligned opcode and operand columns.
3. Optional opcode casing rules and pseudo-op exceptions.
4. Uppercased registers and condition keywords in operands.
5. Aligned inline comments.
6. End-of-file is normalized to exactly one trailing blank line containing four spaces (additional trailing blank/whitespace-only lines are removed).

Customize behavior by editing asm-format.json.

By default, include uses only *.asm. In this formatter, slash-free patterns are matched by basename, so *.asm includes ASM files in all subdirectories unless excluded.

Examples:

- Apply formatting:

	pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/format-asm.ps1 -Write

- Check formatting (non-zero exit if changes are needed):

	pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/format-asm.ps1 -Check

### Autoformat Shortcut Fallback (No Extension)

This workspace uses a no-extension fallback in .vscode/keybindings.json:

1. For .asm editors only, Ctrl+S runs save first.
2. Immediately after save, it runs task: Format ASM.

This provides formatting on Ctrl+S without requiring emeraldwalk.runonsave.

## Git Pre-commit Hook

This repository includes a pre-commit hook in .githooks/pre-commit that runs ASM formatting checks before commit.

Install it once per clone:

	pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/install-git-hooks.ps1

or run the VS Code task:

1. Task: Install git hooks

When formatting violations are found, commit is blocked and the hook prints the command to fix formatting.

## Emulator Launch

Task: RunCPM: launch

This task starts RunCPMRuntime/start-runcpm.ps1 for an interactive RunCPM session.

## Browser Bridge + Playwright

This workspace also supports browser-based RunCPM testing through a local Node bridge server.

Setup:

1. Install dependencies:

	npm install

2. Install the Playwright Chromium browser once:

	npx playwright install chromium

Run tests:

1. Smoke tests:

	npm test

2. UI mode:

	npm run test:ui

VS Code tasks:

1. Task: Playwright: install chromium - one-time Playwright browser install (Chromium).
2. Task: Playwright: test - runs Playwright smoke tests headless.
3. Task: Playwright: test ui - launches Playwright UI mode for interactive runs.
4. Task: Build bforth2 + Playwright test - assembles bforth2, then runs Playwright tests.
5. Task: Build bforth2 + launch bridge browser - assembles bforth2, starts bridge server if needed, and opens http://127.0.0.1:8080.
6. Task: Bridge: stop - stops node bridge_server.js if it owns port 8080.
7. Task: Bridge: restart + launch browser - stops bridge, rebuilds bforth2, starts bridge, and opens http://127.0.0.1:8080.

Bridge details:

1. Entry point: ./bridge_server.js
2. URL: http://127.0.0.1:8080
3. API endpoints:
   - GET /api/state
   - POST /api/command

Optional environment overrides:

1. RUNCPM_EXE (absolute path to RunCPM.exe)
2. RUNCPM_BRIDGE_HOST
3. RUNCPM_BRIDGE_PORT
4. RUNCPM_COMMAND_TIMEOUT_MS
5. RUNCPM_COMMAND_IDLE_MS

Troubleshooting:

1. Windows may log a node-pty warning (`AttachConsole failed`) while tests run.
2. This warning is currently non-fatal in this setup; browser bridge and tests can still pass.
3. If bridge behavior looks stale, run task `Bridge: restart + launch browser`.
