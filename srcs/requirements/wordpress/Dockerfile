FROM debian:trixie

#install php and required extensions (Debian Trixie uses PHP 8.4 without version suffix)
RUN apt-get update -y && \
    apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-redis \
    curl \
    wget \
    mariadb-client

#copy PHP-FPM configuration (PHP 8.4 path)
COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

#copy setup script
COPY tools/wordpress-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-setup.sh

#create directory for PHP-FPM to run
RUN mkdir -p /run/php

#PHP-FPM listens on port 9000
EXPOSE 9000

#run setup script first
ENTRYPOINT ["wordpress-setup.sh"]

#keep PHP-FPM running in foreground (PHP 8.4)
CMD ["php-fpm8.4", "-F"]