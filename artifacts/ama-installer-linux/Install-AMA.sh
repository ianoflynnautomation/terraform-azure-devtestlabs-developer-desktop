#!/bin/bash

echo "Downloading the Azure Monitor Agent installation script..."
wget -O AMAInstall.sh https://aka.ms/AMA-Linux-Installer-Script

# Make the script executable
chmod +x AMAInstall.sh

echo "Installing the Azure Monitor Agent..."
# The script handles the installation of the agent and its dependencies.
./AMAInstall.sh

echo "Azure Monitor Agent installation complete."
rm AMAInstall.sh