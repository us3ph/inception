FROM debian:bullseye

#install php and required extensions
RUN apt-get update -y && \
    apt-get update -y && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-redis \
    curl \
    wget \
    mariadb-client

#copy PHP-FPM configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

#copy setup script
COPY tools/wordpress-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-setup.sh

#create directory for PHP-FPM to run
RUN mkdir -p /run/php

#PHP-FPM listens on port 9000
EXPOSE 9000

#run setup script first
ENTRYPOINT ["wordpress-setup.sh"]

#keep PHP-FPM running in foreground
CMD ["php-fpm7.4", "-F"]









#  php7.3-fpm        # PHP FastCGI Process Manager (talks to Nginx)
#  php7.3-mysql      # Allows PHP to connect to MariaDB
#  php7.3-cli        # Command-line PHP (for running WP-CLI)
#  php7.3-curl       # Makes HTTP requests (for downloading plugins/themes)
#  php7.3-gd         # Image processing (thumbnails, resizing)
#  php7.3-mbstring   # Multi-byte string support (for international characters)
#  php7.3-xml        # XML parsing (needed by WordPress)
#  php7.3-zip        # Handle ZIP files (for plugin/theme uploads)
#  curl              # Download tool
#  wget              # Another download tool
#  mariadb-client    # Allows us to connect to MariaDB for testing