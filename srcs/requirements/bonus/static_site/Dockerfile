FROM alpine:3.23

#install nginx
RUN apk update && apk add --no-cache nginx

#copy html files to nginx web root
COPY html /var/www/html

#create nginx configuration to serve the site on port 8080
RUN echo 'server { \
    listen 8080; \
    root /var/www/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/http.d/default.conf

#expose port 8080
EXPOSE 8080

#run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]