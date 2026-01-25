#!/bin/bash
set -e

# 1. Install remaining dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y flex bison libssl-dev libelf-dev bc dwarves

# 2. Prepare kernel source
KERNEL_DIR="$HOME/target_kernel"
cd "$KERNEL_DIR"

echo "Preparing kernel config..."
zcat /proc/config.gz > .config
make oldconfig

echo "Preparing headers and scripts..."
make modules_prepare

# 3. Create symlink for the build directory
BUILD_DIR="/lib/modules/$(uname -r)/build"
echo "Creating symlink at $BUILD_DIR..."
sudo mkdir -p "/lib/modules/$(uname -r)"
sudo ln -snf "$KERNEL_DIR" "$BUILD_DIR"

echo "Kernel headers prepared successfully!"
