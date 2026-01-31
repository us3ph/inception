FROM alpine:3.18

#install php and required extensions
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-session \
    wget

#download the adminer PHP file
# rename it to index.php so it loads automatically
RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php && \
    chmod 644 /var/www/html/index.php

#configure PHP-FPM to listen on all interfaces
RUN sed -i "s|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|g" /etc/php81/php-fpm.d/www.conf

#create directory for PHP-FPM to run
RUN mkdir -p /run/php

#expose port 9000 for PHP-FPM
EXPOSE 9000

#start PHP-FPM in foreground mode
CMD ["php-fpm81", "-F"]