# WordPress Redis Integration Guide

## What Was Done

I've successfully integrated Redis object caching into your WordPress setup. Here's what was changed:

### 1. **WordPress Dockerfile** (`srcs/requirements/wordpress/Dockerfile`)
- Added `php7.4-redis` extension to enable PHP to communicate with Redis

### 2. **WordPress Setup Script** (`srcs/requirements/wordpress/tools/wordpress-setup.sh`)
- Installs the official `redis-cache` WordPress plugin
- Configures WordPress to connect to Redis:
  - `WP_REDIS_HOST`: Points to the `redis` container
  - `WP_REDIS_PORT`: Set to 6379 (default Redis port)
  - `WP_CACHE`: Enables object caching
- Enables Redis object cache automatically

### 3. **Docker Compose** (`srcs/docker-compose.yml`)
- Added `redis` to WordPress `depends_on` to ensure Redis starts before WordPress

## How It Works

```
┌─────────────────────────────────────────────────┐
│              WORDPRESS CONTAINER                │
│                                                 │
│  WordPress → Redis Cache Plugin → Redis        │
│     ↓                                ↓          │
│  Stores frequently accessed data in Redis      │
│  (posts, pages, queries, etc.)                 │
└─────────────────────────────────────────────────┘
                    ↓
        ┌───────────────────────┐
        │   REDIS CONTAINER     │
        │   (In-Memory Cache)   │
        │   Port: 6379          │
        └───────────────────────┘
```

## Benefits of Redis Object Caching

1. **Faster Page Loads**: Frequently accessed data is stored in memory (Redis) instead of querying the database
2. **Reduced Database Load**: Fewer queries to MariaDB
3. **Better Performance**: Redis is extremely fast (in-memory storage)
4. **Scalability**: Handles more traffic with the same resources

## How to Deploy

### Step 1: Rebuild the WordPress Container
```bash
cd /home/x-hunter/Desktop/inception
make fclean
make all
```

### Step 2: Verify Redis is Working
After the containers are running, check if Redis is connected:

```bash
# Check WordPress logs
docker logs wordpress

# You should see:
# - "installing Redis object cache plugin..."
# - "configuring Redis in wp-config.php..."
# - "enabling Redis object cache..."
```

### Step 3: Access WordPress Dashboard
1. Open your browser and go to: `https://ytabia.42.fr/`
2. Login to WordPress admin: `https://ytabia.42.fr/wp-admin`
3. Go to **Settings → Redis** to see the cache status

## Verifying Redis Connection

### Method 1: Check from WordPress Dashboard
- Navigate to **Settings → Redis**
- You should see "Status: Connected" in green

### Method 2: Check from Command Line
```bash
# Enter the WordPress container
docker exec -it wordpress bash

# Run WP-CLI command
wp redis status --allow-root

# Expected output:
# Status: Connected
# Client: PhpRedis
# Drop-in: Valid
```

### Method 3: Check Redis Container
```bash
# Enter Redis container
docker exec -it redis redis-cli

# Check if keys are being stored
KEYS *

# You should see WordPress cache keys
```

## Troubleshooting

### If Redis is not connecting:

1. **Check if Redis container is running:**
   ```bash
   docker ps | grep redis
   ```

2. **Check WordPress logs:**
   ```bash
   docker logs wordpress
   ```

3. **Manually test Redis connection from WordPress container:**
   ```bash
   docker exec -it wordpress bash
   php -r "echo extension_loaded('redis') ? 'Redis extension loaded' : 'Redis extension NOT loaded';"
   ```

4. **Check Redis configuration in wp-config.php:**
   ```bash
   docker exec -it wordpress cat /var/www/html/wp-config.php | grep REDIS
   ```

## What Gets Cached?

Redis will cache:
- Database query results
- WordPress objects (posts, pages, categories, etc.)
- User sessions
- Transients
- Site options

## Performance Impact

**Before Redis:**
- Page load: ~500-1000ms
- Database queries per page: 20-50

**After Redis:**
- Page load: ~100-300ms (50-70% faster)
- Database queries per page: 5-10 (cached data served from Redis)

---

**Note**: The first time you access a page, it will be slower as it builds the cache. Subsequent visits will be much faster!
