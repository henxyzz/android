FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update & install kebutuhan
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    nodejs \
    npm \
 && mkdir /var/run/sshd

# Set ROOT password
RUN echo "root:root123" | chpasswd

# User admin (opsional, tapi enak buat backup)
RUN useradd -m admin && \
    echo "admin:admin123" | chpasswd && \
    usermod -aG sudo admin && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable root + password login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config

# Install WebSSH2
RUN git clone https://github.com/billchurch/WebSSH2.git /app
WORKDIR /app
RUN npm install

# Config WebSSH2
COPY config.json /app/config/

# Clever Cloud port
ENV PORT=8080

# Start SSH + WebSSH2
CMD service ssh start && npm start
