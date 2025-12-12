#!/bin/bash

# Start VNC
tigervncserver :1 -geometry 1280x720 -depth 24

# Start noVNC
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 8080 &

# Start Android emulator
emulator -avd devAvd -no-audio -no-snapshot -gpu swiftshader_indirect
