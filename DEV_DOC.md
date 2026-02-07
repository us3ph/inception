# Developer Documentation

This document provides technical details for developers who want to understand, modify, or contribute to the Inception project.

## Table of Contents

1. [Project Architecture](#project-architecture)
2. [Environment Setup from Scratch](#environment-setup-from-scratch)
3. [Configuration Files](#configuration-files)
4. [Building and Launching](#building-and-launching)
5. [Container Management](#container-management)
6. [Volume Management](#volume-management)
7. [Network Architecture](#network-architecture)
8. [Data Persistence](#data-persistence)
9. [Development Workflow](#development-workflow)
10. [Debugging Guide](#debugging-guide)
11. [Best Practices](#best-practices)

---

## Project Architecture

### Directory Structure

```
inception/
├── Makefile                           # Build automation
└── srcs/
    ├── docker-compose.yml             # Service orchestration
    ├── .env                           # Environment variables (gitignored)
    ├── .env.example                   # Template for .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile             # MariaDB image definition
        │   ├── conf/
        │   │   └── mariadb.cnf        # MariaDB configuration
        │   └── tools/
        │       └── init.sh            # Database initialization script
        ├── nginx/
        │   ├── Dockerfile             # NGINX image definition
        │   ├── conf/
        │   │   └── nginx.conf         # NGINX server configuration
        │   └── tools/
        │       └── setup_ssl.sh       # SSL certificate generation
        └── wordpress/
            ├── Dockerfile             # WordPress + PHP-FPM image
            ├── conf/
            │   └── www.conf           # PHP-FPM pool configuration
            └── tools/
                └── setup.sh           # WordPress installation script
```

### Service Dependencies

```
nginx (port 443)
  ↓
wordpress (port 9000)
  ↓
mariadb (port 3306)
```

- **NGINX** depends on WordPress being available
- **WordPress** depends on MariaDB being ready
- Services start in order: MariaDB → WordPress → NGINX

---

## Environment Setup from Scratch

### Prerequisites

**Required Software:**
- Docker Engine 20.10+
- Docker Compose 1.29+
- GNU Make
- Git
- Text editor (vim, nano, VSCode, etc.)

**Installation on Debian/Ubuntu:**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Initial Configuration

1. **Clone the repository:**
```bash
git clone <repository-url>
cd inception
```

2. **Create the .env file:**
```bash
cp srcs/.env.example srcs/.env
```

3. **Configure environment variables:**

Edit `srcs/.env` with your preferred text editor:
```bash
vim srcs/.env
```

**Required variables:**
```bash
# Domain Configuration
DOMAIN_NAME=ytabia.42.fr

# MariaDB Configuration
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=your_secure_wp_db_password

# WordPress Admin User
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_secure_admin_password
WP_ADMIN_EMAIL=admin@ytabia.42.fr

# WordPress Regular User
WP_USER=user
WP_USER_PASSWORD=your_secure_user_password
WP_USER_EMAIL=user@ytabia.42.fr

# WordPress Configuration
WP_TITLE=Inception
WP_URL=https://ytabia.42.fr
```

⚠️ **Security Best Practices:**
- Use strong, unique passwords (16+ characters)
- Never commit `.env` to version control
- Use different passwords for each service
- Use a password manager to generate secure passwords

4. **Configure local DNS:**

Add domain to `/etc/hosts`:
```bash
echo "127.0.0.1 ytabia.42.fr" | sudo tee -a /etc/hosts
```

Verify:
```bash
ping ytabia.42.fr
```

### Secrets Management

Secrets are stored in Docker secrets (mounted at `/run/secrets/` inside containers):

**Creating secrets:**
```bash
# In docker-compose.yml
secrets:
  db_root_password:
    file: ./.secrets/db_root_password.txt
  db_password:
    file: ./.secrets/db_password.txt
```

**Structure:**
```
srcs/
├── .secrets/              # Gitignored directory
│   ├── db_root_password.txt
│   ├── db_password.txt
│   └── wp_admin_password.txt
```

**Accessing secrets in containers:**
```bash
# In scripts
DB_PASSWORD=$(cat /run/secrets/db_password)
```

---

## Configuration Files

### docker-compose.yml

**Key sections:**

```yaml
version: '3.8'

services:
  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    env_file: .env
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception
    restart: always

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    depends_on:
      - mariadb
    env_file: .env
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - inception
    restart: always

  nginx:
    build: ./requirements/nginx
    container_name: nginx
    depends_on:
      - wordpress
    env_file: .env
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html:ro
    networks:
      - inception
    restart: always

networks:
  inception:
    driver: bridge

volumes:
  mariadb_data:
    driver: local
  wordpress_data:
    driver: local
```

### Dockerfiles

**Common structure:**
```dockerfile
FROM alpine:3.18

# Install packages
RUN apk update && apk add --no-cache \
    package1 \
    package2

# Copy configuration files
COPY conf/config.conf /etc/service/

# Copy setup scripts
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Expose ports
EXPOSE 9000

# Run as non-root user (if applicable)
USER service_user

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/setup.sh"]
```

**Best practices:**
- Use specific base image tags (not `latest`)
- Minimize layers (combine RUN commands)
- Clean package manager cache
- Run as non-root when possible
- Use multi-stage builds if needed

---

## Building and Launching

### Using the Makefile

The Makefile provides convenient commands:

**Available targets:**
```makefile
all:        Build and start all services
build:      Build Docker images only
up:         Start containers without building
down:       Stop and remove containers
stop:       Stop containers without removing
start:      Start stopped containers
restart:    Restart all containers
logs:       Show container logs
clean:      Remove containers and networks
fclean:     Remove containers, networks, volumes, and images
re:         Clean and rebuild everything
status:     Show container status
```

**Makefile structure:**
```makefile
COMPOSE_FILE = ./srcs/docker-compose.yml
COMPOSE = docker-compose -f $(COMPOSE_FILE)

all: build up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af
	sudo rm -rf /home/${USER}/data

re: fclean all

logs:
	$(COMPOSE) logs -f

.PHONY: all build up down clean fclean re logs
```

### Manual Docker Compose Commands

**Build images:**
```bash
cd srcs
docker-compose build
```

**Build with no cache:**
```bash
docker-compose build --no-cache
```

**Start services:**
```bash
docker-compose up -d
```

**Start with logs visible:**
```bash
docker-compose up
```

**Stop services:**
```bash
docker-compose down
```

**Stop and remove volumes:**
```bash
docker-compose down -v
```

**Rebuild specific service:**
```bash
docker-compose build nginx
docker-compose up -d --no-deps nginx
```

---

## Container Management

### Useful Docker Commands

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**View container logs:**
```bash
docker logs mariadb
docker logs -f wordpress    # Follow logs
docker logs --tail 50 nginx # Last 50 lines
```

**Execute commands in running container:**
```bash
docker exec -it mariadb sh
docker exec wordpress ls -la /var/www/html
```

**Inspect container:**
```bash
docker inspect mariadb
docker inspect mariadb | jq '.[0].NetworkSettings'
```

**View container resource usage:**
```bash
docker stats
```

**Stop/start/restart specific container:**
```bash
docker stop nginx
docker start nginx
docker restart nginx
```

**Remove container:**
```bash
docker rm -f nginx
```

### Container Troubleshooting

**Check why container exited:**
```bash
docker logs mariadb
docker inspect mariadb | jq '.[0].State'
```

**Access container filesystem:**
```bash
docker exec -it mariadb sh
ls -la /var/lib/mysql
cat /etc/mysql/mariadb.conf.d/50-server.cnf
```

**Copy files from/to container:**
```bash
docker cp nginx:/etc/nginx/nginx.conf ./nginx.conf
docker cp ./test.php wordpress:/var/www/html/
```

**Test network connectivity between containers:**
```bash
docker exec wordpress ping mariadb
docker exec wordpress nc -zv mariadb 3306
```

---

## Volume Management

### Understanding Volumes

Docker volumes store persistent data outside container filesystems:

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect srcs_wordpress_data
```

**Volume location on host:**
```bash
# Default location
/var/lib/docker/volumes/srcs_wordpress_data/_data
```

**Access volume data:**
```bash
sudo ls -la /var/lib/docker/volumes/srcs_wordpress_data/_data
```

### Volume Operations

**Create volume manually:**
```bash
docker volume create my_volume
```

**Remove volume:**
```bash
docker volume rm srcs_wordpress_data
```

**Remove all unused volumes:**
```bash
docker volume prune
```

**Backup volume:**
```bash
docker run --rm \
  -v srcs_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/wordpress_backup.tar.gz /data
```

**Restore volume:**
```bash
docker run --rm \
  -v srcs_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/wordpress_backup.tar.gz -C /
```

### Volume Bind Mounts (for development)

If you need to edit files directly during development:

```yaml
volumes:
  - ./wordpress_files:/var/www/html  # Bind mount
```

⚠️ **Note**: The project requirements specify using volumes, not bind mounts for production.

---

## Network Architecture

### Docker Network Details

**List networks:**
```bash
docker network ls
```

**Inspect network:**
```bash
docker network inspect srcs_inception
```

**Network configuration:**
```yaml
networks:
  inception:
    driver: bridge
```

**How containers communicate:**
- Containers can reach each other by service name (DNS)
- Example: WordPress connects to `mariadb:3306`
- Only NGINX exposes ports to the host (443)

### Testing Network Connectivity

**From host to NGINX:**
```bash
curl -k https://localhost
curl -k https://ytabia.42.fr
```

**From WordPress to MariaDB:**
```bash
docker exec wordpress ping mariadb
docker exec wordpress nc -zv mariadb 3306
```

**Check DNS resolution:**
```bash
docker exec wordpress nslookup mariadb
docker exec wordpress getent hosts mariadb
```

**Test WordPress → MariaDB connection:**
```bash
docker exec wordpress mysql -h mariadb -u wpuser -p wordpress -e "SHOW TABLES;"
```

---

## Data Persistence

### Where Data is Stored

**MariaDB data:**
- Volume: `mariadb_data`
- Mount point: `/var/lib/mysql`
- Contains: Database files, tables, logs

**WordPress data:**
- Volume: `wordpress_data`
- Mount point: `/var/www/html`
- Contains: WordPress core, themes, plugins, uploads

### Data Persistence Verification

**Test data persistence:**

1. Create a WordPress post
2. Stop containers: `make down`
3. Start containers: `make`
4. Check if post still exists

**Verify volume contents:**
```bash
# MariaDB
docker exec mariadb ls -la /var/lib/mysql

# WordPress
docker exec wordpress ls -la /var/www/html/wp-content/uploads
```

### Data Lifecycle

**On `make down`:**
- Containers stopped and removed
- Volumes preserved
- Data persists

**On `make fclean`:**
- Containers removed
- Networks removed
- Volumes removed
- Data deleted

---

## Development Workflow

### Making Changes to Configuration

1. **Edit configuration files:**
```bash
vim srcs/requirements/nginx/conf/nginx.conf
```

2. **Rebuild specific service:**
```bash
cd srcs
docker-compose build nginx
```

3. **Restart service:**
```bash
docker-compose up -d --no-deps nginx
```

4. **Test changes:**
```bash
docker logs nginx
curl -k https://ytabia.42.fr
```

### Modifying Dockerfiles

**Best practice workflow:**

1. Make changes to Dockerfile
2. Build with no cache to test:
```bash
docker-compose build --no-cache service_name
```

3. Test the container:
```bash
docker-compose up service_name
docker logs -f service_name
```

4. If successful, rebuild all:
```bash
make re
```

### Testing Individual Services

**Test MariaDB:**
```bash
docker exec -it mariadb mysql -u root -p
# Enter password, then:
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

**Test PHP-FPM:**
```bash
docker exec wordpress php -v
docker exec wordpress php-fpm -t
```

**Test NGINX:**
```bash
docker exec nginx nginx -t
docker exec nginx nginx -s reload
```

---

## Debugging Guide

### Common Issues

#### 1. Container Won't Start

**Check logs:**
```bash
docker logs container_name
```

**Common causes:**
- Syntax error in configuration
- Missing dependencies
- Port already in use
- Permission issues

**Solution:**
```bash
# Rebuild from scratch
make fclean
make
```

#### 2. Database Connection Failed

**Check:**
```bash
# Verify MariaDB is running
docker ps | grep mariadb

# Check MariaDB logs
docker logs mariadb

# Test connection
docker exec wordpress mysql -h mariadb -u wpuser -p
```

**Common causes:**
- MariaDB not fully initialized
- Wrong credentials in .env
- Network issues

**Solution:**
```bash
# Wait for MariaDB initialization
docker logs -f mariadb

# Verify environment variables
docker exec mariadb env | grep MYSQL
```

#### 3. NGINX 502 Bad Gateway

**Check:**
```bash
# Verify WordPress is running
docker ps | grep wordpress

# Check NGINX upstream
docker exec nginx cat /etc/nginx/nginx.conf

# Test PHP-FPM
docker exec wordpress php-fpm -t
```

**Solution:**
```bash
# Restart WordPress
docker restart wordpress

# Check connectivity
docker exec nginx ping wordpress
```

#### 4. SSL Certificate Issues

**Regenerate certificates:**
```bash
docker exec nginx ls -la /etc/nginx/ssl/
docker exec nginx openssl x509 -in /etc/nginx/ssl/certificate.crt -text -noout
```

**Rebuild NGINX:**
```bash
docker-compose build --no-cache nginx
docker-compose up -d nginx
```

### Advanced Debugging

**Enter container for debugging:**
```bash
docker exec -it mariadb sh

# Inside container
ps aux
netstat -tulpn
cat /etc/my.cnf
```

**Check file permissions:**
```bash
docker exec wordpress ls -la /var/www/html
docker exec mariadb ls -la /var/lib/mysql
```

**Monitor real-time logs:**
```bash
docker-compose logs -f --tail=100
```

**Check resource usage:**
```bash
docker stats
```

---

## Best Practices

### Dockerfile Best Practices

✅ **Do:**
- Use specific image tags (`alpine:3.18`, not `alpine:latest`)
- Combine RUN commands to reduce layers
- Clean package cache after installation
- Use `.dockerignore` to exclude unnecessary files
- Run processes as PID 1 (no wrapper scripts if possible)
- Use ENTRYPOINT for main process

❌ **Don't:**
- Use `tail -f` or `sleep infinity` to keep containers running
- Install unnecessary packages
- Store secrets in Dockerfiles
- Use `latest` tags
- Run as root unnecessarily

### Security Best Practices

✅ **Do:**
- Use Docker secrets for sensitive data
- Run services as non-root users
- Keep images updated
- Use strong passwords
- Limit container capabilities
- Use TLS for all connections

❌ **Don't:**
- Commit `.env` to version control
- Use default passwords
- Expose unnecessary ports
- Run services as root
- Store passwords in plain text

### Performance Best Practices

✅ **Do:**
- Use multi-stage builds
- Minimize image layers
- Use build cache effectively
- Clean up temporary files
- Optimize configuration files

❌ **Don't:**
- Install development tools in production images
- Keep unnecessary files in images
- Use large base images unnecessarily

---

## Testing Checklist

Before submitting your project:

**Functional Tests:**
- [ ] `make` builds all images without errors
- [ ] All containers start successfully
- [ ] https://ytabia.42.fr loads WordPress
- [ ] WordPress admin panel is accessible
- [ ] Database connection works
- [ ] Data persists after `make down` and `make`
- [ ] SSL certificate is present and valid (self-signed)

**Technical Tests:**
- [ ] No containers use `latest` tags
- [ ] No `tail -f` or infinite loops
- [ ] All containers restart on crash
- [ ] Volumes are used (not bind mounts)
- [ ] Custom bridge network is used
- [ ] Only NGINX exposes port 443
- [ ] `.env` is gitignored
- [ ] All Dockerfiles follow best practices

**Documentation Tests:**
- [ ] README.md is complete
- [ ] USER_DOC.md is clear for end users
- [ ] DEV_DOC.md is detailed for developers
- [ ] All commands in docs work correctly

---

## Additional Resources

### Useful Commands Reference

```bash
# Quick rebuild
make re

# View logs
make logs

# Check status
docker-compose ps

# Clean everything
make fclean

# Access MariaDB
docker exec -it mariadb mysql -u root -p

# Access WordPress container
docker exec -it wordpress sh

# Check NGINX config
docker exec nginx nginx -t

# Reload NGINX
docker exec nginx nginx -s reload
```

### Environment Variables Reference

```bash
DOMAIN_NAME              # ytabia.42.fr
MYSQL_ROOT_PASSWORD      # MariaDB root password
MYSQL_DATABASE           # Database name (wordpress)
MYSQL_USER               # WordPress DB user
MYSQL_PASSWORD           # WordPress DB password
WP_ADMIN_USER            # WP admin username
WP_ADMIN_PASSWORD        # WP admin password
WP_ADMIN_EMAIL           # WP admin email
WP_USER                  # WP regular user
WP_USER_PASSWORD         # WP user password
WP_USER_EMAIL            # WP user email
WP_TITLE                 # Site title
WP_URL                   # Site URL
```

---

This documentation should provide all the technical details needed to work with the this project. For user facing instructions, refer to [USER_DOC.md](USER_DOC.md).