FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    qemu-kvm qemu-system-x86 \
    novnc websockify \
    x11vnc xvfb \
    wget curl \
    net-tools \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Download Android-x86 ISO (Android 9.0-r2)
RUN mkdir -p /android && \
    wget -O /android/android.iso \
    "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso"

# Create supervisor config directly from Dockerfile
RUN mkdir -p /etc/supervisor/conf.d && \
    echo "[supervisord]\n\
nodaemon=true\n\
\n\
[program:qemu]\n\
command=qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom /android/android.iso -boot d -vga virtio -display vnc=:1 -device virtio-mouse-pci -device virtio-keyboard-pci -nic user,model=virtio-net-pci\n\
autostart=true\n\
autorestart=true\n\
\n\
[program:websockify]\n\
command=websockify 8080 localhost:5901 --web=/usr/share/novnc/\n\
autostart=true\n\
autorestart=true" \
    > /etc/supervisor/conf.d/supervisord.conf

# Expose NoVNC port
EXPOSE 8080

# Run supervisor
CMD ["/usr/bin/supervisord"]
