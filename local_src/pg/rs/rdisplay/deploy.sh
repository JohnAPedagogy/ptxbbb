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
REMOTE_PATH="/usr/local/bin/rdisplay"

echo "Deploying rdisplay to $TARGET_IP..."

# Check if executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo "Error: Executable not found at $EXECUTABLE"
    echo "Please build the project first with: cargo build --target armv7-unknown-linux-gnueabihf --release"
    exit 1
fi

# Copy executable to target
echo "Copying executable to $TARGET_IP..."
scp "$EXECUTABLE" "root@$TARGET_IP:$REMOTE_PATH"

# Make executable
echo "Setting permissions..."
ssh "root@$TARGET_IP" "chmod +x $REMOTE_PATH"

echo "Deployment complete! rdisplay is now available at $TARGET_IP:$REMOTE_PATH"