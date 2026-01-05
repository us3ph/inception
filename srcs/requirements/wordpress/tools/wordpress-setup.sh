#!/bin/bash

echo "starting WordPress setup..."

#change to wordpress directory
cd /var/www/html/

#read password from secret file
DB_PASSWORD=$(cat /run/secrets/db_password)

#extract admin and user credentials from credentials file
WP_ADMIN_USER=$(grep WORDPRESS_ADMIN= /run/secrets/wordpress_credentials | grep -v PASSWORD | cut -d '=' -f2)
WP_ADMIN_PASSWORD=$(grep WORDPRESS_ADMIN_PASSWORD /run/secrets/wordpress_credentials | cut -d '=' -f2)
WP_USER=$(grep WORDPRESS_USER= /run/secrets/wordpress_credentials | grep -v PASSWORD | cut -d '=' -f2)
WP_USER_PASSWORD=$(grep WORDPRESS_USER_PASSWORD /run/secrets/wordpress_credentials | cut -d '=' -f2)

echo "checking if MariaDB is ready..."
until mariadb -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "waiting for MariaDB..."
    sleep 3
done
echo "MariaDB is ready"

#download WP-CLI if not already present
if [ ! -f /usr/local/bin/wp ]; then
    echo "downloading WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    echo "WP-CLI installed"
fi

#check if WordPress is already installed
if [ ! -f wp-config.php ]; then
    echo "downloading WordPress..."
    wp core download --allow-root

    echo "creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --allow-root

    echo "installing WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "creating additional user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "installing and activating theme..."
    wp theme install astra --activate --allow-root

    echo "wordpress installation complete"
else
    echo "WordPress is already installed"
fi
echo "staring PHP-FPM..."

#start PHP-FPM (the CMD from Dockerfile will run)
exec "$@"






#  ## **Visual Summary: How Everything Works Together**
#  ```
#  ┌──────────────────────────────────────────────┐
#  │          WORDPRESS CONTAINER                 │
#  ├──────────────────────────────────────────────┤
#  │                                              │
#  │  1. wordpress-setup.sh runs:                │
#  │     ├─ Wait for MariaDB ⏳                  │
#  │     ├─ Download WP-CLI 📥                   │
#  │     ├─ Download WordPress 📦                │
#  │     ├─ Create wp-config.php ⚙️              │
#  │     ├─ Install WordPress 🔧                 │
#  │     ├─ Create users 👤                      │
#  │     └─ Install theme 🎨                     │
#  │                                              │
#  │  2. PHP-FPM starts (port 9000)              │
#  │     └─ Waits for requests from Nginx        │
#  │                                              │
#  └──────────────────────────────────────────────┘
#           ↑                           ↓
#           │ PHP files                 │ SQL queries
#           │                           │
#  ┌────────┴─────┐            ┌────────┴────────┐
#  │    NGINX     │            │    MARIADB      │
#  │  (port 443)  │            │  (port 3306)    │
#  └──────────────┘            └─────────────────┘
#  ```
#
#  ---
#
#  ## **Understanding the Complete Flow**
#
#  Let me show you what happens when a user visits your WordPress site:
#  ```
#  1. User types: https://login.42.fr
#     ↓
#  2. Browser connects to Nginx on port 443 (HTTPS)
#     ↓
#  3. Nginx sees it's the homepage, requests index.php
#     ↓
#  4. Nginx sends request to wordpress:9000 (PHP-FPM)
#     ↓
#  5. PHP-FPM executes index.php
#     ↓
#  6. WordPress needs post data, queries mariadb:3306
#     ↓
#  7. MariaDB returns post data
#     ↓
#  8. WordPress generates HTML
#     ↓
#  9. PHP-FPM sends HTML to Nginx
#     ↓
#  10. Nginx sends encrypted HTML to user's browser
#     ↓
#  11. User sees their WordPress site! 🎉