# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

DistroKit is a PTXdist-based Board Support Package (BSP) that creates modern embedded Linux systems. It uses PTXdist 2025.06.0 as the build system and assembles systems with barebox bootloader, mainline kernel, systemd init, and NetworkManager.

## Architecture

### Directory Structure

- `configs/` - Platform-specific configurations for different hardware
  - `platform-v7a/` - ARM v7a platforms (BeagleBone Black/White, i.MX6, etc.)
  - `platform-v8a/` - ARM v8a platforms (BeaglePlay, etc.)  
  - `platform-rpi1/` - Raspberry Pi 1
  - `platform-x86_64/` - x86_64 platforms
  - `platform-mips*/` - MIPS platforms
  - `ptxconfig` - Main BSP configuration
- `doc/` - Documentation in reStructuredText format
- `projectroot/` - Root filesystem customizations
- `local_src/` - Local source packages and examples
- `scripts/` - Build helper scripts
  - `p-all` - Run PTXdist commands on all platforms

### Platform Configuration Structure

Each platform directory contains:
- `platformconfig` - PTXdist platform configuration
- `kernelconfig` - Linux kernel configuration
- `barebox.config` - Barebox bootloader configuration
- `config/images/` - Image generation configurations
- `rules/` - Custom build rules and packages
- `dts/` - Device tree overlays and customizations
- `barebox-defaultenv/` - Barebox default environment

## Common Development Commands

### Initial Setup
```bash
# Select a platform (example: ARM v7a for BeagleBone Black)
ptxdist select configs/platform-v7a

# Select project configuration  
ptxdist select ptxconfig
```

### Configuration
```bash
# Configure BSP packages and options
ptxdist menuconfig

# Configure Linux kernel
ptxdist kernelconfig

# Configure Barebox bootloader
ptxdist barebox-config

# Migrate configurations after PTXdist updates
ptxdist migrate
```

### Building
```bash
# Build everything (toolchain, kernel, rootfs, bootloader)
ptxdist go

# Build specific package
ptxdist targetinstall <package-name>

# Generate final images
ptxdist images

# Clean specific package
ptxdist clean <package-name>

# Clean all packages
ptxdist clean
```

### Multi-Platform Operations
```bash
# Run PTXdist command on all platforms
./scripts/p-all <command>

# Examples:
./scripts/p-all migrate        # Migrate all platforms
./scripts/p-all clean          # Clean all platforms  
./scripts/p-all go             # Build all platforms (takes hours)
```

### Development and Debugging
```bash
# Show package information
ptxdist print <package-name>

# Show package dependencies
ptxdist deps <package-name>

# Check configuration for issues
ptxdist lint

# Update config files and keep in sync
ptxdist oldconfig all

# Generate HTML documentation
ptxdist docs-html
```

### Package Development
```bash
# Create new package
ptxdist newpackage

# Edit package rules
ptxdist edit <package-name>

# Extract and modify source
ptxdist extract <package-name>
ptxdist prepare <package-name>
```

## Build System Details

### Toolchain Requirements
- Uses OSELAS.Toolchain-2024.11.1 (configured in platform configs)
- ARM v7a: `arm-v7a-linux-gnueabihf` toolchain for platforms like BeagleBone Black
- ARM v8a: `aarch64-v8a-linux-gnu` toolchain for 64-bit ARM platforms

### Image Generation
- Images are created in `platform-*/images/` directories
- Common image types: `.hdimg` (disk images), `.ext4` (filesystems), `.tgz` (archives)
- Image configurations in `config/images/*.config`
- Uses `genimage` tool for creating bootable images

### Key Technologies
- **Bootloader**: Barebox (modern, feature-rich bootloader)
- **Init System**: systemd with NetworkManager
- **Package Format**: OpenEmbedded-compatible packages (.ipk)
- **Updates**: RAUC-based A/B update system
- **Security**: Code signing support for secure boot

## Hardware Platform Support

### ARM v7a Platforms (platform-v7a)
- BeagleBone Black/White (AM335x)
- i.MX6 boards (Sabrelite, RIoTboard, UDOO Neo)
- Raspberry Pi 2/3
- STM32MP1 series
- SAMA5D27 boards

### ARM v8a Platforms (platform-v8a)  
- BeaglePlay (AM62x)
- Raspberry Pi 4

### x86_64 Platforms (platform-x86_64)
- Generic x86_64 systems
- QEMU virtual machines

## Development Workflow

### For New Platforms
1. Copy existing platform config as template
2. Modify `platformconfig` for architecture/toolchain
3. Update `kernelconfig` for hardware support
4. Configure `barebox.config` for bootloader
5. Create image configuration in `config/images/`
6. Add device trees in `dts/` if needed

### For Package Development
1. Place sources in `local_src/` or create remote package
2. Write package rules in `rules/*.make`
3. Add package selection in `rules/*.in`
4. Test with `ptxdist targetinstall <package>`
5. Rebuild images with `ptxdist images`

### For Kernel Development
1. Extract kernel: `ptxdist extract kernel`
2. Modify sources in `platform-*/build-target/linux-*/`
3. Configure: `ptxdist kernelconfig`
4. Build: `ptxdist targetinstall kernel`
5. Generate images: `ptxdist images`

## Quality Assurance

### Before Submitting Changes
```bash
# Check for lint issues
ptxdist lint

# Test multi-platform compatibility
./scripts/p-all migrate
./scripts/p-all menuconfig  # Check for conflicts

# Build test on affected platforms
ptxdist clean && ptxdist go
```

### Maintenance Tasks
```bash
# Update to new PTXdist version
ptxdist-<new-version> migrate
./scripts/p-all migrate

# Sync config diffs for kernel/barebox
ptxdist oldconfig all
```

## Contributing

- Main repository: https://git.pengutronix.de/cgit/DistroKit/
- Mailing list: distrokit@pengutronix.de
- Use `git commit --signoff` for Developer Certificate of Origin
- Send patches via `git send-email` or `git format-patch`
- Archives available at lore.distrokit.org

## File Locations Reference

- Platform configs: `configs/platform-*/platformconfig`
- Kernel configs: `configs/platform-*/kernelconfig` 
- Barebox configs: `configs/platform-*/barebox.config`
- Image configs: `configs/platform-*/config/images/*.config`
- Build outputs: `platform-*/images/`
- Documentation: `doc/*.rst`
- Hardware docs: `doc/hardware_*.rst`