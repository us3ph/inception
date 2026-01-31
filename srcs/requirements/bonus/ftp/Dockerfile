FROM alpine:3.18

#install vsftpd (FTP server)
RUN apk update && apk add --no-cache vsftpd

#create a user for FTP access
RUN adduser -D ftpuser && echo "ftpuser:ftppass" | chpasswd

#configure vsftpd
# local_enable: allow local users to login
# write_enable: allow uploading/modifying files
# pasv_enable: enable passive mode (essential for docker)
# pasv_min/max_port: port range for passive mode data transfer
RUN sed -i "s|#local_enable=YES|local_enable=YES|g" /etc/vsftpd/vsftpd.conf && \
    sed -i "s|#write_enable=YES|write_enable=YES|g" /etc/vsftpd/vsftpd.conf && \
    echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_min_port=21100" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_max_port=21110" >> /etc/vsftpd/vsftpd.conf && \
    echo "pasv_address=0.0.0.0" >> /etc/vsftpd/vsftpd.conf

#expose FTP ports
EXPOSE 21 21100-21110

#run vsftpd in foreground
CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
