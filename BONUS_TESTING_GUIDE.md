# Inception Bonus Services - Testing Guide

## Prerequisites
Make sure your `/etc/hosts` file contains:
```
127.0.0.1 ytabia.42.fr
```

## Build and Start All Services

```bash
# Navigate to the project directory
cd /home/x-hunter/Desktop/inception

# Clean up old containers and rebuild
make re
```

## Service Testing Commands

### 1. **Redis (Cache) - Port 6379**

**Test if Redis is running:**
```bash
docker exec -it redis redis-cli ping
```
Expected output: `PONG`

**Check Redis connection from WordPress:**
```bash
docker exec -it wordpress sh -c "apk add redis && redis-cli -h redis ping"
```
Expected output: `PONG`

**Monitor Redis activity:**
```bash
docker exec -it redis redis-cli MONITOR
```
Then visit your WordPress site to see cache operations in real-time.

**Check Redis memory usage:**
```bash
docker exec -it redis redis-cli INFO memory
```

---

### 2. **Adminer (Database GUI) - Accessible via HTTPS**

**Access URL:**
```
https://ytabia.42.fr/adminer
```

**Login Credentials:**
- **System:** MySQL
- **Server:** mariadb
- **Username:** wpuser
- **Password:** (from `/home/x-hunter/Desktop/inception/secrets/db_password.txt`)
- **Database:** wordpress

**Test from command line:**
```bash
# Check if Adminer container is running
docker ps | grep adminer

# Check Adminer PHP-FPM is listening
docker exec -it adminer netstat -tuln | grep 9000

# Test Adminer response
curl -k https://ytabia.42.fr/adminer
```

---

### 3. **FTP (File Access) - Port 21**

**FTP Credentials:**
- **Host:** localhost or ytabia.42.fr
- **Port:** 21
- **Username:** ftpuser
- **Password:** ftppass

**Test FTP connection:**
```bash
# Install FTP client if not available
sudo apt-get install ftp -y

# Connect to FTP
ftp localhost
# When prompted:
# Username: ftpuser
# Password: ftppass
```

**Test with FileZilla or command-line FTP:**
```bash
# Using lftp (better for testing)
sudo apt-get install lftp -y
lftp -u ftpuser,ftppass localhost
# Once connected, try:
ls
cd /var/www/html
ls
quit
```

**Check FTP logs:**
```bash
docker logs ftp
```

---

### 4. **Static Site (Showcase) - Port 8080 (via nginx proxy)**

**Access URL:**
```
https://ytabia.42.fr/static_site
```

**Test from command line:**
```bash
# Check if static_site container is running
docker ps | grep static_site

# Test direct access to container
docker exec -it static_site wget -O- http://localhost:8080

# Test via nginx proxy
curl -k https://ytabia.42.fr/static_site
```

**Expected output:** HTML content showing "LLM Gateway Project" showcase page

---

### 5. **Portainer (Docker Management GUI) - Port 9000**

**Note:** Portainer needs to be exposed via nginx or accessed directly. Currently not routed through nginx.

**Test if Portainer is running:**
```bash
docker ps | grep portainer

# Check if Portainer is listening
docker exec -it portainer netstat -tuln | grep 9000
```

---

## Comprehensive System Check

**Check all bonus containers are running:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(redis|adminer|ftp|static_site|portainer)"
```

**Expected output:**
```
redis          Up X minutes   6379/tcp
adminer        Up X minutes   9000/tcp
ftp            Up X minutes   0.0.0.0:21->21/tcp, 0.0.0.0:21100-21110->21100-21110/tcp
static_site    Up X minutes   8080/tcp
portainer      Up X minutes   9000/tcp
```

**Check all containers are on the same network:**
```bash
docker network inspect inception | grep -A 3 "Containers"
```

**Check nginx routing configuration:**
```bash
docker exec -it nginx cat /etc/nginx/sites-enabled/default | grep -A 5 "location"
```

---

## Browser Testing Checklist

- [ ] **Main WordPress Site:** https://ytabia.42.fr
- [ ] **Adminer (DB GUI):** https://ytabia.42.fr/adminer
- [ ] **Static Site:** https://ytabia.42.fr/static_site

---

## Troubleshooting

**If a service is not running:**
```bash
# Check container logs
docker logs <container_name>

# Rebuild specific service
docker-compose -f srcs/docker-compose.yml build <service_name>
docker-compose -f srcs/docker-compose.yml up -d <service_name>
```

**If Redis is not caching WordPress:**
```bash
# Check if WordPress has Redis object cache plugin
docker exec -it wordpress ls -la /var/www/html/wp-content/plugins/ | grep redis

# Check WordPress wp-config.php for Redis configuration
docker exec -it wordpress cat /var/www/html/wp-config.php | grep -i redis
```

**If FTP connection fails:**
```bash
# Check FTP logs
docker logs ftp

# Verify FTP user exists
docker exec -it ftp cat /etc/passwd | grep ftpuser

# Test passive mode ports are open
netstat -tuln | grep -E "(21|2110)"
```

---

## Quick Test Script

Save this as `test_bonus.sh`:

```bash
#!/bin/bash

echo "=== Testing Inception Bonus Services ==="
echo ""

echo "1. Testing Redis..."
docker exec -it redis redis-cli ping 2>/dev/null && echo "✓ Redis is working" || echo "✗ Redis failed"
echo ""

echo "2. Testing Adminer..."
curl -sk https://ytabia.42.fr/adminer | grep -q "Adminer" && echo "✓ Adminer is accessible" || echo "✗ Adminer failed"
echo ""

echo "3. Testing FTP..."
docker ps | grep -q ftp && echo "✓ FTP container is running" || echo "✗ FTP container not running"
echo ""

echo "4. Testing Static Site..."
curl -sk https://ytabia.42.fr/static_site | grep -q "LLM Gateway" && echo "✓ Static site is accessible" || echo "✗ Static site failed"
echo ""

echo "5. Testing Portainer..."
docker ps | grep -q portainer && echo "✓ Portainer container is running" || echo "✗ Portainer container not running"
echo ""

echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(redis|adminer|ftp|static_site|portainer)"
```

Make it executable and run:
```bash
chmod +x test_bonus.sh
./test_bonus.sh
```
