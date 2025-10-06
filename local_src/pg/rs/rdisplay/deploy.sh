#!/bin/bash

# Deploy script for rdisplay
# Usage: ./deploy.sh <last_octet>
# Example: ./deploy.sh 10 (deploys to 172.16.100.10)

set -e

# Enable verbose mode
VERBOSE=true

log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%H:%M:%S')] $1"
    fi
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <last_octet>"
    echo "Example: $0 10 (deploys to 172.16.100.10)"
    exit 1
fi

LAST_OCTET=$1
TARGET_IP="172.16.100.$LAST_OCTET"
EXECUTABLE="target/armv7-unknown-linux-gnueabihf/release/rdisplay"
REMOTE_PATH="/usr/sbin/rdisplay"

log "Starting deployment process for rdisplay..."
log "Target IP: $TARGET_IP"
log "Local executable path: $EXECUTABLE"
log "Remote installation path: $REMOTE_PATH"

echo "Deploying rdisplay to $TARGET_IP..."

# Check if executable exists, build if not
if [ ! -f "$EXECUTABLE" ]; then
    log "Executable not found at $EXECUTABLE"
    log "Building project for ARM target..."
    echo "Executable not found at $EXECUTABLE"
    echo "Building project for ARM target..."
    
    # Check if cross is installed
    log "Checking if cross is installed..."
    if ! command -v cross &> /dev/null; then
        log "cross command not found. Installing cross..."
        echo "cross command not found. Installing cross..."
        cargo install cross
        if ! command -v cross &> /dev/null; then
            echo "Failed to install cross. Please install it manually with: cargo install cross"
            exit 1
        fi
        log "cross installed successfully!"
        echo "cross installed successfully!"
    else
        log "cross is already installed"
    fi
    
    # Check if Docker is running
    log "Checking if Docker is running..."
    if ! docker info > /dev/null 2>&1; then
        echo "Docker is not running. Please start Docker Desktop and try again."
        echo "Alternatively, you can build manually with:"
        echo "  rustup target add armv7-unknown-linux-gnueabihf"
        echo "  cargo build --target armv7-unknown-linux-gnueabihf --release"
        exit 1
    fi
    log "Docker is running"
    
    # Use cross to build for ARM (requires Docker)
    log "Starting cross build process..."
    echo "Building with cross for target armv7-unknown-linux-gnueabihf..."
    cross build --target armv7-unknown-linux-gnueabihf --release
    #   rustup target add armv7-unknown-linux-gnueabihf
    #   cargo build --target armv7-unknown-linux-gnueabihf --release
    # Check if build was successful
    if [ ! -f "$EXECUTABLE" ]; then
        echo "Error: Build failed or executable still not found"
        exit 1
    fi
    log "Build completed successfully!"
    echo "Build completed successfully!"
else
    log "Executable already exists at $EXECUTABLE"
fi

# Copy executable to target
log "Starting file transfer to remote system..."
log "Source: $EXECUTABLE"
log "Destination: root@$TARGET_IP:$REMOTE_PATH"
echo "Copying executable to $TARGET_IP..."
scp "$EXECUTABLE" "root@$TARGET_IP:$REMOTE_PATH"
log "File transfer completed successfully"

# Make executable
log "Setting executable permissions on remote system..."
echo "Setting permissions..."
ssh "root@$TARGET_IP" "chmod +x $REMOTE_PATH"
log "Permissions set successfully"

log "Verifying remote installation..."
ssh "root@$TARGET_IP" "ls -la $REMOTE_PATH"

log "Deployment process completed!"
echo "Deployment complete! rdisplay is now available at $TARGET_IP:$REMOTE_PATH"