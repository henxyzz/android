FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Update & install dependencies
RUN apt update && apt install -y \
    xfce4 \
    xfce4-goodies \
    wget \
    curl \
    unzip \
    nano \
    git \
    tigervnc-standalone-server \
    tigervnc-common \
    supervisor \
    websockify \
    xvfb \
    x11-apps \
    libglu1-mesa \
    libpulse0 \
    libnss3 \
    libxss1 \
    openjdk-11-jdk

# Install noVNC
RUN git clone https://github.com/novnc/noVNC /opt/noVNC \
    && git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify \
    && ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Install Android SDK
RUN mkdir -p /opt/android/cmdline-tools && \
    cd /opt/android/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    mv cmdline-tools tools

ENV ANDROID_HOME=/opt/android
ENV PATH=$PATH:/opt/android/cmdline-tools/tools/bin:/opt/android/platform-tools:/opt/android/emulator

# Accept licenses
RUN yes | sdkmanager --licenses

# Install Android tools + system image
RUN sdkmanager "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "system-images;android-33;google_apis_playstore;x86_64"

# Create AVD
RUN echo "no" | avdmanager create avd \
    --name devAvd \
    --package "system-images;android-33;google_apis_playstore;x86_64" \
    --device "pixel"

# Supervisor config (start VNC + noVNC + emulator)
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5901
EXPOSE 8080

CMD ["/usr/bin/supervisord"]
