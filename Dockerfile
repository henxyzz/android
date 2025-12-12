FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/root/android
ENV ANDROID_SDK_ROOT=/root/android
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    unzip \
    xfce4 \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    libvirt-daemon-system \
    qemu-kvm \
    && apt-get clean

# CMDLINE Tools
RUN mkdir -p /root/android/cmdline-tools && \
    cd /root/android/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-*.zip && \
    mv cmdline-tools tools

ENV PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Install SDK components
RUN yes | sdkmanager --sdk_root=/root/android \
    "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "system-images;android-33;google_apis_playstore;x86_64"

# Create AVD
RUN echo "no" | avdmanager create avd \
    --name devAvd \
    --package "system-images;android-33;google_apis_playstore;x86_64"

# Expose VNC over 8080
EXPOSE 8080

# Start script
RUN echo '#!/bin/bash\n\
Xvfb :0 -screen 0 1280x720x16 &\n\
x11vnc -display :0 -forever -nopw -shared &\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900 &\n\
adb start-server\n\
emulator -avd devAvd -no-snapshot -gpu swiftshader_indirect -no-boot-anim -noaudio -verbose\n\
' > /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
