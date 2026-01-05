#start with Debian Bullseye (stable linux version)
FROM debian:bullseye

#install Nginx and OpenSSL
#Nginx is the web server, OpenSSL tool to create SSL certificates (for HTTPS)
RUN apt-get update -y && \
    apt-get update -y && \
    apt-get install -y nginx openssl gettext-base

#copy our Nginx configuration file
COPY conf/nginx.conf /etc/nginx/sites-available/default

#copy our setup script that will generate SSL certificates
COPY tools/nginx-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-setup.sh

#Nginx listens on port 443 for HTTPS
EXPOSE 443

#run the setup script first (creates SSL certificates)

ENTRYPOINT ["nginx-setup.sh"]

#then start Ngnix in the foreground mode (so the container keeps running)
#-g means off = dont run in background (docker needs foreground)
CMD ["nginx", "-g", "daemon off;"]







# **Key points:**
# - `nginx` - The web server software
# - `openssl` - Creates SSL certificates for HTTPS
# - Port `443` - Standard HTTPS port (HTTP uses 80, HTTPS uses 443)
# - `daemon off` - Keeps Nginx running in the foreground (required for Docker)


# Before we create the config, let's understand **why we need SSL**:
#
# **Without SSL (HTTP):**
# ```
# Your Computer → "password123" → Server
#                 ↑ Anyone can read this!
# ```
#
# **With SSL (HTTPS):**
# ```
# Your Computer → "jK8#mP2$qL9" (encrypted) → Server
#                 ↑ Looks like gibberish to hackers!