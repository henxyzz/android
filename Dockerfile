FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    tigervnc-standalone-server \
    xfce4 \
    novnc \
    websockify \
    wget \
    unzip \
    supervisor \
    qemu-system-x86 \
    xz-utils

# noVNC
RUN mkdir -p /opt/novnc && cp -r /usr/share/novnc/* /opt/novnc/

# Download Android-x86
RUN mkdir -p /iso
RUN wget -O /iso/android.iso "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso"

# VNC password
RUN mkdir -p /root/.vnc
RUN echo password | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Supervisor configs
RUN mkdir -p /etc/supervisor/conf.d

# --- VNC ---
RUN echo "[program:vnc]"                   >> /etc/supervisor/conf.d/vnc.conf && \
    echo "command=/usr/bin/vncserver :1 -geometry 1280x720 -depth 24" >> /etc/supervisor/conf.d/vnc.conf && \
    echo "autostart=true"                >> /etc/supervisor/conf.d/vnc.conf && \
    echo "autorestart=true"              >> /etc/supervisor/conf.d/vnc.conf

# --- Websockify / noVNC ---
RUN echo "[program:websockify]"          >> /etc/supervisor/conf.d/websockify.conf && \
    echo "command=/usr/bin/websockify --web=/opt/novnc 8080 localhost:5901" >> /etc/supervisor/conf.d/websockify.conf && \
    echo "autostart=true"                >> /etc/supervisor/conf.d/websockify.conf && \
    echo "autorestart=true"              >> /etc/supervisor/conf.d/websockify.conf

# --- Android-x86 QEMU ---
RUN echo "[program:android]"             >> /etc/supervisor/conf.d/android.conf && \
    echo "command=qemu-system-x86_64 -cdrom /iso/android.iso -m 2048 -smp 2 -vnc :1" >> /etc/supervisor/conf.d/android.conf && \
    echo "autostart=true"                >> /etc/supervisor/conf.d/android.conf && \
    echo "autorestart=true"              >> /etc/supervisor/conf.d/android.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
