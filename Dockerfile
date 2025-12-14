FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    x11vnc xvfb \
    novnc websockify \
    dbus-x11 \
    net-tools nano && \
    apt clean

# Password VNC
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd 1234 /root/.vnc/passwd

# Startup script
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
startxfce4 &\n\
x11vnc -display :1 -rfbauth /root/.vnc/passwd -forever -shared &\n\
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 8080 localhost:5900\n\
' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
