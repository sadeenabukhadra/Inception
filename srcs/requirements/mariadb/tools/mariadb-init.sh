#!/bin/sh

set -e

# Create the directory for the MariaDB Unix socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Read passwords from Docker secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Initialize MariaDB if this is the first startup
if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing MariaDB system tables..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    echo "Starting temporary MariaDB server..."

    mariadbd \
        --user=mysql \
        --skip-networking &

    TEMP_PID=$!

    echo "Waiting for MariaDB..."

    mariadb-admin \
        -uroot \
        --wait=30 \
        ping

    echo "MariaDB is ready."

    echo "Creating database and user..."

    mariadb -uroot << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    echo "Database and user created successfully."

    echo "Stopping temporary MariaDB server..."

    mariadb-admin \
        -uroot \
        -p"${DB_ROOT_PASSWORD}" \
        shutdown

    wait $TEMP_PID

    echo "MariaDB initialization completed."

fi

# Start MariaDB in the foreground
exec mariadbd --user=mysql
