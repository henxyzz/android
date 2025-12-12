FROM ubuntu:22.04

# Update dan install SSH
RUN apt-get update && apt-get install -y \
    openssh-server \
    nginx \
    && mkdir /var/run/sshd

# Set password user (user: admin, pass: admin123)
RUN useradd -m admin && echo "admin:admin123" | chpasswd

# Allow SSH login password
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Nginx sebagai reverse proxy → port 8080 -> 22
RUN rm /etc/nginx/sites-enabled/default
RUN echo 'server { \
    listen 8080; \
    location / { \
        proxy_pass http://127.0.0.1:22; \
        proxy_protocol off; \
    } \
}' > /etc/nginx/sites-enabled/ssh-proxy.conf

EXPOSE 8080

CMD service ssh start && nginx -g "daemon off;"
