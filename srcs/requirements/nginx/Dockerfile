# OS base image
FROM debian:bullseye

# Install nginx package, plus openssl and ca-certificates so we can read/use our .crt and .key
RUN apt-get update && apt-get install -y nginx openssl

# Set nginx configuration by copying our own .conf file in default configuration directory
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Generate ssl certificate and key
RUN openssl req -subj "/C=SP/ST=Malaga/L=Malaga/O=42 Malaga/OU=pablogon/CN=pablogon.42.fr" \
    -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/nginx/ssl/pablogon.42.fr.key -out /etc/nginx/ssl/pablogon.42.fr.crt

# Create a basic index.html in the index directory used by our config, so we can test if the server is working properly
# We will change this later, when wordpress is set and working
RUN touch /var/www/html/index.html && echo "<h1>Nginx is working!</h1>" > /var/www/html/index.html

EXPOSE 443

# CMD to be executed when docker-compose, to run nginx without daemon "mode"
CMD ["nginx", "-g", "daemon off;"]