#!/bin/bash

set -e

echo "Starting WordPress initialization..."

cd /var/www/html

# Read database password from Docker secret
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."

until mariadb \
    -h"${MYSQL_HOST}" \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
    -e "SELECT 1;" > /dev/null 2>&1
do
    echo "MariaDB is not ready yet..."
    sleep 2
done

echo "MariaDB connection successful."

# Create wp-config.php if it does not exist
if [ ! -f /var/www/html/wp-config.php ]; then

    echo "Creating wp-config.php..."

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php

fi

# Install WordPress if it has not been installed yet
if ! wp core is-installed --allow-root; then

    echo "Installing WordPress..."

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating second WordPress user..."

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=subscriber \
        --allow-root

    echo "WordPress installation completed."

else

    echo "WordPress is already installed."

fi

# Set WordPress permissions
chown -R www-data:www-data /var/www/html

echo "WordPress initialization completed."

# Start PHP-FPM in foreground
exec php-fpm8.4 -F
