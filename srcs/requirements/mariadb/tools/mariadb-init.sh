#!/bin/sh

set -e

# Read passwords from Docker secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Initialize MariaDB if this is the first startup
if [ ! -d "/var/lib/mysql/mysql" ]; then

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    mariadbd --user=mysql --bootstrap << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

fi

exec mariadbd --user=mysql