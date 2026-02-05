FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y nginx openssl gettext-base

COPY conf/nginx.conf /etc/nginx/sites-available/default

COPY tools/nginx-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-setup.sh

EXPOSE 443

ENTRYPOINT ["nginx-setup.sh"]

CMD ["nginx", "-g", "daemon off;"]