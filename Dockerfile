FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV PORT=8080

RUN apt-get update && apt-get install -y \
    wget curl git \
    tigervnc-standalone-server \
    supervisor \
    xfce4 \
    xz-utils \
    xserver-xorg-video-dummy \
    xserver-xorg-core \
    xserver-xorg-input-all \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install websockify terbaru
RUN pip3 install websockify

# Install noVNC from GitHub (versi stabil)
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify

# VNCPASS
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Xorg dummy
RUN mkdir -p /etc/X11/xorg.conf.d
RUN echo 'Section "Device"
  Identifier "dummy"
  Driver "dummy"
EndSection
Section "Monitor"
  Identifier "monitor"
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
command=/usr/local/bin/websockify --web=/opt/novnc ${PORT} localhost:5900
autorestart=true

" > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080
CMD bash -c "echo '➡ noVNC running at: https://${CC_WEBROOT_DOMAIN}' && supervisord -n"
