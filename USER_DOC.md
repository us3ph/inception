# User Documentation

This document provides instructions for end users and system administrators on how to use and manage the Inception infrastructure.

## Table of Contents

1. [Overview](#overview)
2. [Services Provided](#services-provided)
3. [Starting and Stopping the Project](#starting-and-stopping-the-project)
4. [Accessing the Services](#accessing-the-services)
5. [Managing Credentials](#managing-credentials)
6. [Verifying Service Status](#verifying-service-status)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The Inception project provides a complete web hosting infrastructure running in isolated Docker containers. The stack includes:
- A secure web server (NGINX with HTTPS)
- A content management system (WordPress)
- A database server (MariaDB)

All services are containerized, automatically configured, and orchestrated to work together seamlessly.

---

## Services Provided

### 1. NGINX Web Server
- **Purpose**: Serves as the entry point for all web traffic
- **Features**:
  - HTTPS/SSL encryption (TLS 1.2/1.3)
  - Reverse proxy to WordPress
  - Static file serving
  - Security headers

### 2. WordPress
- **Purpose**: Content Management System for website creation and management
- **Features**:
  - Full CMS functionality
  - Theme and plugin support
  - User management
  - Media library
  - Connected to MariaDB database

### 3. MariaDB
- **Purpose**: Database server for WordPress data storage
- **Features**:
  - Persistent data storage
  - Automatic initialization with WordPress database
  - User and privilege management
  - Data backup through volumes

---

## Starting and Stopping the Project

### Prerequisites

Ensure Docker and Docker Compose are installed and running on your system.

### Starting the Infrastructure

1. Open a terminal in the project root directory

2. Start all services:
```bash
make
```

This command will:
- Build all Docker images (if not already built)
- Create the necessary networks and volumes
- Start all containers in the correct order
- Configure SSL certificates
- Initialize the WordPress database

**Expected output**: You should see containers starting without errors. The process may take 1-2 minutes on first run.

### Stopping the Infrastructure

To stop all services gracefully:
```bash
make down
```

This command will:
- Stop all running containers
- Remove containers and networks
- Preserve all data in volumes

**Data Safety**: Your WordPress content and database data will be preserved in Docker volumes.

### Complete Cleanup

To remove everything including data volumes:
```bash
make fclean
```

**Warning**: This will delete ALL data including WordPress posts, uploads, and database content. Use with caution!

### Restarting from Scratch

To rebuild everything:
```bash
make re
```

---

## Accessing the Services

### Domain Configuration

Before accessing the services, ensure `ytabia.42.fr` points to your server:

**For local development:**
```bash
sudo nano /etc/hosts
```

Add this line:
```
127.0.0.1    ytabia.42.fr
```

### Accessing the Website

**WordPress Frontend:**
- URL: https://ytabia.42.fr
- What you'll see: The main WordPress website

**Browser Security Warning:**
- You will see an SSL/TLS warning because the certificate is self-signed
- This is normal and expected for this project
- Click "Advanced" → "Proceed to ytabia.42.fr" (or similar option in your browser)

### Accessing the Administration Panel

**WordPress Admin Dashboard:**
- URL: https://ytabia.42.fr/wp-admin
- Use your administrator credentials (see [Managing Credentials](#managing-credentials))

**Admin Dashboard Features:**
- Create and edit posts/pages
- Manage themes and plugins
- Configure site settings
- Manage users
- View site analytics

---

## Managing Credentials

### Location of Credentials

All credentials are stored in the `.env` file located at:
```
srcs/.env
```

**Security Note**: Never commit the `.env` file to version control. It contains sensitive information.

### Default Credentials Structure

The `.env` file contains the following credential types:

**Database Credentials:**
- `MYSQL_ROOT_PASSWORD` - MariaDB root password
- `MYSQL_DATABASE` - WordPress database name
- `MYSQL_USER` - WordPress database user
- `MYSQL_PASSWORD` - WordPress database password

**WordPress Credentials:**
- `WP_ADMIN_USER` - WordPress administrator username
- `WP_ADMIN_PASSWORD` - WordPress administrator password
- `WP_ADMIN_EMAIL` - WordPress administrator email
- `WP_USER` - WordPress standard user username
- `WP_USER_PASSWORD` - WordPress standard user password
- `WP_USER_EMAIL` - WordPress standard user email

**Domain Configuration:**
- `DOMAIN_NAME` - Should be set to `ytabia.42.fr`

### Viewing Credentials

To view your credentials:
```bash
cat srcs/.env
```

### Changing Credentials

1. Stop the infrastructure:
```bash
make down
```

2. Edit the `.env` file:
```bash
nano srcs/.env
```

3. Modify the desired credentials

4. Rebuild and restart:
```bash
make re
```

**Important**: Changing credentials after initial setup may require a complete rebuild to take effect.

---

## Verifying Service Status

### Checking if Services are Running

**Method 1: Using Make**
```bash
make status
```
(If this target exists in your Makefile)

**Method 2: Using Docker Compose**
```bash
cd srcs
docker-compose ps
```

**Expected output:**
```
NAME                COMMAND             STATUS              PORTS
mariadb             "docker-entry..."   Up 2 minutes        3306/tcp
nginx               "nginx -g 'dae..."  Up 2 minutes        0.0.0.0:443->443/tcp
wordpress           "docker-entry..."   Up 2 minutes        9000/tcp
```

All services should show `Up` status.

### Checking Individual Services

**NGINX:**
```bash
docker exec nginx nginx -t
```
Expected: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

**MariaDB:**
```bash
docker exec mariadb mysqladmin ping -p<MYSQL_ROOT_PASSWORD>
```
Expected: `mysqld is alive`

**WordPress:**
```bash
docker exec wordpress php-fpm -t
```
Expected: `configuration file /etc/php*/php-fpm.conf test is successful`

### Viewing Service Logs

To see what's happening inside the containers:

**All services:**
```bash
cd srcs
docker-compose logs
```

**Specific service:**
```bash
docker-compose logs nginx
docker-compose logs wordpress
docker-compose logs mariadb
```

**Follow logs in real-time:**
```bash
docker-compose logs -f
```

Press `Ctrl+C` to stop following logs.

### Testing Website Accessibility

**From command line:**
```bash
curl -k https://ytabia.42.fr
```

You should see HTML content from WordPress.

**From browser:**
1. Navigate to https://ytabia.42.fr
2. You should see the WordPress homepage
3. Accept the SSL certificate warning

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Cannot connect to Docker daemon"
**Solution:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

#### Issue: "Port 443 already in use"
**Solution:**
Check what's using port 443:
```bash
sudo lsof -i :443
```
Stop the conflicting service or change the port in `docker-compose.yml`.

#### Issue: "Error establishing database connection"
**Solutions:**
1. Wait 30 seconds for MariaDB to fully initialize
2. Check MariaDB logs:
```bash
docker-compose logs mariadb
```
3. Verify credentials in `.env` file match
4. Restart the infrastructure:
```bash
make down
make
```

#### Issue: "SSL Certificate Warning won't go away"
**Solution:**
This is expected behavior. The certificate is self-signed. Simply proceed past the warning in your browser.

#### Issue: "ytabia.42.fr not found"
**Solution:**
Ensure the domain is in your `/etc/hosts` file:
```bash
echo "127.0.0.1 ytabia.42.fr" | sudo tee -a /etc/hosts
```

#### Issue: "WordPress shows installation screen"
**Solution:**
WordPress may not be initialized. Check:
1. MariaDB is running and initialized
2. Environment variables are correct
3. Check WordPress logs for errors

### Getting Help

**View all container logs:**
```bash
cd srcs
docker-compose logs --tail=100
```

**Access container shell for debugging:**
```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

**Check container resource usage:**
```bash
docker stats
```

### Emergency Recovery

If everything is broken:
1. Stop all services:
```bash
make down
```

2. Clean everything:
```bash
make fclean
```

3. Rebuild from scratch:
```bash
make
```

**Warning**: This will delete all data. Make sure to backup important content first if needed.

---

## Data Backup

While not automated, you can backup your data manually:

**Backup WordPress files:**
```bash
docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_backup.tar.gz /data
```

**Backup Database:**
```bash
docker exec mariadb mysqldump -u root -p<MYSQL_ROOT_PASSWORD> --all-databases > backup.sql
```

---

## Conclusion

This infrastructure is designed to be simple, reliable, and maintainable. For most operations, the `make` command is all you need. For more technical details and development setup, refer to [DEV_DOC.md](DEV_DOC.md).