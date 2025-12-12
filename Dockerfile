FROM node:18-bullseye

# Update & install SSH server
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd

# Set user & password
RUN useradd -m admin && echo "admin:admin123" | chpasswd

# Allow password auth
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install webssh2
RUN git clone https://github.com/billchurch/WebSSH2.git /app
WORKDIR /app
RUN npm install

# Config WebSSH2 to connect LOCAL SSH
COPY config.json /app/config/

# EXPOSE clevercloud port
ENV PORT=8080

CMD service ssh start && \
    npm start
