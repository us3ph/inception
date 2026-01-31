# Quick Test Commands - Inception Bonus Services

## 🚀 Quick Start
```bash
cd /home/x-hunter/Desktop/inception
make re  # Rebuild everything
```

## ✅ Test All Services (Automated)
```bash
./test_bonus.sh
```

## 🔍 Individual Service Tests

### 1. Redis (Cache)
```bash
# Test Redis is responding
docker exec -it redis redis-cli ping
# Expected: PONG

# Check Redis memory limit
docker exec -it redis redis-cli CONFIG GET maxmemory
# Expected: 268435456 (256MB in bytes)

# Monitor Redis activity in real-time
docker exec -it redis redis-cli MONITOR
# Then visit your WordPress site to see cache operations
```

### 2. Adminer (Database GUI)
```bash
# Test web interface
curl -sk https://ytabia.42.fr/adminer | head -10
# Should show HTML with "Adminer" in title

# Open in browser
firefox https://ytabia.42.fr/adminer
# Or: google-chrome https://ytabia.42.fr/adminer

# Login credentials:
# System: MySQL
# Server: mariadb
# Username: wpuser
# Password: (from secrets/db_password.txt)
# Database: wordpress
```

### 3. FTP (File Access)
```bash
# Check FTP container is running
docker ps | grep ftp

# Test FTP connection (command-line)
ftp localhost
# Username: ftpuser
# Password: ftppass

# Or using lftp (better for testing)
lftp -u ftpuser,ftppass localhost
ls
cd /var/www/html
ls
quit

# Check FTP logs
docker logs ftp
```

### 4. Static Site (Showcase)
```bash
# Test web interface
curl -sk https://ytabia.42.fr/static_site/
# Should show HTML with "LLM Gateway Project"

# Open in browser
firefox https://ytabia.42.fr/static_site/
# Or: google-chrome https://ytabia.42.fr/static_site/

# Check container logs
docker logs static_site
```

## 🌐 Browser URLs
- **WordPress**: https://ytabia.42.fr
- **Adminer**: https://ytabia.42.fr/adminer
- **Static Site**: https://ytabia.42.fr/static_site/

## 📊 System Status
```bash
# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check specific bonus containers
docker ps | grep -E "(redis|adminer|ftp|static_site)"

# Check network connectivity
docker network inspect inception | grep -A 3 "Containers"

# View logs for all services
docker-compose -f srcs/docker-compose.yml logs -f
```

## 🔧 Troubleshooting
```bash
# Restart a specific service
docker-compose -f srcs/docker-compose.yml restart <service_name>

# Rebuild a specific service
docker-compose -f srcs/docker-compose.yml build <service_name>
docker-compose -f srcs/docker-compose.yml up -d <service_name>

# View logs for a specific service
docker logs <container_name>

# Full cleanup and rebuild
make fclean
make all
```

## 📝 FTP Credentials
- **Host**: localhost or ytabia.42.fr
- **Port**: 21
- **Username**: ftpuser
- **Password**: ftppass

## 🔑 Adminer Credentials
- **System**: MySQL
- **Server**: mariadb
- **Username**: wpuser
- **Password**: Check `secrets/db_password.txt`
- **Database**: wordpress

## ✨ Expected Results
All commands should complete successfully:
- ✅ Redis: PONG response
- ✅ Adminer: Login page visible
- ✅ FTP: Connection successful, can browse /var/www/html
- ✅ Static Site: Showcase page visible with "LLM Gateway Project"
