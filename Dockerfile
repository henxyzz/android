# ===============================
# Dockerfile: RDP + ngrok + status HTML
# ===============================

# Gunakan base image Linux
FROM ubuntu:22.04

# Set build non-interaktif
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=id_ID.UTF-8
ENV LANGUAGE=id_ID:en
ENV LC_ALL=id_ID.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip xrdp sudo python3 python3-pip locales keyboard-configuration && \
    # Set keyboard layout Indonesia non-interaktif
    echo "keyboard-configuration keyboard-configuration/layoutcode select id" | debconf-set-selections && \
    echo "keyboard-configuration keyboard-configuration/layout select Indonesian" | debconf-set-selections && \
    # Generate locale
    locale-gen id_ID.UTF-8 && \
    update-locale LANG=id_ID.UTF-8 && \
    apt-get clean

# Buat user baru untuk RDP
RUN useradd -m -s /bin/bash runneradmin && \
    echo "runneradmin:P@ssw0rd!" | chpasswd && \
    adduser runneradmin sudo

# Enable RDP
RUN sed -i 's/^#port=3389/port=3389/' /etc/xrdp/xrdp.ini

# Download & install ngrok
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
    tar -xvzf ngrok.tgz && \
    mv ngrok /usr/local/bin/ && \
    rm ngrok.tgz

# Set environment variable untuk ngrok authtoke
ENV NGROK_AUTH_TOKEN=2ubrky4Md4p0uDATQAURfYRxrzD_44pso4SGhy6q8BfCGvVPF

# Buat folder status HTML
RUN mkdir /status
WORKDIR /status

# Tambahkan contoh index.html
RUN echo "<!DOCTYPE html><html><head><title>Status</title></head><body><h1>Server RDP + ngrok Online</h1></body></html>" > /status/index.html

# Expose port RDP & web status
EXPOSE 3389 8080

# Start xrdp, ngrok tunnel & web server status
CMD service xrdp start && \
    ngrok authtoken $NGROK_AUTH_TOKEN && \
    ngrok tcp 3389 & \
    python3 -m http.server 8080 --directory /status
