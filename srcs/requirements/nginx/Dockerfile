# ===============================
# DOCKERFILE FOR NGINX
# ===============================
# Nginx web server configuration with SSL to serve WordPress
# Acts as reverse proxy between client and PHP-FPM

# Base operating system: Debian Bullseye (stable with updated packages)
FROM debian:bullseye

# ===============================
# PACKAGE INSTALLATION
# ===============================
# Install Nginx and SSL tools:
# - nginx: web server and reverse proxy
# - openssl: to generate self-signed SSL certificates
# - ca-certificates: certificate authority certificates
RUN apt-get update && apt-get install -y nginx openssl

# ===============================
# NGINX CONFIGURATION
# ===============================
# Copy custom Nginx configuration from local directory
# Replaces default configuration with our WordPress-specific configuration
COPY conf/nginx.conf /etc/nginx/sites-available/default

# ===============================
# SSL CONFIGURATION
# ===============================
# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate and private key:
# -subj: certificate information (Country, State, City, Organization, etc.)
# -new -newkey rsa:2048: create new RSA key with 2048 bits
# -days 365: valid for 1 year
# -nodes: no password for private key
# -x509: generate self-signed certificate
# Generated files: pablogon.42.fr.crt (certificate) and pablogon.42.fr.key (private key)
RUN openssl req -subj "/C=SP/ST=Malaga/L=Malaga/O=42 Malaga/OU=pablogon/CN=pablogon.42.fr" \
    -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/nginx/ssl/pablogon.42.fr.key -out /etc/nginx/ssl/pablogon.42.fr.crt

# ===============================
# TEST PAGE
# ===============================
# Create basic index.html file to verify Nginx is working
# Will be replaced when WordPress is working correctly
RUN touch /var/www/html/index.html && echo "<h1>Nginx is working!</h1>" > /var/www/html/index.html

# ===============================
# PORT EXPOSURE AND STARTUP COMMAND
# ===============================
# Expose port 443 (HTTPS) - only port we'll use per project requirements
EXPOSE 443

# Command to execute when container starts:
# Start Nginx in foreground (daemon off) to keep container active
CMD ["nginx", "-g", "daemon off;"]