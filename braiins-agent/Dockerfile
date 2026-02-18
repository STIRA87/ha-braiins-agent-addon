FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y openssh-server wget sudo curl apt-utils libterm-readline-perl-perl jq

# Download yq for YAML editing (aarch64 binary)
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Enable root SSH login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

# Copy and set entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
