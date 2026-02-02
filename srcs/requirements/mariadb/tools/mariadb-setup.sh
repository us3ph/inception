#!/bin/bash

echo "starting MariaDB setup..."

#initialize MariaDB data directory if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

#start MySQL temporarily to configure it
mysqld --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!
sleep 3

echo "waiting for MySQL to be ready..."

until mysqladmin ping &>/dev/null 2>&1; do
    sleep 1
done
echo "MySQL is ready!"

#read the password from the secret file

DB_PASSWORD=$(cat /run/secrets/db_password)

#create the database

echo "creating database: ${MYSQL_DATABASE}"
mysql << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "database setup completed"

#stop the temporary MySQL service
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null

#start MySQL properly (this keep container running)
echo "starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir=/var/lib/mysql


#1. **Starts MySQL temporarily** - We need it running to configure it
#2. **Waits for MySQL** - Makes sure it's ready before we try to use it
#3. **Reads passwords** - Gets passwords from our secret files
#4. **Creates database** - Sets up the WordPress database
#5. **Creates user** - Makes a user account that WordPress will use
#6. **Grants permissions** - Gives the user access to the database
#7. **Sets root password** - Secures the root account
#8. **Starts MySQL properly** - Keeps it running forever