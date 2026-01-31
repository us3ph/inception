# Adminer Integration with Nginx

## Overview

Adminer is a lightweight database management tool (similar to phpMyAdmin) that allows you to manage your MariaDB database through a web interface.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    USER'S BROWSER                       │
│                                                         │
│  https://ytabia.42.fr/adminer                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                  NGINX CONTAINER                        │
│                  (Port 443 - HTTPS)                     │
│                                                         │
│  Location Blocks:                                       │
│  ┌──────────────────────────────────────────┐          │
│  │ /adminer → adminer:9000                  │          │
│  │ /*.php   → wordpress:9000                │          │
│  │ /        → wordpress files               │          │
│  └──────────────────────────────────────────┘          │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ↓                         ↓
┌──────────────────┐    ┌──────────────────┐
│    ADMINER       │    │   WORDPRESS      │
│  Container       │    │   Container      │
│  (Port 9000)     │    │   (Port 9000)    │
│                  │    │                  │
│  PHP-FPM         │    │   PHP-FPM        │
│  Adminer.php     │    │   WordPress      │
└────────┬─────────┘    └──────────────────┘
         │
         ↓
┌──────────────────┐
│    MARIADB       │
│  Container       │
│  (Port 3306)     │
└──────────────────┘
```

## What Was Configured

### 1. **Nginx Configuration** (`srcs/requirements/nginx/conf/nginx.conf`)

Added a new location block for Adminer:

```nginx
location /adminer {
    # Rewrite rules to remove /adminer prefix
    rewrite ^/adminer(/.*)$ $1 break;
    rewrite ^/adminer$ / break;

    # Send requests to adminer container on port 9000
    fastcgi_pass adminer:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/html/index.php;
    fastcgi_param SCRIPT_NAME /adminer/index.php;
}
```

**How it works:**
- When you visit `https://ytabia.42.fr/adminer`, Nginx intercepts the request
- The rewrite rules strip the `/adminer` prefix
- The request is forwarded to the `adminer` container on port 9000
- PHP-FPM in the adminer container executes the Adminer PHP file
- The result is sent back through Nginx to your browser

### 2. **Adminer Dockerfile** (`srcs/requirements/bonus/adminer/Dockerfile`)

Fixed and completed the Dockerfile:

**Key Changes:**
- ✅ Fixed typo: `alphine` → `alpine`
- ✅ Fixed command: `update` → `apk update`
- ✅ Used proper Adminer download URL (GitHub release)
- ✅ Fixed PHP-FPM config path: `/etc/php81/php-fpm.d/www.conf`
- ✅ Added `EXPOSE 9000` to expose the PHP-FPM port
- ✅ Added `CMD` to start PHP-FPM in foreground mode

## How to Access Adminer

### Step 1: Rebuild and Deploy

```bash
cd /home/x-hunter/Desktop/inception
make fclean
make all
```

### Step 2: Access Adminer

Open your browser and navigate to:
```
https://ytabia.42.fr/adminer
```

### Step 3: Login to Adminer

You'll see a login form. Use these credentials:

- **System**: MySQL
- **Server**: `mariadb` (the container name)
- **Username**: `wpuser` (from your .env file: MYSQL_USER)
- **Password**: The password from `/secrets/db_password.txt`
- **Database**: `wordpress` (from your .env file: MYSQL_DATABASE)

## Understanding the Routing

### Request Flow:

1. **User visits**: `https://ytabia.42.fr/adminer`
2. **Nginx receives** the HTTPS request on port 443
3. **Location matching**: Nginx checks location blocks in order:
   - ✅ Matches `/adminer` → routes to adminer container
   - ❌ Doesn't match `~ \.php$` (not a .php file in URL)
   - ❌ Doesn't match `/` (more specific match found)
4. **FastCGI pass**: Nginx forwards to `adminer:9000`
5. **PHP-FPM executes**: Adminer container runs the PHP code
6. **Response**: HTML is sent back through Nginx to the browser

### Why This Order Matters:

```nginx
# Order of location blocks:
location / { ... }              # Priority: Low (catches everything)
location /adminer { ... }       # Priority: Medium (exact prefix match)
location ~ \.php$ { ... }       # Priority: High (regex match)
```

Nginx processes locations in this order:
1. Exact matches (`=`)
2. Prefix matches (longest match wins)
3. Regex matches (`~` or `~*`)
4. Default location (`/`)

Since `/adminer` is a prefix match and appears before the general PHP handler, it takes precedence for `/adminer` URLs.

## Troubleshooting

### Issue 1: "502 Bad Gateway" when accessing /adminer

**Cause**: Adminer container is not running or PHP-FPM is not listening

**Solution**:
```bash
# Check if adminer container is running
docker ps | grep adminer

# Check adminer logs
docker logs adminer

# Verify PHP-FPM is listening
docker exec -it adminer netstat -tuln | grep 9000
```

### Issue 2: Adminer shows but can't connect to database

**Cause**: Wrong database credentials or MariaDB is not accessible

**Solution**:
```bash
# Check if MariaDB is running
docker ps | grep mariadb

# Test connection from adminer container
docker exec -it adminer ping mariadb

# Verify database credentials
cat /home/x-hunter/Desktop/inception/secrets/db_password.txt
```

### Issue 3: Nginx shows "File not found"

**Cause**: Adminer PHP file is not downloaded or in wrong location

**Solution**:
```bash
# Check if adminer file exists
docker exec -it adminer ls -la /var/www/html/

# Should show: index.php
```

## Security Considerations

⚠️ **Important**: Adminer is a powerful tool that gives full access to your database!

**Best Practices:**
1. **Don't expose in production** without authentication
2. **Use strong passwords** for database users
3. **Consider IP whitelisting** in Nginx
4. **Monitor access logs** for suspicious activity

### Optional: Add Basic Authentication

To add an extra layer of security, you can add HTTP Basic Auth to the `/adminer` location:

```nginx
location /adminer {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    # ... rest of the configuration
}
```

## Testing the Setup

### Test 1: Verify Nginx can reach Adminer

```bash
# From your host machine
curl -k https://ytabia.42.fr/adminer

# Should return HTML with "Login - Adminer"
```

### Test 2: Check PHP-FPM is running

```bash
docker exec -it adminer ps aux | grep php-fpm

# Should show php-fpm81 processes
```

### Test 3: Verify network connectivity

```bash
# Adminer should be able to reach MariaDB
docker exec -it adminer ping -c 3 mariadb

# Should show successful pings
```

## What You Can Do with Adminer

Once logged in, you can:
- 📊 **Browse tables**: View WordPress database structure
- ✏️ **Edit data**: Modify posts, users, settings
- 🔍 **Run SQL queries**: Execute custom SQL commands
- 📥 **Export database**: Create backups
- 📤 **Import data**: Restore from backups
- 🔧 **Manage users**: Create/modify database users
- 📈 **View statistics**: Check table sizes, indexes

## Comparison: Adminer vs phpMyAdmin

| Feature | Adminer | phpMyAdmin |
|---------|---------|------------|
| Size | ~500 KB (single file) | ~10 MB |
| Speed | Fast | Slower |
| Features | Essential | Comprehensive |
| Setup | Simple | Complex |
| Memory | Low | Higher |

**Adminer is perfect for Inception project** because:
- ✅ Lightweight (bonus requirement)
- ✅ Easy to deploy (single PHP file)
- ✅ Sufficient features for database management
- ✅ Less resource intensive

---

**Access URL**: `https://ytabia.42.fr/adminer`

**Default Credentials**:
- Server: `mariadb`
- Username: `wpuser`
- Password: (from secrets file)
- Database: `wordpress`
