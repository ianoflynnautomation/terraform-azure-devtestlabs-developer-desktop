#!/bin/bash

# Fetch the latest version number from JetBrains' data feed
LATEST_VERSION_URL="https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release"
echo "Fetching latest version information from JetBrains..."
DOWNLOAD_URL=$(curl -sL $LATEST_VERSION_URL | grep -oP '"linux":{[^}]+"link":"\K[^"]+')

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Could not determine the download URL for IntelliJ IDEA. Exiting."
    exit 1
fi

INSTALL_DIR="/opt"
DOWNLOAD_PATH="/tmp/ideaIC.tar.gz"

echo "Downloading IntelliJ IDEA Community from: $DOWNLOAD_URL"
curl -L -o "$DOWNLOAD_PATH" "$DOWNLOAD_URL"

echo "Download complete. Extracting to $INSTALL_DIR..."
# Extract the tarball to the installation directory
tar -xzf "$DOWNLOAD_PATH" -C "$INSTALL_DIR"

# Clean up the downloaded file
rm "$DOWNLOAD_PATH"

# Find the extracted directory name (e.g., idea-IC-223.8214.52)
IDEA_DIR=$(find "$INSTALL_DIR" -maxdepth 1 -type d -name "idea-IC-*" | head -n 1)

if [ -d "$IDEA_DIR" ]; then
    # Create a symbolic link to the executable
    ln -s "$IDEA_DIR/bin/idea.sh" /usr/local/bin/idea
    echo "Installation complete. You can now run 'idea' from the terminal."
else
    echo "Could not find the extracted IntelliJ directory. Symlink not created."
fi

echo "IntelliJ IDEA artifact finished."