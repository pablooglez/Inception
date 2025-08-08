# ===============================
# DOCKERFILE FOR MARIADB
# ===============================
# MariaDB database configuration for WordPress
# Based on Alpine Linux to keep the image lightweight

# Base operating system: Alpine Linux (lightweight distribution)
FROM alpine:3.16

# ===============================
# MARIADB INSTALLATION
# ===============================
# Update package index and install MariaDB with its client
# --no-cache avoids storing temporary files, keeping the image small
RUN apk update && apk add --no-cache mariadb mariadb-client

# ===============================
# DIRECTORY AND PERMISSIONS CONFIGURATION
# ===============================
# Create MySQL socket directory and assign correct permissions
# The socket is necessary for local connections to MariaDB
# chown assigns directory ownership to the 'mysql' user
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# ===============================
# MARIADB CONFIGURATION
# ===============================
# Create custom configuration directory if it doesn't exist
# Write Docker custom configuration to docker.cnf file
# This configuration allows connections from other containers:
# - skip-host-cache: improves performance by omitting DNS cache
# - skip-name-resolve: improves security by omitting reverse DNS resolution  
# - bind-address=0.0.0.0: allows connections from any IP
RUN mkdir -p /etc/my.cnf.d && echo '[mysqld]\nskip-host-cache\nskip-name-resolve\nbind-address=0.0.0.0' > /etc/my.cnf.d/docker.cnf

# ===============================
# NETWORK CONFIGURATION
# ===============================
# Disable skip-networking to allow remote TCP/IP connections
# skip-networking would force only local connections via Unix socket
# We need TCP/IP connections so WordPress (in another container) can connect
# sed finds and comments the skip-networking line in server configuration
RUN sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf

# ===============================
# DATABASE INITIALIZATION
# ===============================
# Initialize new MariaDB database by creating files and system tables
# mysql_install_db creates basic structure and default tables
# --user=mysql ensures all files are owned by mysql user
# --datadir specifies where to store data (/var/lib/mysql is standard location)
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# ===============================
# PORT EXPOSURE AND CONFIGURATION FILES
# ===============================
# Inform Docker that container will listen on port 3306 (MySQL standard port)
EXPOSE 3306

# Copy database configuration script from local directory
# This script will create WordPress database and configure users
COPY conf/db.sh .

# Make the script executable
RUN chmod +x db.sh

# ===============================
# USER CONFIGURATION AND STARTUP COMMAND
# ===============================
# Switch to mysql user for security (don't run as root)
USER mysql

# Command executed when starting container:
# 1. Execute database configuration script (db.sh)
# 2. Start MySQL server in foreground without error logs
CMD ["sh", "-c", "./db.sh && exec /usr/bin/mysqld --skip-log-error"]