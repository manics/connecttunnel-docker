FROM jupyter/base-notebook:ecabcb829fe0
# Based on ubuntu:20.04
# https://github.com/jupyter/docker-stacks/tree/ecabcb829fe048d23daae8fef5f42bff8d5fd4d5/base-notebook

LABEL maintainer "https://github.com/manics/connecttunnel-docker"

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    kmod \
    net-tools \
    openjdk-8-jdk \
    dante-server \
    dbus-x11

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


# https://github.com/jupyterhub/jupyter-remote-desktop-proxy/blob/f4061a68372161e6036e6c9924f9bbccc8373efe/Dockerfile

RUN apt-get -y update \
 && apt-get install -y \
    firefox \
    git \
    sudo \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme

# Remove light-locker to prevent screen lock
RUN wget 'https://sourceforge.net/projects/turbovnc/files/2.2.5/turbovnc_2.2.5_amd64.deb/download' -O turbovnc_2.2.5_amd64.deb && \
   apt-get install -y -q ./turbovnc_2.2.5_amd64.deb && \
   apt-get remove -y -q light-locker && \
   rm ./turbovnc_2.2.5_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# apt-get may result in root-owned directories/files under $HOME
RUN chown -R $NB_UID:$NB_GID $HOME
RUN echo 'jovyan ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jovyan

USER $NB_USER
COPY environment.yml .
RUN conda env update -n base --file environment.yml

# To start Connect Tunnel run:
# sudo /usr/local/bin/startct_wrap.sh
