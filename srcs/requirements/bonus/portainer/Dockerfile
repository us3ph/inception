FROM alpine:3.23

RUN apk update && apk add --no-cache wget tar ca-certificates

RUN wget https://github.com/portainer/portainer/releases/download/1.24.2/portainer-1.24.2-linux-amd64.tar.gz && \
    tar -xzf portainer-1.24.2-linux-amd64.tar.gz && \
    mv portainer /opt/portainer && \
    chmod +x /opt/portainer/portainer && \
    rm -f portainer-1.24.2-linux-amd64.tar.gz

RUN mkdir -p /data

EXPOSE 9000

WORKDIR /opt/portainer

CMD ["/opt/portainer/portainer", "--data", "/data", "--template-file", "/opt/portainer/templates.json"]
