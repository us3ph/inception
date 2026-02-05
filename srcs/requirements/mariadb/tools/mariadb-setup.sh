#!/bin/bash

echo "starting MariaDB setup..."

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!
sleep 3

echo "waiting for MySQL to be ready..."

until mysqladmin ping &>/dev/null 2>&1; do
    sleep 1
done
echo "MySQL is ready!"

DB_PASSWORD=$(cat /run/secrets/db_password)

echo "creating database: ${MYSQL_DATABASE}"
mysql << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "database setup completed"

kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null

echo "starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
