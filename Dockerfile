FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    xrdp \
    novnc websockify \
    git curl wget sudo \
    && apt-get clean

# Fix: X wrapper allow anyone
RUN sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config

# Prepare noVNC folder
RUN mkdir -p /opt/novnc \
 && cp -r /usr/share/novnc/* /opt/novnc/ \
 && cp -r /usr/share/novnc/utils/* /opt/novnc/utils/

EXPOSE 8080

# Auto clear console + start VNC + noVNC
CMD clear && \
    /usr/sbin/xrdp-sesman && \
    /usr/sbin/xrdp && \
    websockify --web=/opt/novnc 8080 localhost:5901
