FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    qemu-system-x86 \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    wget \
    unzip \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Download Android-x86 automatically
RUN mkdir -p /android && \
    wget -O /android/android.iso \
    "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso"

# Expose NoVNC port
EXPOSE 8080

# Auto-clear logs + start everything
CMD bash -c "\
    echo '[INFO] Clearing old logs...' && \
    rm -rf /var/log/* && \
    mkdir -p /var/log && \
    \
    echo '[INFO] Starting Xvfb...' && \
    Xvfb :0 -screen 0 1280x720x16 & \
    sleep 2 && \
    \
    echo '[INFO] Starting QEMU Android-x86...' && \
    qemu-system-x86_64 \
        -m 2048 \
        -smp 2 \
        -cdrom /android/android.iso \
        -boot d \
        -vga virtio \
        -display vnc=:1 \
        -enable-kvm \
        -nic user,model=virtio-net-pci \
        -serial mon:stdio \
        & \
    sleep 3 && \
    \
    echo '[INFO] Starting NoVNC on port 8080...' && \
    websockify --web=/usr/share/novnc/ 8080 localhost:5901 \
"
