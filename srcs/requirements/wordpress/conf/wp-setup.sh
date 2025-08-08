#!/bin/sh

# ===============================
# WORDPRESS AUTOMATIC CONFIGURATION SCRIPT
# ===============================
# This script automates complete WordPress installation and configuration
# Runs every time container starts, but includes checks
# to avoid reconfiguring an already installed WordPress

# ===============================
# EARLY EXIT CHECK - WordPress already configured
# ===============================
# Check if WordPress is already fully configured to avoid reconfiguration:
# 1. wp-config.php exists
# 2. WordPress core is installed
# 3. Specified user already exists
if [ -f /var/www/html/wp-config.php ] && 
   wp core is-installed --allow-root --path="/var/www/html" && 
   wp user get "$WP_USER" --allow-root --path="/var/www/html" &>/dev/null; then
    echo "WordPress is already fully configured. Exiting setup."
    exit 0
fi

# ===============================
# NORMAL CONFIGURATION PROCESS (Only if not configured)
# ===============================

# ===============================
# PRELIMINARY CHECKS
# ===============================
# Verify WP-CLI is installed (tool needed for automation)
if ! command -v wp > /dev/null 2>&1; then
    echo "Error: WP-CLI (wp command) is not installed"
    exit 1
fi

# Verify WordPress files exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Error: WordPress files not found in /var/www/html"
    exit 1
fi

# Verify PHP is installed
if ! command -v php > /dev/null 2>&1; then
    echo "PHP is not installed. Exiting."
    exit 1
fi

# ===============================
# DISPLAY CONFIGURATION INFORMATION
# ===============================
echo "Creating setup with the following values:"
echo "DB_NAME: ${DB_NAME}"
echo "DB_USER: ${DB_USER}"
echo "DB_PASS: ${DB_PASS}"

# ===============================
# WAIT FOR MARIADB TO BE READY
# ===============================
# Implement retries to wait for MariaDB to be available
# This is crucial because WordPress depends on the database
MAX_RETRIES=5                           # Maximum number of attempts
RETRY_COUNT=0                          # Current attempt counter
until mysql -h mariadb -u"${DB_USER}" -p"${DB_PASS}" -e "USE ${DB_NAME};" 2>/dev/null; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Error: Could not connect to MariaDB after $MAX_RETRIES attempts"
        echo "Trying command: mysql -h mariadb -u${DB_USER} -p[hidden] -e \"USE ${DB_NAME};\""
        mysql -h mariadb -u"${DB_USER}" -p"${DB_PASS}" -e "USE ${DB_NAME};"
        exit 1
    fi
    echo "Waiting for MariaDB... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 5                             # Wait 5 seconds between attempts
done

echo "Database ready. Proceeding with WordPress setup..."

# ===============================
# WORDPRESS CORE INSTALLATION
# ===============================
# Only run core installation if WordPress is not already installed
if ! wp core is-installed --allow-root --path="/var/www/html"; then
    echo "Running WordPress core installation..."
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="pablogon inception" \
        --admin_user="$DB_USER" \
        --admin_password="$DB_PASS" \
        --admin_email="pablooglez97@gmail.com" \
        --path="/var/www/html"
    if [ $? -ne 0 ]; then
        echo "Error: wp core install failed."
        exit 1
    fi
else
    echo "WordPress is already installed. Skipping core installation."
fi

# ===============================
# ADDITIONAL USER CREATION
# ===============================
# Only create additional user if it doesn't exist (besides admin)
if ! wp user list --allow-root --path="/var/www/html" | grep -q "^\s*[0-9]\+\s\+$WP_USER\s"; then
    echo "Creating WordPress user '$WP_USER'..."
    wp user create "$WP_USER" "guest@example.com" \
        --role=author \
        --user_pass="$WP_PASS" \
        --allow-root \
        --path="/var/www/html"
    [ $? -ne 0 ] && echo "Error: Failed to create user" && exit 1
else
    echo "User '$WP_USER' already exists. Skipping creation."
fi

echo "WordPress setup completed successfully."