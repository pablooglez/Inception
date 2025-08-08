#!/bin/sh

# ===============================
# WP-CONFIG.PHP GENERATION SCRIPT
# ===============================
# This script creates the main WordPress configuration file
# Only executes if the file doesn't exist (avoids overwriting existing configurations)

# Check if wp-config.php already exists in WordPress root directory
if [ ! -f "/var/www/html/wp-config.php" ]; then
    # Use heredoc to create wp-config.php with dynamic values from environment variables
    cat << EOF > /var/www/html/wp-config.php
<?php
# ===============================
# DATABASE CONNECTION CONFIGURATION
# ===============================
define( 'DB_NAME', '${DB_NAME}' );          # Database name (from environment variable)
define( 'DB_USER', '${DB_USER}' );          # Database user (from environment variable)
define( 'DB_PASSWORD', '${DB_PASS}' );      # Database password (from environment variable)
define( 'DB_HOST', 'mariadb' );             # MariaDB host (Docker service name)
define( 'DB_CHARSET', 'utf8' );             # Database character set
define( 'DB_COLLATE', '' );                 # No custom collation

# ===============================
# FILESYSTEM CONFIGURATION
# ===============================
# Filesystem method - allows direct filesystem writes (needed for Docker)
define('FS_METHOD','direct');

# ===============================
# SSL/HTTPS CONFIGURATION
# ===============================
# Force SSL for admin area and detect HTTPS from proxy headers
define('FORCE_SSL_ADMIN', true);
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    \$_SERVER['HTTPS'] = 'on';  # Set HTTPS flag when behind proxy with SSL termination
}

# ===============================
# DATABASE AND DEBUGGING CONFIGURATION
# ===============================
# WordPress database table prefix (change for security)
\$table_prefix = 'wp_';

# Debug mode - disabled in production (change to true only for development)
define( 'WP_DEBUG', false );

# ===============================
# PATHS AND WORDPRESS LOADING CONFIGURATION
# ===============================
# Define absolute path to WordPress directory
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

# Load WordPress settings (main system file)
require_once ABSPATH . 'wp-settings.php';
EOF

    echo "wp-config.php created successfully."
else
    echo "wp-config.php already exists. Skipping creation."
fi