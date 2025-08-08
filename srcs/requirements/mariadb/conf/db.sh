#!/bin/sh

# ===============================
# MARIADB CONFIGURATION SCRIPT
# ===============================
# This script runs the first time the container starts
# Configures database, users and permissions for WordPress

# ===============================
# SYSTEM VERIFICATION AND INITIALIZATION
# ===============================
# Check if MySQL system directory already exists
# /var/lib/mysql/mysql contains MariaDB system tables
if [ ! -d "/var/lib/mysql/mysql" ]; then

	echo "Initializing MariaDB data directory..."
	chown -R mysql:mysql /var/lib/mysql    # Ensure correct permissions

	# Initialize system database with specific configurations:
	# --basedir=/usr: MariaDB base directory
	# --datadir=/var/lib/mysql: directory where data is stored
	# --user=mysql: run as mysql user
	# --rpm: RPM compatibility mode
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

	# Create temporary file for SQL commands
	tfile=$(mktemp)
	if [ ! -f "$tfile" ]; then
		echo "Error: Failed to create temp file."
		exit 1
	fi
fi

# ===============================
# WORDPRESS DATABASE CREATION
# ===============================
# Check if WordPress database already exists
if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
	echo "Creating database and user..."

	# Create SQL script with security configuration and WordPress DB
	cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;

-- Clean insecure default installations
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';

-- Configure root user for local connections only (security)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Set password for root user
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';

-- Create WordPress database with UTF-8 encoding
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Create specific user for WordPress with access from any host
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';

-- Grant all permissions on WordPress DB to user
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	# ===============================
	# EJECUCIÓN DEL SCRIPT SQL
	# ===============================
	# Ejecutar el script SQL usando el modo bootstrap de MariaDB
	# --bootstrap permite ejecutar comandos SQL antes de que el servidor esté completamente iniciado
	/usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create database and user."
    exit 1
	fi
  # Limpiar archivo temporal de comandos SQL
  rm -f /tmp/create_db.sql
fi