FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    qemu-system-x86 \
    qemu-kvm \
    ovmf \
    novnc \
    python3 python3-pip \
    tigervnc-standalone-server \
    supervisor wget curl \
    && rm -rf /var/lib/apt/lists/*

# Install websockify via pip (FIX)
RUN pip3 install websockify

# noVNC
RUN mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz \
    | tar xz --strip 1 -C /opt/novnc

# Supervisor
RUN mkdir -p /etc/supervisor/conf.d && \
cat << 'EOF' > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:qemu]
command=qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 \
    -drive file=/os/windows.qcow2,format=qcow2,if=virtio \
    -vga qxl \
    -display vnc=:0 \
    -net nic -net user
autostart=true
autorestart=true

[program:websockify]
command=/usr/local/bin/websockify 8080 localhost:5900 --web=/opt/novnc/
autostart=true
autorestart=true
EOF

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
