FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y openssh-server wget sudo curl apt-utils libterm-readline-perl-perl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install yq (YAML processor)
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Enable root SSH login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create SSH runtime directory
RUN mkdir /var/run/sshd

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
