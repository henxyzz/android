FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV PORT=8080

RUN apt-get update && apt-get install -y \
    wget unzip xz-utils \
    tigervnc-standalone-server \
    websockify \
    supervisor \
    xfce4 \
    novnc \
    xserver-xorg-video-dummy \
    xserver-xorg-core \
    xserver-xorg-input-all \
    && rm -rf /var/lib/apt/lists/*

# Create VNC password
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Xorg dummy config
RUN mkdir -p /etc/X11/xorg.conf.d
RUN echo 'Section "Device"
  Identifier "dummy"
  Driver "dummy"
EndSection
Section "Monitor"
  Identifier "monitor"
  HorizSync 30-80
  VertRefresh 50-75
EndSection
Section "Screen"
  Identifier "screen"
  Device "dummy"
  Monitor "monitor"
  SubSection "Display"
    Depth 24
    Virtual 1280 720
  EndSubSection
EndSection' > /etc/X11/xorg.conf.d/10-dummy.conf

# Supervisor config
RUN mkdir -p /etc/supervisor/conf.d
RUN echo "[supervisord]
nodaemon=true

[program:xorg]
command=/usr/bin/Xorg :0 -config /etc/X11/xorg.conf.d/10-dummy.conf
autorestart=true

[program:vnc]
command=/usr/bin/tigervncserver :0 -geometry 1280x720 -localhost no -rfbauth /root/.vnc/passwd
autorestart=true

[program:websockify]
command=/usr/bin/websockify --web=/usr/share/novnc/ ${PORT} localhost:5900
autorestart=true

[program:healthcheck]
command=/bin/bash -c \"echo 'Open ports:' && ss -tulpn\"
startsecs=3
autorestart=false
" > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD bash -c "echo '➡ CleverCloud Android VNC running at: https://${CC_WEBROOT_DOMAIN}/' && supervisord -n"
