## Beagle Bone Black Image

To build a Linux image for the **BeagleBone Black** using **PTXdist** and its **DistroKit**, follow these steps based on the official PTXdist documentation and this DistroKit repository:

---

### 🛠️ Prerequisites

Ensure your host system has the following installed:

- A Linux development environment (Debian/Ubuntu preferred)
- Essential build tools: `git`, `make`, `gcc`, `ncurses-dev`, `flex`, `bison`, `libtool`, `pkg-config`, `build-essential`
- Python 3 and pip
- At least 20GB of free disk space

---

### 📦 Installing PTXdist-2025.06.0

#### Download and Install PTXdist

```bash
# Download PTXdist 2025.06.0
wget http://www.pengutronix.de/software/ptxdist/download/ptxdist-2025.06.0.tar.bz2

# Extract the tarball
tar xf ptxdist-2025.06.0.tar.bz2 && cd ptxdist-2025.06.0

# Configure, build and install
./configure && make && sudo make install

# Verify installation
ptxdist --version
```

---

### 🔧 Installing OSELAS Cross-Compiler Toolchain

Since PTXdist 2025.06.0 requires **OSELAS.Toolchain-2024.11.1** (the latest available), install it as follows:

#### Option 1: Pre-built Debian Packages (Recommended)

```bash
# Add Pengutronix repository
echo "deb http://debian.pengutronix.de/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/pengutronix.list

# Add GPG key
wget -O - http://debian.pengutronix.de/pool/main/p/pengutronix-archive-keyring/pengutronix-archive-keyring.gpg | sudo apt-key add -

# Update package list
sudo apt update

# Install ARM v7a toolchain for BeagleBone Black
sudo apt install oselas.toolchain-2024.11.1-arm-v7a-linux-gnueabihf-gcc-14.2.1-glibc-2.40-binutils-2.43.1-kernel-6.10.0-sanitized
```

#### Option 2: Build from Source

```bash
# Download OSELAS.Toolchain source
wget http://www.pengutronix.de/software/toolchain/download/OSELAS.Toolchain-2024.11.1.tar.bz2

# Extract and build (takes 2-4 hours)
tar xf OSELAS.Toolchain-2024.11.1.tar.bz2 && cd OSELAS.Toolchain-2024.11.1
./configure
make
sudo make install
```

---

### 📦 Step-by-Step Build Guide

#### 1. **Clone the DistroKit Repository**

```bash
git clone https://git.pengutronix.de/git/DistroKit.git
cd DistroKit
```

#### 2. **Select BeagleBone Black Platform**

```bash
# Select the ARM v7a platform configuration (includes BeagleBone Black)
ptxdist select configs/platform-v7a
```

This sets up the BeagleBone Black platform configuration from `configs/platform-v7a/platformconfig`.

#### 3. **Configure the Project** (Optional)

Launch the configuration menu to customize packages:

```bash
# Configure BSP packages and settings
ptxdist menuconfig
```

Here you can:
- Select packages (BusyBox, systemd, NetworkManager, etc.)
- Configure system settings
- Set root filesystem options

For kernel-specific configuration:

```bash
# Configure Linux kernel options
ptxdist kernelconfig
```

For bootloader configuration:

```bash
# Configure Barebox bootloader
ptxdist barebox-config
```

#### 4. **Build the Complete System**

```bash
# Build toolchain, kernel, root filesystem, and bootloader
ptxdist go
```

This command builds:
- Cross-compilation toolchain (if not already available)
- Linux kernel (zImage) with device trees
- Barebox bootloader and MLO (secondary bootloader)
- Root filesystem with systemd, NetworkManager, and selected packages
- All dependencies and libraries

**Build time**: 1-3 hours depending on your system and selected packages.

#### 5. **Create the Final BeagleBone Black Image**

```bash
# Generate the final disk images
ptxdist images
```

This creates the bootable image files in `platform-v7a/images/`:
- `beaglebone.hdimg` - Main bootable SD card image
- `linuximage` - Kernel image
- `root.tgz` - Root filesystem archive
- `root.ext4` - Root filesystem as ext4 image

#### 6. **Flash the Image to MicroSD Card**

Use the BeagleBone-specific image:

```bash
# Write to SD card (replace /dev/sdX with your actual SD card device)
sudo dd if=platform-v7a/images/beaglebone.hdimg of=/dev/sdX bs=4M status=progress sync

# Or use a flashing tool like balenaEtcher with the .hdimg file
```

**⚠️ Warning**: Double-check your SD card device path to avoid data loss!

#### 7. **Boot BeagleBone Black from SD Card**

1. Insert the flashed MicroSD card into the BeagleBone Black
2. **Hold down the User/Boot button (S2)** while powering on the device
3. Release the button after the power LED illuminates
4. The system should boot from the MicroSD card

---

### 🔧 Serial Console Access

Connect to the debug serial port for console access:

- **Port**: J1 (6-pin header near the Ethernet port)
- **Pinout**:
  - J1.1: GND (Black wire)
  - J1.4: RxD (White wire)
  - J1.5: TxD (Green wire)
- **Settings**: 115200 baud, 8N1, no flow control

Use a USB-to-TTL serial adapter and terminal software like `minicom`:

```bash
# Install minicom
sudo apt install minicom

# Configure and connect
sudo minicom -D /dev/ttyUSB0 -b 115200
```

---

### 🧩 Advanced Customization & Tips

#### Adding Custom Packages

1. Modify package selection:
```bash
ptxdist menuconfig
```

2. Add local source packages in `local_src/` directory

3. Create custom rules in `configs/platform-v7a/rules/`

#### Kernel Customization

```bash
# Modify kernel configuration
ptxdist kernelconfig

# Add custom device tree modifications in:
# configs/platform-v7a/dts/
```

#### Bootloader Customization

```bash
# Customize Barebox bootloader
ptxdist barebox-config

# Modify boot environment in:
# configs/platform-v7a/barebox-defaultenv/
```

#### Image Customization

Edit the image configuration:
```bash
# BeagleBone-specific image settings
configs/platform-v7a/config/images/beaglebone.config
```

#### Multi-Platform Development

Use the provided script for operations across all platforms:
```bash
# Run commands on all platforms
./scripts/p-all <ptxdist-command>

# Example: clean all platforms
./scripts/p-all clean
```

#### Quality Assurance

```bash
# Check for configuration issues
ptxdist lint

# Update configurations after PTXdist version changes  
ptxdist migrate
./scripts/p-all migrate
```

---

### 🛠️ Development Workflow

#### Incremental Development

```bash
# Clean and rebuild specific packages
ptxdist clean <package-name>
ptxdist targetinstall <package-name>

# Rebuild images only
ptxdist images

# Clean everything
ptxdist clean
```

#### Debugging and Analysis

```bash
# Get detailed build information
ptxdist print <package-name>

# Show package dependencies
ptxdist deps <package-name>

# Generate build reports
ptxdist docs-html
```

---

### 🆘 Troubleshooting

#### Common Build Issues

1. **Missing host tools**: Install required development packages
```bash
sudo apt install build-essential libncurses-dev flex bison libtool
```

2. **Toolchain not found**: Verify OSELAS toolchain installation and PATH

3. **Insufficient disk space**: Ensure at least 20GB free space

4. **Network timeout**: Check internet connectivity for package downloads

#### BeagleBone Black Specific Issues

1. **Boot failure**: Ensure User/Boot button (S2) is pressed during power-on
2. **No serial output**: Check serial cable connections and settings (115200 8N1)
3. **SD card not detected**: Try different SD card or reformat as FAT32

#### Getting Help

- DistroKit mailing list: `distrokit@pengutronix.de`
- PTXdist documentation: https://www.ptxdist.org/doc/
- DistroKit repository: https://git.pengutronix.de/cgit/DistroKit/

---

### 🖥️ Testing with QEMU Emulator

Before flashing to real hardware, you can test the BeagleBone Black image using QEMU emulation:

#### Prerequisites

Install QEMU ARM system emulator:

```bash
# Ubuntu/Debian
sudo apt install qemu-system-arm

# Or build QEMU with PTXdist (if enabled in menuconfig)
ptxdist targetinstall host-qemu
```

#### Running the Image in QEMU

The DistroKit platform-v7a configuration includes QEMU-compatible images. Use the VExpress board emulation:

```bash
# Navigate to the images directory
cd platform-v7a/images/

# Run with QEMU ARM VExpress board
qemu-system-arm \
    -M vexpress-a9 \
    -cpu cortex-a9 \
    -m 512M \
    -kernel linuximage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=root.ext4,if=sd,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0 rootwait rw" \
    -serial stdio \
    -display none
```

#### Alternative: Using the Complete HDIMG

```bash
# Run using the complete disk image
qemu-system-arm \
    -M vexpress-a9 \
    -cpu cortex-a9 \
    -m 512M \
    -drive file=vexpress.hdimg,if=sd,format=raw \
    -serial stdio \
    -display none
```

#### QEMU Parameters Explained

- `-M vexpress-a9`: ARM Versatile Express board with Cortex-A9
- `-cpu cortex-a9`: Use Cortex-A9 CPU (similar to BeagleBone Black's AM335x)
- `-m 512M`: Allocate 512MB RAM
- `-kernel linuximage`: Boot kernel directly
- `-dtb vexpress-v2p-ca9.dtb`: Device tree for VExpress board
- `-drive file=root.ext4,if=sd`: Root filesystem as SD card
- `-append "..."`: Kernel command line arguments
- `-serial stdio`: Redirect serial console to terminal
- `-display none`: Run headless (console only)

#### Adding Network Support

Enable network connectivity in QEMU:

```bash
qemu-system-arm \
    -M vexpress-a9 \
    -cpu cortex-a9 \
    -m 512M \
    -kernel linuximage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=root.ext4,if=sd,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0 rootwait rw" \
    -serial stdio \
    -display none \
    -netdev user,id=net0 \
    -device lan9118,netdev=net0
```

#### QEMU Console Controls

- **Ctrl+A, X**: Exit QEMU
- **Ctrl+A, C**: Switch to QEMU monitor console
- **Ctrl+A, H**: Show help for console commands

#### Debugging with QEMU

Enable additional debugging options:

```bash
# Run with debugging enabled
qemu-system-arm \
    -M vexpress-a9 \
    -cpu cortex-a9 \
    -m 512M \
    -kernel linuximage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=root.ext4,if=sd,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0 rootwait rw debug" \
    -serial stdio \
    -display none \
    -d guest_errors \
    -monitor telnet:127.0.0.1:1234,server,nowait
```

#### Using QEMU Scripts

Create a script for easier testing:

```bash
#!/bin/bash
# qemu-test.sh
cd platform-v7a/images/

qemu-system-arm \
    -M vexpress-a9 \
    -cpu cortex-a9 \
    -m 512M \
    -kernel linuximage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=root.ext4,if=sd,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0 rootwait rw" \
    -serial stdio \
    -display none \
    -netdev user,id=net0 \
    -device lan9118,netdev=net0

chmod +x qemu-test.sh
./qemu-test.sh
```

#### QEMU Benefits for Development

1. **Fast Iteration**: No need to flash SD cards repeatedly
2. **Easy Debugging**: Access to QEMU monitor and debugging tools
3. **Safe Testing**: No risk of hardware damage
4. **Automated Testing**: Can be scripted for CI/CD pipelines
5. **Snapshot Support**: Save and restore system states

**Note**: While QEMU provides excellent testing capabilities, always verify final functionality on real BeagleBone Black hardware due to hardware-specific differences.

---

### 📚 Next Steps

After successfully booting your BeagleBone Black with DistroKit (either in QEMU or on hardware):

1. **Network Configuration**: Connect Ethernet or configure WiFi
2. **Package Management**: Use `opkg` for runtime package installation  
3. **Development**: Set up cross-compilation environment for custom applications
4. **Updates**: Implement RAUC-based secure updates
5. **Hardware Integration**: Configure GPIO, SPI, I2C, and other peripherals
6. **QEMU Testing**: Use emulation for rapid development and testing cycles

This DistroKit-based system provides a modern, maintainable foundation for embedded Linux development on BeagleBone Black with systemd init, NetworkManager, and professional tooling.