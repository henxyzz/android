FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    qemu-system-x86 \
    ovmf \
    novnc \
    python3 python3-pip \
    tigervnc-standalone-server \
    supervisor wget curl \
    && rm -rf /var/lib/apt/lists/*

# Install websockify
RUN pip3 install websockify

# Setup noVNC
RUN mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz \
        | tar xz --strip 1 -C /opt/novnc

# Dummy disk supaya QEMU selalu hidup
RUN mkdir -p /os && qemu-img create -f qcow2 /os/dummy.qcow2 1G

# Supervisor
RUN mkdir -p /etc/supervisor/conf.d && \
cat << 'EOF' > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:qemu]
command=qemu-system-x86_64 \
    -m 1024 -smp 2 \
    -drive file=/os/dummy.qcow2,format=qcow2 \
    -vga std \
    -bios /usr/share/OVMF/OVMF_CODE.fd \
    -display vnc=:0 \
    -net nic -net user
autostart=true
autorestart=true

[program:websockify]
command=websockify 8080 localhost:5900 --web=/opt/novnc/
autostart=true
autorestart=true
EOF

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
