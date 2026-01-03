#!/bin/bash

echo "generating SSL certificate..."

#generate a self-signed SSL certificate

openssl req - x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=MA/ST=Marrakesh/L=Benguerir/O=1337/OU=student/CN=${DOMAIN_NAME}"

echo "SSL certificate created"

#start Nginx (the CMD from Dockerfile will run)
exec "$@"






# openssl req - Request a certificate
# -x509 - Create a self-signed certificate (not from a certificate authority)
# -nodes - No password needed (easier for automation)
# -days 365 - Valid for 1 year
# -newkey rsa:2048 - Create a new 2048-bit RSA key (the encryption strength)

# -keyout - Where to save the private key (keep this secret!)
# -out - Where to save the certificate (can be public)


# C = Country (MA = Morocco)
# ST = State (Marrakesh)
# L = Location (BenGuerir)
# O = Organization (1337)
# OU = Organizational Unit (student)
# CN = Common Name (your domain name - very important!)