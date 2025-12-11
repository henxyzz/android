FROM ubuntu:22.04

# Non-interaktif + locale Indonesia
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=id_ID.UTF-8
ENV LANGUAGE=id_ID:en
ENV LC_ALL=id_ID.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip xrdp sudo python3 python3-pip locales keyboard-configuration openssh-client && \
    echo "keyboard-configuration keyboard-configuration/layoutcode select id" | debconf-set-selections && \
    echo "keyboard-configuration keyboard-configuration/layout select Indonesian" | debconf-set-selections && \
    locale-gen id_ID.UTF-8 && \
    update-locale LANG=id_ID.UTF-8 && \
    apt-get clean

# Buat user baru untuk RDP
RUN useradd -m -s /bin/bash runneradmin && \
    echo "runneradmin:P@ssw0rd!" | chpasswd && \
    adduser runneradmin sudo

# Enable RDP
RUN sed -i 's/^#port=3389/port=3389/' /etc/xrdp/xrdp.ini

# Folder status HTML
RUN mkdir /status
WORKDIR /status
RUN echo "<!DOCTYPE html><html><head><title>Status</title></head><body><h1>Server RDP Online</h1></body></html>" > /status/index.html

# Expose port lokal RDP & status (tidak publik)
EXPOSE 3389 8080

# Script start: RDP, web status, SSH reverse tunnel
CMD service xrdp start && \
    python3 -m http.server 8080 --directory /status & \
    # SSH reverse tunnel (ganti user@vps_ip dan port publik)
    ssh -o StrictHostKeyChecking=no -N -R 50000:localhost:3389 -R 5080:localhost:8080 user@vps_ip
