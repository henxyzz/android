FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_ISO_URL="https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso?ts=gAAAAABpPAuNjuGidDLlf7WWj3MWbj8uBC8PO9PV8KYwvjzWnyk8YhGqELoilVjJohR58bw0bTqQ2jnB41N0W6akq3MQosvi6w%3D%3D&use_mirror=twds"
ENV DISPLAY=:0

# Install deps
RUN apt-get update && apt-get install -y \
    wget unzip xz-utils \
    tigervnc-standalone-server websockify \
    supervisor \
    xfce4 \
    xserver-xorg-core xserver-xorg-video-dummy xserver-xorg-input-all \
 && rm -rf /var/lib/apt/lists/*

# Download Android-x86 ISO
WORKDIR /opt
RUN wget -O /opt/android-x86.iso "$ANDROID_ISO_URL"

# Create Xorg dummy configuration
RUN mkdir -p /etc/X11/xorg.conf.d
RUN echo 'Section "Device"\n\
    Identifier "Configured Video Device"\n\
    Driver     "dummy"\n\
EndSection\n\
Section "Monitor"\n\
    Identifier "Configured Monitor"\n\
    HorizSync   31.5-48.5\n\
    VertRefresh 50-70\n\
EndSection\n\
Section "Screen"\n\
    Identifier "Default Screen"\n\
    Monitor    "Configured Monitor"\n\
    Device     "Configured Video Device"\n\
    DefaultDepth 24\n\
    SubSection "Display"\n\
        Depth 24\n\
        Virtual 1280 720\n\
    EndSubSection\n\
EndSection' > /etc/X11/xorg.conf.d/10-dummy.conf

# Supervisor config
RUN mkdir -p /etc/supervisor/conf.d
RUN echo "[supervisord]\nnodaemon=true\n\
[program:xorg]\ncommand=/usr/bin/Xorg :0 -config /etc/X11/xorg.conf.d/10-dummy.conf\n\
[program:vnc]\ncommand=/usr/bin/tigervncserver :0 -geometry 1280x720 -localhost no\n\
[program:websockify]\ncommand=/usr/bin/websockify --web=/usr/share/novnc/ 8080 localhost:5900\n" > /etc/supervisor/conf.d/supervisord.conf

# Expose web port
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
