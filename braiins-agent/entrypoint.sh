#!/bin/bash

# Parse options from HA add-on config (/data/options.json)
ROOT_PASSWORD=$(jq -r '.root_password // "root"' /data/options.json)
AGENT_ID=$(jq -r '.agent_id // empty' /data/options.json)
SECRET_KEY=$(jq -r '.secret_key // empty' /data/options.json)
AGENT_VERSION=$(jq -r '.agent_version // "4.5.2"' /data/options.json)

# Install the agent at runtime using the configured version
apt-get update
wget https://downloads.braiins.com/braiins-manager-agent/assets/${AGENT_VERSION}/braiins-manager-agent-linux-aarch64.deb -O /tmp/braiins-manager-agent.deb

# Preseed debconf with dummy values for non-interactive install
echo "braiins-manager-agent braiins-manager-agent/agent-id string 123e4567-e89b-42d3-a456-426655440000" | debconf-set-selections
echo "braiins-manager-agent braiins-manager-agent/secret-key password 123e4567-e89b-42d3-a456-426655440001" | debconf-set-selections

# Install the agent non-interactively
DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/braiins-manager-agent.deb

# Clean up
rm /tmp/braiins-manager-agent.deb

# Set root password (defaults to original if not provided)
echo "root:$ROOT_PASSWORD" | chpasswd

# Create directory and empty file if missing
mkdir -p /etc/braiins-manager-agent
if [ ! -f /etc/braiins-manager-agent/daemon.yml ]; then
  touch /etc/braiins-manager-agent/daemon.yml
fi

# Update agent config if ID and key are provided (assumes top-level YAML keys in daemon.yml)
if [ -n "$AGENT_ID" ] && [ -n "$SECRET_KEY" ]; then
    yq e -i ".agent_id = \"$AGENT_ID\"" /etc/braiins-manager-agent/daemon.yml
    yq e -i ".secret_key = \"$SECRET_KEY\"" /etc/braiins-manager-agent/daemon.yml
fi

# Start the agent in background
nohup /usr/bin/bma-daemon --config /etc/braiins-manager-agent/daemon.yml > /var/log/braiins-agent.log 2>&1 &

# Start SSH server
exec /usr/sbin/sshd -D
