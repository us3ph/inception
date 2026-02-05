FROM alpine:3.23

RUN apk update && apk add --no-cache redis

RUN sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf && \
    sed -i 's/# maxmemory <bytes>/maxmemory 256mb/g' /etc/redis.conf && \
    sed -i 's/# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/g' /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]