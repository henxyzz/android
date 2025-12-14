FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=android
ENV HOME=/home/android

# ===============================
# Install deps (ROOT)
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
# Create user
# ===============================
RUN useradd -m android && \
    echo "android ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ===============================
# Prepare workspace (ROOT)
# ===============================
WORKDIR /home/android
RUN chown -R android:android /home/android

# ===============================
# Download Android-x86 (ROOT)
# ===============================
RUN wget -O /home/android/android.iso \
  https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download

RUN qemu-img create -f qcow2 /home/android/android.img 8G
RUN chown android:android /home/android/android.*

# ===============================
# Switch user
# ===============================
USER android
WORKDIR /home/android

# ===============================
# Startup script
# ===============================
RUN cat << 'EOF' > start.sh
#!/bin/bash
set -e
export DISPLAY=:0

echo "[+] Starting Xvfb"
Xvfb :0 -screen 0 1280x720x24 &
sleep 2

echo "[+] Starting XFCE"
startxfce4 &
sleep 5

echo "[+] Starting QEMU Android"
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
sleep 5

echo "[+] Starting x11vnc"
x11vnc -display :0 -forever -nopw -rfbport 5901 &
sleep 2

echo "[+] Starting noVNC on 8080"
exec websockify --web=/usr/share/novnc/ 8080 localhost:5901
EOF

RUN chmod +x start.sh

CMD ["bash", "start.sh"]
