FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    xrdp \
    novnc websockify \
    git curl wget sudo \
    && apt-get clean

# Enable XRDP
RUN sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config
RUN systemctl enable xrdp

# Setup noVNC
RUN mkdir -p /opt/novnc && \
    cp -r /usr/share/novnc/* /opt/novnc/ && \
    cp -r /usr/share/novnc/utils/websockify /opt/novnc/

EXPOSE 8080

# Start script
CMD /etc/init.d/xrdp start && \
    /opt/novnc/utils/launch.sh --vnc localhost:5901 --listen 8080
