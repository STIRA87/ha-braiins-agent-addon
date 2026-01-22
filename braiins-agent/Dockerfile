FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y openssh-server wget sudo curl apt-utils libterm-readline-perl-perl jq

# Download yq for YAML editing (aarch64 binary)
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Download Braiins Manager Agent .deb (v4.5.2 for aarch64)
RUN wget https://downloads.braiins.com/braiins-manager-agent/assets/4.5.2/braiins-manager-agent-linux-aarch64.deb -O /braiins-manager-agent.deb

# Preseed debconf with dummy values for non-interactive install
RUN echo "braiins-manager-agent braiins-manager-agent/agent-id string 74bc017c-a964-41e1-b808-f51092e9ac90" | debconf-set-selections
RUN echo "braiins-manager-agent braiins-manager-agent/secret-key password d73d2498-d3cb-4c18-8bcd-4360711fb1ea" | debconf-set-selections

# Install the agent non-interactively
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y /braiins-manager-agent.deb

# Clean up
RUN rm /braiins-manager-agent.deb

# Enable root SSH login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

# Copy and set entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
