FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    qemu-system-x86 \
    qemu-kvm \
    ovmf \
    novnc websockify \
    tigervnc-standalone-server \
    supervisor wget curl \
    && rm -rf /var/lib/apt/lists/*

# Folder OS
RUN mkdir -p /os/

# Install noVNC (clean)
RUN mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz \
    | tar xz --strip 1 -C /opt/novnc

# Supervisor
RUN mkdir -p /etc/supervisor/conf.d && \
echo "[supervisord]
nodaemon=true

[program:qemu]
command=qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS.fd \
    -drive file=/os/windows.qcow2,format=qcow2,if=virtio \
    -vga qxl \
    -display vnc=:0 \
    -net nic,model=virtio -net user
autostart=true
autorestart=true

[program:websockify]
command=websockify 8080 localhost:5900 --web=/opt/novnc/
autostart=true
autorestart=true
" > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080
CMD ["/usr/bin/supervisord"]
