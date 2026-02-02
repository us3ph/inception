FROM debian:trixie

#install php and adminer package (no need for php-fpm, using built-in server)
RUN apt-get update && apt-get install -y --no-install-recommends \
    php \
    php-mysqli \
    adminer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#setup adminer - create symlink to serve via PHP
RUN mkdir -p /var/www/html && \
    ln -s /usr/share/adminer/adminer.php /var/www/html/index.php

#expose port 8080 for PHP built-in server
EXPOSE 8080

#start PHP built-in web server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]