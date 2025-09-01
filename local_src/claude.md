# Claude Code Instructions for DistroKit Project

This file provides guidance to Claude Code when working with the DistroKit embedded Linux build system.

## File Synchronization Requirements

**CRITICAL**: The following files must be kept in sync at all times:

### FZF Go Documentation Sync
- **Source**: `local_src/fzfgo/readme.md` 
- **Target**: `local_src/fzfgo/FuzzyFinder.md`

**Instructions**:
- When making changes to `local_src/fzfgo/readme.md`, **always** mirror the same content to `local_src/fzfgo/FuzzyFinder.md`
- When making changes to `local_src/fzfgo/FuzzyFinder.md`, **always** mirror the same content to `local_src/fzfgo/readme.md`
- These files must contain identical content
- Use `cp local_src/fzfgo/readme.md local_src/fzfgo/FuzzyFinder.md` or equivalent to maintain synchronization

## Project Context

This is a PTXdist-based Board Support Package for creating embedded Linux systems targeting:
- BeagleBone Black (ARM v7a platform)
- Other ARM platforms (v8a, MIPS, x86_64)

## Build System Notes

- Uses PTXdist 2025.06.0
- Kernel: Linux 5.15.167
- Init: systemd 257.5
- Toolchain: arm-v7a-linux-gnueabihf
- Images generated in `platform-v7a/images/`

## Development Workflow

When working on local source packages in `local_src/`:
1. Make changes to source code
2. Update any synchronized documentation files
3. Rebuild with `ptxdist targetinstall <package>`
4. Test in QEMU with `configs/platform-v7a/run 9p`

## Important Reminders

- Always maintain file synchronization as specified above
- Check for synchronized files before committing changes
- Verify documentation consistency across mirrored files