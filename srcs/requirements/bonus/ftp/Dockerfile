FROM alpine:3.23

ARG FTP_USER
ARG FTP_PASSWORD

RUN apk update && apk add --no-cache vsftpd

RUN adduser -D -h /home/${FTP_USER} ${FTP_USER} && \
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd && \
    mkdir -p /home/${FTP_USER}/ftp && \
    chown -R ${FTP_USER}:${FTP_USER} /home/${FTP_USER}

RUN sed -i "s|#local_enable=YES|local_enable=YES|g" /etc/vsftpd/vsftpd.conf && \
    sed -i "s|#write_enable=YES|write_enable=YES|g" /etc/vsftpd/vsftpd.conf && \
    echo "seccomp_sandbox=NO" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_min_port=21100" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_max_port=21110" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_address=127.0.0.1" >> /etc/vsftpd/vsftpd.conf && \
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf

EXPOSE 21 21100-21110

CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]

