#!/bin/bash

echo "starting WordPress setup..."

cd /var/www/html/

DB_PASSWORD=$(cat /run/secrets/db_password)

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

if [ ! -f /usr/local/bin/wp ]; then
    echo "downloading WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    echo "WP-CLI installed"
fi

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

    echo "installing Redis object cache plugin..."
    wp plugin install redis-cache --activate --allow-root

    echo "configuring Redis in wp-config.php..."

    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp config set WP_CACHE true --raw --allow-root

    echo "enabling Redis object cache..."
    wp redis enable --allow-root

    echo "wordpress installation complete"
else
    echo "WordPress is already installed"
fi
echo "staring PHP-FPM..."

exec "$@"