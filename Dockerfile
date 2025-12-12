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

# --- Folder untuk noVNC ---
RUN mkdir -p /opt/novnc
RUN cp -r /usr/share/novnc/* /opt/novnc/

# Download Android-x86 ISO
RUN mkdir -p /iso
RUN wget -O /iso/android.iso "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso"

# --- Supervisor config ---
RUN mkdir -p /etc/supervisor/conf.d

# VNC di :1 = port 5901
RUN mkdir -p /root/.vnc
RUN echo password | vncpasswd -f > /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd

# Supervisor program untuk VNC
RUN bash -c 'cat > /etc/supervisor/conf.d/vnc.conf << EOF
[program:vnc]
command=/usr/bin/vncserver :1 -geometry 1280x720 -depth 24
autostart=true
autorestart=true
EOF'

# Supervisor untuk websockify (VNC → WebSocket)
RUN bash -c 'cat > /etc/supervisor/conf.d/websockify.conf << EOF
[program:websockify]
command=/usr/bin/websockify --web=/opt/novnc 8080 localhost:5901
autostart=true
autorestart=true
EOF'

# Supervisor untuk Android-x86 QEMU
RUN bash -c 'cat > /etc/supervisor/conf.d/android.conf << EOF
[program:android]
command=qemu-system-x86_64 -cdrom /iso/android.iso -m 2048 -smp 2 -vnc :1 -enable-kvm
autostart=true
autorestart=true
EOF'

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
