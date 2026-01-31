FROM alpine:3.18

#install dependencies
RUN apk update && apk add --no-cache wget tar ca-certificates

#download and install portainer (using version 1.24.2 which doesn't require docker-compose)
RUN wget https://github.com/portainer/portainer/releases/download/1.24.2/portainer-1.24.2-linux-amd64.tar.gz && \
    tar -xzf portainer-1.24.2-linux-amd64.tar.gz && \
    mv portainer /opt/portainer && \
    chmod +x /opt/portainer/portainer && \
    rm -f portainer-1.24.2-linux-amd64.tar.gz

#create data directory for portainer
RUN mkdir -p /data

#expose portainer web interface port
EXPOSE 9000

#set working directory
WORKDIR /opt/portainer

#start portainer with correct paths
CMD ["/opt/portainer/portainer", "--data", "/data", "--template-file", "/opt/portainer/templates.json"]
