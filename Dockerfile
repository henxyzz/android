FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    x11vnc xvfb \
    novnc websockify \
    wget curl nano sudo \
    && apt-get clean

# buat password vnc default (kosong / no pass)
RUN x11vnc -storepasswd "" /etc/x11vnc.pass

# buat folder noVNC
RUN mkdir -p /opt/novnc \
 && cp -r /usr/share/novnc/* /opt/novnc/ \
 && cp -r /usr/share/novnc/utils/* /opt/novnc/utils/

EXPOSE 8080

CMD \
  rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 ; \
  export DISPLAY=:1 ; \
  Xvfb :1 -screen 0 1280x720x24 & \
  sleep 1 && \
  startxfce4 & \
  x11vnc -display :1 -nopw -forever -shared -rfbport 5901 & \
  websockify --web=/opt/novnc 8080 localhost:5901
