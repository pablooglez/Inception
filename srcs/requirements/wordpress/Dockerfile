# ===============================
# DOCKERFILE FOR WORDPRESS
# ===============================
# WordPress configuration with PHP-FPM to serve dynamic content
# Based on Alpine Linux to keep the image lightweight

# Base operating system: Alpine Linux (latest stable version)
FROM alpine:3.18

# ===============================
# BUILD ARGUMENTS
# ===============================
# Variables passed during image build
ARG PHP_VERSION=82                      # PHP version to install (8.2)

# Database configuration variables
ARG DB_NAME                             # Database name
ARG DB_USER                             # Database user
ARG DB_PASS                             # Database password

# WordPress configuration variables
ARG DOMAIN_NAME                         # Domain name (e.g: user.42.fr)
ARG WP_USER                             # WordPress administrator user
ARG WP_PASS                             # Administrator password

# ===============================
# CONVERT ARGUMENTS TO ENVIRONMENT VARIABLES
# ===============================
# Convert arguments to environment variables for runtime availability
# Needed by configuration scripts that run when container starts
ENV DB_NAME=$DB_NAME \
    DB_USER=$DB_USER \
    DB_PASS=$DB_PASS \
    DOMAIN_NAME=$DOMAIN_NAME \
    WP_USER=$WP_USER \
    WP_PASS=$WP_PASS

# ===============================
# PHP AND TOOLS INSTALLATION
# ===============================
# Install PHP-FPM and all extensions needed for WordPress:
# - php-fpm: FastCGI Process Manager for serving PHP
# - php-mysqli: extension to connect with MariaDB/MySQL
# - php-json, php-curl, php-dom, etc.: extensions required by WordPress
# Also install download tools and MySQL client
# Everything in single layer to optimize image size
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-phar \
    php${PHP_VERSION}-mysqli php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl php${PHP_VERSION}-dom php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl php${PHP_VERSION}-xml php${PHP_VERSION}-zip \
    php${PHP_VERSION}-redis wget unzip mysql-client && rm -rf /var/cache/apk/*

# ===============================
# WP-CLI INSTALLATION
# ===============================
# WP-CLI is a command line tool for managing WordPress
# Allows automating installation, configuration and management of WordPress sites
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# ===============================
# PHP CONFIGURATION
# ===============================
# Create symbolic link so 'php' points to specific installed version
# This allows using generic 'php' commands in scripts
RUN ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# Verify PHP installed correctly
RUN php -v

# ===============================
# PHP-FPM CONFIGURATION
# ===============================
# Modify PHP-FPM configuration to work in containers:
# - Change listen from 127.0.0.1:9000 to 9000 (listen on all interfaces)
# - Enable listen.owner and listen.group for correct permissions
# This allows Nginx (in another container) to connect to PHP-FPM
RUN sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|ig" /etc/php${PHP_VERSION}/php-fpm.d/www.conf

# ===============================
# WORDPRESS DOWNLOAD AND INSTALLATION
# ===============================
# Set working directory where WordPress files will reside
WORKDIR /var/www/html

# Download WordPress, unzip and move files to working directory:
# 1. Download specific WordPress version (6.5.2)
# 2. Unzip the ZIP file
# 3. Copy content to current directory (/var/www/html)
# 4. Clean temporary files to keep image lightweight
RUN wget -O wordpress.zip https://wordpress.org/wordpress-6.5.2.zip && \
    unzip wordpress.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress wordpress.zip

# ===============================
# WORDPRESS CONFIGURATION
# ===============================
# Copy script that will generate wp-config.php file
# This file contains database connection configuration
COPY conf/wp-config.sh .

# Execute configuration script, remove it afterwards (security) 
# and give full permissions to wp-content directory (needed by WordPress)
RUN sh wp-config.sh && rm wp-config.sh && chmod -R 0777 wp-content/

# ===============================
# INITIALIZATION SCRIPT AND FINAL COMMAND
# ===============================
# Copy script that will automate complete WordPress installation
COPY conf/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

# Port the container will expose (PHP-FPM listens on 9000)
EXPOSE 9000

# Container startup command:
# 1. Execute WordPress configuration script (wp-setup.sh)
# 2. Start PHP-FPM in foreground (-F) to keep container active
CMD ["sh", "-c", "/usr/local/bin/wp-setup.sh && exec /usr/sbin/php-fpm82 -F"]