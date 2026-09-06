# Agent Instructions

## Project overview

This repository builds a Z80 Forth system centered on the assembly source [bforth2.asm](bforth2.asm). The project expects the zasm assembler at `C:\Users\boris\Desktop\zasm\zasm.exe` unless a different absolute path is passed to the build script.

## Build and run workflow

- Default build: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./build.ps1 -Source ./bforth2.asm`
- VS Code task: `Build bforth2.asm`
- This build assembles the source, exports breakpoint labels into `RunCPMRuntime/breakpoints.txt`, produces `bforth2.com`, and copies it into `RunCPMRuntime/A/0`.
- Run the emulator with the task `RunCPM: launch`, which starts `RunCPMRuntime/start-runcpm.ps1`.
- If you change the bundled RunCPM source, rebuild that tool with the task `RunCPM: build runcpm.exe`.

## Repository conventions

- Keep Forth and command-processor changes in the assembly source and related subfolders rather than inventing new runtime patterns.
- Prefer surgical edits in the existing structure: [bforth2.asm](bforth2.asm), [command-processor/](command-processor/), [input/](input/), [output/](output/), [util/](util/), and [constants/](constants/).
- Preserve the repo’s zasm-oriented style and existing label/operand layout.
- Do not add broad refactors unless a task explicitly requires them.

## Formatting

- Use the repo formatter before finalizing assembly edits:
  - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/format-asm.ps1 -Write`
  - Or run the VS Code task `Format ASM`.
- Check formatting with:
  - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/format-asm.ps1 -Check`

## Testing and validation

- Preferred repo validation: assemble the project with the default build task, then run the narrowest relevant smoke check.
- Browser/bridge smoke tests:
  - `npm test`
  - `npm run test:ui`
- Useful tasks already defined in the workspace:
  - `Build bforth2 + Playwright test`
  - `Build bforth2 + launch bridge browser`
  - `Bridge: restart + launch browser`

## Key project files

- [README.md](README.md) for environment and task documentation.
- [RUNCPM_SETUP.md](RUNCPM_SETUP.md) as the setup source of truth for local toolchain and runtime configuration.
- [scripts/format-asm.ps1](scripts/format-asm.ps1) for repo formatting rules.
- [bridge_server.js](bridge_server.js) for the browser bridge and Playwright integration.

## Working style for agents

- Keep the first response focused on the specific assembly file or behavior under discussion.
- When a bug is suspected, build first, confirm the failure mode, then patch the relevant file.
- If a change affects both the Forth engine and the command processor, mention both areas in the summary rather than treating them as unrelated.
- Limit context expansion: prefer exact file references and narrow commands over broad repo-wide edits.

