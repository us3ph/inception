FROM alpine:3.23

#install redis
RUN apk update && apk add --no-cache redis

#config redis to listen on all network interfaces
#by default redis only listens to localhost, we change it to 0.0.0.0 so wordpress container can reach it
#also set memory limit and eviction policy for caching
RUN sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf && \
    sed -i 's/# maxmemory <bytes>/maxmemory 256mb/g' /etc/redis.conf && \
    sed -i 's/# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/g' /etc/redis.conf

#expose redis port
EXPOSE 6379

#start redis server
CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]