FROM alpine:3.23

RUN apk update && apk add --no-cache nginx

COPY html /var/www/html

RUN echo 'server { \
    listen 8080; \
    root /var/www/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/http.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]