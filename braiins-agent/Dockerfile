FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y openssh-server wget sudo curl

RUN echo "root:mJpMpBdjbxRnGuh4FcbD" | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

CMD ["/usr/sbin/sshd", "-D"]
