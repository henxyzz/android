FROM ubuntu:22.04

# Update dan install SSH + Nginx
RUN apt-get update && apt-get install -y \
    openssh-server \
    nginx \
    && mkdir /var/run/sshd

# Buat user SSH
RUN useradd -m admin && echo "admin:admin123" | chpasswd

# Enable password login
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Konfigurasi reverse proxy SIMPLE (tanpa proxy_protocol)
RUN rm /etc/nginx/sites-enabled/default
RUN echo 'server { \
    listen 8080; \
    location / { \
        proxy_pass http://127.0.0.1:22; \
    } \
}' > /etc/nginx/sites-enabled/ssh-proxy.conf

EXPOSE 8080

CMD service ssh start && nginx -g "daemon off;"
