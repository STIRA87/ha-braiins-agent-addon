#!/bin/bash

# Parse options from HA add-on config (/data/options.json)
ROOT_PASSWORD=$(jq -r '.root_password // "root"' /data/options.json)
AGENT_ID=$(jq -r '.agent_id // empty' /data/options.json)
SECRET_KEY=$(jq -r '.secret_key // empty' /data/options.json)
AGENT_VERSION=$(jq -r '.agent_version // "4.6.0"' /data/options.json)

# Set root password (defaults to original if not provided)
echo "root:$ROOT_PASSWORD" | chpasswd

# Check current agent version (if installed)
CURRENT_VERSION=$(dpkg -s braiins-manager-agent 2>/dev/null | grep '^Version:' | cut -d' ' -f2 || echo "none")

# Install or update agent if version doesn't match
if [ "$CURRENT_VERSION" != "$AGENT_VERSION" ]; then
    echo "Installing/updating Braiins Manager Agent to version $AGENT_VERSION..."
    wget "https://downloads.braiins.com/braiins-manager-agent/assets/${AGENT_VERSION}/braiins-manager-agent-linux-aarch64.deb" -O /tmp/braiins-manager-agent.deb
    
    # Preseed debconf with dummies for non-interactive install
    echo "braiins-manager-agent braiins-manager-agent/agent-id string 123e4567-e89b-42d3-a456-426655440000" | debconf-set-selections
    echo "braiins-manager-agent braiins-manager-agent/secret-key password 123e4567-e89b-42d3-a456-426655440001" | debconf-set-selections
    
    DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/braiins-manager-agent.deb || apt-get install -f -y
    rm -f /tmp/braiins-manager-agent.deb
fi

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
