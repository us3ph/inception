#!/bin/bash

echo "starting MariaDB setup..."

#start MySQL temporarily to cnfigure it
service mysql start
sleep 3

#wail until mysql is ready to accept commands

echo "waiting for MySQL to be ready..."

unlti mysqladmin ping &>/dev/null 2>&1; do
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

#stop the temporarily MySQL service
mysqladmin -u root -p${DB_PASSWORD} shutdown

#start MySQL properly (this keep container running)
echo "starting MariaDB in foreground..."
exec mysqld


#1. **Starts MySQL temporarily** - We need it running to configure it
#2. **Waits for MySQL** - Makes sure it's ready before we try to use it
#3. **Reads passwords** - Gets passwords from our secret files
#4. **Creates database** - Sets up the WordPress database
#5. **Creates user** - Makes a user account that WordPress will use
#6. **Grants permissions** - Gives the user access to the database
#7. **Sets root password** - Secures the root account
#8. **Starts MySQL properly** - Keeps it running forever