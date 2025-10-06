#!/bin/bash

# Deploy script for rdisplay
# Usage: ./deploy.sh <last_octet>
# Example: ./deploy.sh 10 (deploys to 172.16.100.10)

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <last_octet>"
    echo "Example: $0 10 (deploys to 172.16.100.10)"
    exit 1
fi

LAST_OCTET=$1
TARGET_IP="172.16.100.$LAST_OCTET"
EXECUTABLE="target/armv7-unknown-linux-gnueabihf/release/rdisplay"
REMOTE_PATH="/usr/sbin/rdisplay"

echo "Deploying rdisplay to $TARGET_IP..."

# Check if executable exists, build if not
if [ ! -f "$EXECUTABLE" ]; then
    echo "Executable not found at $EXECUTABLE"
    echo "Building project for ARM target..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo "Docker is not running. Please start Docker Desktop and try again."
        echo "Alternatively, you can build manually with:"
        echo "  rustup target add armv7-unknown-linux-gnueabihf"
        echo "  cargo build --target armv7-unknown-linux-gnueabihf --release"
        exit 1
    fi
    
    # Use cross to build for ARM (requires Docker)
    cross build --target armv7-unknown-linux-gnueabihf --release
    #   rustup target add armv7-unknown-linux-gnueabihf
    #   cargo build --target armv7-unknown-linux-gnueabihf --release
    # Check if build was successful
    if [ ! -f "$EXECUTABLE" ]; then
        echo "Error: Build failed or executable still not found"
        exit 1
    fi
    echo "Build completed successfully!"
fi

# Copy executable to target
echo "Copying executable to $TARGET_IP..."
scp "$EXECUTABLE" "root@$TARGET_IP:$REMOTE_PATH"

# Make executable
echo "Setting permissions..."
ssh "root@$TARGET_IP" "chmod +x $REMOTE_PATH"

echo "Deployment complete! rdisplay is now available at $TARGET_IP:$REMOTE_PATH"