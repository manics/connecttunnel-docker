FROM ubuntu:20.04
LABEL maintainer "https://github.com/manics/connecttunnel-docker"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update; apt-get install -y kmod net-tools openjdk-8-jdk dante-server

COPY ConnectTunnel-Linux64.tar ConnectTunnel-Linux64.tar
# Disable check for /dev/tun during installation
RUN tar xf ConnectTunnel-Linux64.tar && \
    sed -i 's/^xg_check_tun/#xg_check_tun/' install.sh && \
    ./install.sh

VOLUME /dev/net
# So that .sonicwall/AventailConnect/config/profiles.xml can be reused
VOLUME /root/.sonicwall

COPY sockd.conf /etc/danted.conf
COPY startct_wrap.sh /usr/local/bin/startct_wrap.sh

ENTRYPOINT ["/usr/local/bin/startct_wrap.sh"]
