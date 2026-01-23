#!/bin/bash

# Parse options from HA add-on config (/data/options.json)
ROOT_PASSWORD=$(jq -r '.root_password // "root"' /data/options.json)
AGENT_ID=$(jq -r '.agent_id // empty' /data/options.json)
SECRET_KEY=$(jq -r '.secret_key // empty' /data/options.json)

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

# Start the agent in background (adjust path/args if needed; assumes binary is in PATH and uses default config)
nohup braiins-manager-agent > /var/log/braiins-agent.log 2>&1 &

# Start SSH server
exec /usr/sbin/sshd -D
