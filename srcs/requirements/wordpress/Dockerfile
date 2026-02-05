FROM debian:trixie

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

COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

COPY tools/wordpress-setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-setup.sh

RUN mkdir -p /run/php

EXPOSE 9000

ENTRYPOINT ["wordpress-setup.sh"]

CMD ["php-fpm8.4", "-F"]