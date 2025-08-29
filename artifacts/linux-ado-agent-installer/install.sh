#!/bin/bash

# Parameters
ADO_URL=$1
ADO_PAT=$2
ADO_POOL=$3
AGENT_NAME=$4
AGENT_PATH=$5

# Get latest agent version
AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')
AGENT_URL="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"

echo "Installing dependencies..."
sudo apt-get install -y curl jq

echo "Creating agent directory at $AGENT_PATH..."
sudo mkdir -p "$AGENT_PATH" && cd "$AGENT_PATH"

echo "Downloading ADO Agent v$AGENT_VERSION..."
sudo curl -O "$AGENT_URL"
sudo tar zxvf "vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"

echo "Configuring agent..."
sudo chown -R $USER:$USER "$AGENT_PATH"
./config.sh --unattended --url "$ADO_URL" --auth pat --token "$ADO_PAT" --pool "$ADO_POOL" --agent "$AGENT_NAME" --acceptTeeEula --work "_work" --runAsService

echo "Installing and starting service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "Agent installation complete."