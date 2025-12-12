FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget unzip xz-utils \
    tigervnc-standalone-server \
    websockify \
    xfce4 \
    xserver-xorg-video-dummy \
    xserver-xorg-input-void \
    xserver-xorg-core \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Download Android-x86 image
RUN mkdir -p /opt/android
WORKDIR /opt/android
RUN wget -O android.img "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.img"

# Dummy Xorg config
RUN mkdir -p /etc/X11/xorg.conf.d
COPY dummy.conf /etc/X11/xorg.conf.d/dummy.conf

# Supervisor config (start VNC + websockify)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port untuk Clever Cloud
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
