#!/bin/bash

# Parameters
PACKAGES=$1
UPDATE=$2

echo "Updating package list..."
if [ "$UPDATE" = "true" ]; then
  sudo apt-get update -y
fi

echo "Installing packages: $PACKAGES"
sudo apt-get install -y $PACKAGES

echo "Package installation complete."