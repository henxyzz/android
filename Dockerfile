FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=android
ENV HOME=/home/android
WORKDIR /home/android

# ===============================
# Install deps
# ===============================
RUN apt update && apt install -y \
  xfce4 xfce4-goodies \
  x11vnc xvfb \
  novnc websockify \
  qemu-system-x86 qemu-utils \
  wget curl sudo \
  openjdk-11-jdk \
  && apt clean

# ===============================
# User
# ===============================
RUN useradd -m android && echo "android ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER android

# ===============================
# Download Android-x86
# ===============================
RUN wget -O android.iso https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download

# Create disk
RUN qemu-img create -f qcow2 android.img 8G

# ===============================
# Startup script
# ===============================
RUN cat << 'EOF' > start.sh
#!/bin/bash
set -e

export DISPLAY=:0

# Virtual display
Xvfb :0 -screen 0 1280x720x24 &

# Desktop
startxfce4 &

# Android via QEMU (VNC on :1 -> port 5901)
qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  -hda android.img \
  -cdrom android.iso \
  -boot d \
  -vga std \
  -net nic -net user \
  -display none \
  -vnc :1 &

# VNC bridge
x11vnc -display :0 -forever -nopw -rfbport 5901 &

# noVNC (Clever Cloud port)
websockify --web=/usr/share/novnc/ 8080 localhost:5901
EOF

RUN chmod +x start.sh

CMD ["bash", "start.sh"]
