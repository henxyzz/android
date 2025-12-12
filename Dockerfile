FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    wget curl unzip git \
    websockify \
    openjdk-11-jdk

# Install noVNC
RUN git clone https://github.com/novnc/noVNC /opt/noVNC \
 && git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify \
 && ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Install Android SDK
RUN mkdir -p /opt/android/cmdline-tools \
 && cd /opt/android/cmdline-tools \
 && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
 && unzip commandlinetools-linux-9477386_latest.zip \
 && mv cmdline-tools tools

ENV ANDROID_HOME=/opt/android
ENV PATH=$PATH:/opt/android/cmdline-tools/tools/bin:/opt/android/platform-tools:/opt/android/emulator

RUN yes | sdkmanager --licenses

RUN sdkmanager "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "system-images;android-33;google_apis_playstore;x86_64"

RUN echo "no" | avdmanager create avd \
    --name devAvd \
    --package "system-images;android-33;google_apis_playstore;x86_64" \
    --device "pixel"

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080 5901

CMD ["/start.sh"]
