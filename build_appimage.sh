#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
APP_NAME="CUDABurner"
APP_DIR="$APP_NAME.AppDir"
BUILD_DIR="build_appimage" # Use a dedicated build directory

# --- 1. Generate Icon ---
echo "Generating placeholder icon..."
bash create_icon.sh
chmod 644 cudaburner.png # Ensure correct permissions

# --- 2. Download linuxdeploy ---
echo "Downloading linuxdeploy..."
if [ ! -f linuxdeploy-x86_64.AppImage ]; then
    wget -q "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x linuxdeploy-x86_64.AppImage
fi

# --- 2. Build the project ---
echo "Building the project..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure CMake. AppImage standard practice is to use /usr as the prefix.
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

# Compile the project
make -j$(nproc)

# --- 3. Create the AppDir structure ---
echo "Creating AppDir..."
# The DESTDIR variable is used to stage the installation into a temporary directory
rm -rf ../"$APP_DIR"
make install DESTDIR=../"$APP_DIR"

cd .. # Return to the project root

# --- 4. Run linuxdeploy ---
echo "Running linuxdeploy to bundle dependencies..."
# Note: --icon and --desktop-file are now optional with recent linuxdeploy versions
# It will find the .desktop file automatically because our `make install` step
# has already placed it in the correct directory ($APP_DIR/usr/share/applications).

# Run the tool
./linuxdeploy-x86_64.AppImage --appdir "$APP_DIR" --output appimage

echo "---------------------------------------------------------"
echo "AppImage build complete!"
echo "Find the result in the CUDABurner directory."
echo "---------------------------------------------------------"
