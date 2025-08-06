#!/bin/sh

# Start MariaDB in the background
mysqld_safe --user=mysql --datadir=/var/lib/mysql &

# Wait for MariaDB to start
until mysqladmin ping -h localhost --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

echo "MariaDB started successfully"

# Check if the WordPress database exists
if ! mysql -e "USE ${DB_NAME};" 2>/dev/null; then
	echo "Creating database and user..."

	mysql -e "
		DELETE FROM mysql.user WHERE User='';
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test';
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
		CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
	"

	if [ $? -eq 0 ]; then
		echo "Database and user created successfully"
	else
		echo "Error: Failed to create database and user"
		exit 1
	fi
else
	echo "Database already exists, but ensuring user exists..."
	mysql -e "
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
	"
	echo "User permissions updated"
fi

# Stop the background MariaDB to let the main process take over
mysqladmin shutdown

echo "Database setup completed"