FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update + basic tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    openssh-server \
    sudo \
 && mkdir /var/run/sshd

# Install Node.js 22 (INI KUNCI NYA)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Cek versi (buat mental health)
RUN node -v && npm -v

# Set ROOT password
RUN echo "root:root123" | chpasswd

# Optional admin user
RUN useradd -m admin && \
    echo "admin:admin123" | chpasswd && \
    usermod -aG sudo admin && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable root SSH login
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

CMD service ssh start && npm start
