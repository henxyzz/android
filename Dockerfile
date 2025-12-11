FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  xfce4 xfce4-goodies \
  x11vnc xvfb \
  novnc websockify \
  wget curl nano sudo \
  && apt-get clean

RUN x11vnc -storepasswd "" /etc/x11vnc.pass

RUN mkdir -p /opt/novnc \
 && cp -r /usr/share/novnc/* /opt/novnc/ \
 && cp -r /usr/share/novnc/utils/* /opt/novnc/utils/

RUN echo '<meta http-equiv="refresh" content="0; url=vnc.html">' > /opt/novnc/index.html

EXPOSE 8080

CMD \
  rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 ; \
  export DISPLAY=:1 ; \
  echo "Starting Xvfb..." ; \
  Xvfb :1 -screen 0 1280x720x24 & \
  sleep 4 ; \
  echo "Starting XFCE..." ; \
  startxfce4 & \
  sleep 4 ; \
  echo "Starting x11vnc..." ; \
  x11vnc -display :1 -nopw -forever -shared -rfbport 5901 -bg ; \
  sleep 2 ; \
  echo "Starting noVNC..." ; \
  websockify --web=/opt/novnc 8080 localhost:5901
