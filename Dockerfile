FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update & install dependencies
RUN apt update && apt install -y \
    qemu-kvm qemu-utils \
    novnc websockify python3-websockify \
    wget unzip sudo xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/android-cloud

# Download Android-x86 ISO
RUN wget -O android.iso https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso?ts=gAAAAABpOjs_JoTa-l8dBbHX1edwmfa6KAP7XgczH9L_23VAuOwlou5g8QOUPZp5kFbVkd0_Ij2wPtwFt6xnG3eOCYCJYqqveg%3D%3D&use_mirror=onboardcloud&r=

# Create 8GB disk
RUN qemu-img create -f qcow2 android-disk.qcow2 8G

# Start Android VM
RUN echo '#!/bin/bash\n\
qemu-system-x86_64 \\\n\
  -m 4096 \\\n\
  -smp 4 \\\n\
  -enable-kvm \\\n\
  -cdrom /opt/android-cloud/android.iso \\\n\
  -boot d \\\n\
  -drive file=/opt/android-cloud/android-disk.qcow2,format=qcow2 \\\n\
  -vnc :1 \\\n\
  -device virtio-mouse-pci \\\n\
  -device virtio-keyboard-pci \\\n\
  -device virtio-net-pci,netdev=n0 \\\n\
  -netdev user,id=n0' > /opt/android-cloud/start-android.sh

RUN chmod +x /opt/android-cloud/start-android.sh

# Start noVNC on port 8080
RUN echo '#!/bin/bash\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5901' > /opt/android-cloud/start-novnc.sh

RUN chmod +x /opt/android-cloud/start-novnc.sh

# Expose 8080
EXPOSE 8080

CMD bash -c "/opt/android-cloud/start-android.sh & sleep 3 && /opt/android-cloud/start-novnc.sh"
