#!/bin/bash

set -e

echo "Starting WordPress initialization..."

# WordPress directory
cd /var/www/html

# Read database password from Docker secret
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

# Wait for MariaDB
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

echo "MariaDB is ready."

# Create wp-config.php if it does not exist
if [ ! -f /var/www/html/wp-config.php ]; then

    echo "Creating wp-config.php..."

    cp /var/www/html/wp-config-sample.php \
       /var/www/html/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" \
        /var/www/html/wp-config.php

    sed -i "s/username_here/${MYSQL_USER}/" \
        /var/www/html/wp-config.php

    sed -i "s/password_here/${MYSQL_PASSWORD}/" \
        /var/www/html/wp-config.php

    sed -i "s/localhost/${MYSQL_HOST}/" \
        /var/www/html/wp-config.php
fi

# Set WordPress permissions
chown -R www-data:www-data /var/www/html

echo "WordPress initialization completed."

# Start PHP-FPM in foreground
exec php-fpm8.2 -F