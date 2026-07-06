# =============================================================================
# PTXBBB Build Environment Dockerfile
# Based on Debian Bookworm (stable)
# =============================================================================
# PTXBBB is a preconfigured BSP based on PTXdist for ARM Cortex-A boards.
# This Dockerfile sets up a complete build environment including PTXdist.
#
# Usage:
#   docker build -t ptxbbb-builder .
#   docker run -it --rm -v $(pwd)/output:/output ptxbbb-builder
# =============================================================================

FROM debian:bookworm-slim

LABEL maintainer="PTXBBB Build Environment"
LABEL description="Debian-based container for building PTXBBB/PTXdist BSPs"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# =============================================================================
# STEP 1: Install base system dependencies
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential build tools
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    \
    # Version control
    git \
    git-lfs \
    subversion \
    \
    # PTXdist / build system dependencies
    autoconf \
    automake \
    libtool \
    pkg-config \
    \
    # Python (PTXdist uses Python for various scripts)
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    \
    # Kernel build dependencies
    bison \
    flex \
    libncurses-dev \
    libssl-dev \
    libelf-dev \
    bc \
    \
    # Filesystem / image tools
    squashfs-tools \
    genext2fs \
    e2fsprogs \
    dosfstools \
    mtools \
    parted \
    kpartx \
    \
    # Compression tools
    lzop \
    xz-utils \
    lzma \
    zlib1g-dev \
    \
    # Networking tools (for downloads)
    wget \
    curl \
    ca-certificates \
    \
    # Text processing
    sed \
    gawk \
    grep \
    diffutils \
    patch \
    \
    # Archive tools
    unzip \
    tar \
    \
    # Documentation tools
    graphviz \
    \
    # QEMU for emulation/testing (optional but useful)
    qemu-system-arm \
    qemu-system-x86 \
    qemu-utils \
    \
    # Misc utilities
    file \
    cpio \
    rsync \
    locales \
    \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Generate locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# =============================================================================
# STEP 2: Install PTXdist
# =============================================================================
# PTXdist is the build system that PTXBBB is based on.
# We download and install the latest stable version.
# You may need to adjust the PTXDIST_VERSION to match what the project requires.

ENV PTXDIST_VERSION=2025.03.0
ENV PTXDIST_URL=https://public.pengutronix.de/software/ptxdist/ptxdist-${PTXDIST_VERSION}.tar.bz2

RUN cd /tmp && \
    wget -q ${PTXDIST_URL} && \
    tar -xjf ptxdist-${PTXDIST_VERSION}.tar.bz2 && \
    cd ptxdist-${PTXDIST_VERSION} && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && \
    rm -rf ptxdist-${PTXDIST_VERSION}*

# Verify PTXdist installation
RUN ptxdist --version

# =============================================================================
# STEP 3: Set up environment for PTXdist/PTXBBB
# =============================================================================

# PTXdist needs to know where to find toolchains and configs
ENV PTXDIST_WORKSPACE=/workspace
ENV PTXDIST_PATH=/usr/local/share/ptxdist
ENV PATH="/usr/local/bin:${PATH}"

# Create workspace directory
RUN mkdir -p ${PTXDIST_WORKSPACE}
WORKDIR ${PTXDIST_WORKSPACE}

# =============================================================================
# STEP 4: Clone Current Repository
# =============================================================================
# We clone the ptxbbb repository. You can mount your own source instead.

RUN git clone https://github.com/JohnAPedagogy/ptxbbb /workspace/ptxbbb

WORKDIR /workspace/ptxbbb

# =============================================================================
# STEP 5: Set up entrypoint and default command
# =============================================================================

# Copy a helper script for common build tasks
RUN cat > /usr/local/bin/ptxbbb-build << 'EOF'
#!/bin/bash
set -e

# Default platform if not specified
PLATFORM=${PLATFORM:-v7a}

echo "========================================"
echo "PTXBBB Build Environment"
echo "Platform: ${PLATFORM}"
echo "========================================"

cd /workspace/ptxbbb

# Select platform configuration
case "${PLATFORM}" in
v7a)
ptxdist platform configs/platform-v7a/platformconfig
;;
v7a_noneon)
ptxdist platform configs/platform-v7a_noneon/platformconfig
;;
v8a)
ptxdist platform configs/platform-v8a/platformconfig
;;
x86_64)
ptxdist platform configs/platform-x86_64/platformconfig
;;
*)
echo "Unknown platform: ${PLATFORM}"
echo "Supported: v7a, v7a_noneon, v8a, x86_64"
exit 1
;;
esac

# Go menuconfig if requested
if [ "$1" == "menuconfig" ]; then
ptxdist menuconfig
exit 0
fi

# Build the BSP
ptxdist go

# Copy output to shared volume if mounted
if [ -d /output ]; then
echo "Copying build artifacts to /output..."
cp -r platform-${PLATFORM}/images /output/ 2>/dev/null || true
cp -r platform-${PLATFORM}/root /output/ 2>/dev/null || true
fi

echo "Build complete!"
EOF

RUN chmod +x /usr/local/bin/ptxbbb-build

# =============================================================================
# STEP 6: Final setup
# =============================================================================

# Create a non-root user for building (recommended)
RUN useradd -m -s /bin/bash -u 1000 builder && \
    chown -R builder:builder /workspace

# Allow builder to run ptxdist
RUN usermod -aG sudo builder

# Switch to builder user
USER builder

# Set home for builder
ENV HOME=/home/builder

# Default to bash for interactive use
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "echo 'PTXBBB build environment ready. Run: ptxbbb-build [PLATFORM]'"]
