FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop + vnc + qemu
RUN apt update && apt install -y \
  xfce4 xfce4-goodies \
  tightvncserver \
  novnc websockify \
  wget curl sudo \
  qemu-system-x86 \
  openjdk-11-jdk \
  && apt clean

# User
RUN useradd -m android && echo "android:android" | chpasswd && adduser android sudo
USER android
WORKDIR /home/android

# Download Android-x86 ISO
RUN wget -O android.iso https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download

# Create virtual disk
RUN qemu-img create -f qcow2 android.img 8G

# VNC setup
RUN mkdir ~/.vnc && echo "android" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

# Startup
CMD vncserver :0 -geometry 1280x720 -depth 24 && \
    qemu-system-x86_64 \
      -m 2048 \
      -smp 2 \
      -hda android.img \
      -cdrom android.iso \
      -boot d \
      -vga std \
      -net nic -net user \
      -display none \
      -vnc :1 & \
    websockify --web=/usr/share/novnc/ 8080 localhost:5901
