#!/bin/bash

INSTALL_DIR="/opt"
DOWNLOAD_PATH="/tmp/vscode.tar.gz"
DOWNLOAD_URL="https://update.code.visualstudio.com/latest/linux-x64/stable"

echo "Downloading Visual Studio Code for Linux..."
curl -L -o "$DOWNLOAD_PATH" "$DOWNLOAD_URL"

echo "Download complete. Extracting to $INSTALL_DIR..."
# The --strip-components=1 flag removes the top-level folder from the archive
mkdir -p "$INSTALL_DIR/vscode"
tar -xzf "$DOWNLOAD_PATH" -C "$INSTALL_DIR/vscode" --strip-components=1

# Clean up the downloaded file
rm "$DOWNLOAD_PATH"

# Create a symbolic link to the executable
ln -s "$INSTALL_DIR/vscode/bin/code" /usr/local/bin/code

echo "Installation complete. You can now run 'code' from the terminal."
echo "Visual Studio Code artifact finished."