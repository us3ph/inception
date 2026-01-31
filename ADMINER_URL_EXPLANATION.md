# Adminer Download URLs Explained

## The Question

Why did we change from:
```bash
wget "https://www.adminer.org" -O /var/www/html/index.php
```

To:
```bash
wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php
```

## The Answer

### ❌ Wrong URL: `https://www.adminer.org`

This downloads the **HTML homepage** of the Adminer website, NOT the PHP application.

**What you get:**
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Adminer - Database management in a single PHP file</title>
    ...
  </head>
  <body>
    <!-- Website content -->
  </body>
</html>
```

**Result**: Your browser would show the Adminer marketing website, not the database management tool!

---

### ✅ Correct URL: `https://www.adminer.org/latest.php`

This downloads the **actual Adminer PHP application** (the latest version).

**What you get:**
```php
<?php
/** Adminer - Compact database management
* @link https://www.adminer.org/
* @author Jakub Vrana, https://www.vrana.cz/
* @copyright 2007 Jakub Vrana
...
// Actual PHP code for database management
```

**Result**: A working database management interface!

---

## Alternative Download Options

### Option 1: Official Latest Version (Recommended) ✅
```bash
wget "https://www.adminer.org/latest.php" -O index.php
```
**Pros:**
- Always gets the latest version
- Official source
- Simple URL

**Cons:**
- Version changes over time (not deterministic)

---

### Option 2: Specific GitHub Release
```bash
wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O index.php
```
**Pros:**
- Specific version (deterministic)
- Good for production (version control)

**Cons:**
- Need to manually update version number
- Longer URL

---

### Option 3: Latest MySQL-only Version
```bash
wget "https://www.adminer.org/latest-mysql.php" -O index.php
```
**Pros:**
- Smaller file size (~200KB vs ~500KB)
- Only includes MySQL/MariaDB support

**Cons:**
- Can't manage other database types

---

## Which Should You Use?

### For Inception Project: Use `latest.php` ✅

**Reason:**
```bash
wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php
```

1. **Official source**: From Adminer's official website
2. **Always up-to-date**: Gets the latest stable version
3. **Simple**: Easy to remember and maintain
4. **Supports all databases**: Full feature set

---

## Testing the URLs

### Test 1: Check what you're downloading
```bash
# Wrong URL (downloads HTML)
curl -sL "https://www.adminer.org" | head -5
# Output: <!DOCTYPE html>

# Correct URL (downloads PHP)
curl -sL "https://www.adminer.org/latest.php" | head -5
# Output: <?php
```

### Test 2: Check file size
```bash
# HTML homepage (small)
curl -sL "https://www.adminer.org" | wc -c
# ~15KB (just the website)

# PHP application (larger)
curl -sL "https://www.adminer.org/latest.php" | wc -c
# ~500KB (the actual application)
```

---

## Summary

| URL | Type | Size | Works? |
|-----|------|------|--------|
| `https://www.adminer.org` | HTML Website | ~15KB | ❌ No |
| `https://www.adminer.org/latest.php` | PHP App | ~500KB | ✅ Yes |
| `https://www.adminer.org/latest-mysql.php` | PHP App (MySQL only) | ~200KB | ✅ Yes |
| `https://github.com/.../adminer-4.8.1.php` | PHP App (specific version) | ~500KB | ✅ Yes |

---

## Current Configuration

Your Dockerfile now uses:
```dockerfile
RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php && \
    chmod 644 /var/www/html/index.php
```

This will:
1. ✅ Download the actual PHP application
2. ✅ Save it as `index.php`
3. ✅ Set proper permissions (readable by web server)
4. ✅ Work when you access `https://ytabia.42.fr/adminer`

---

**Bottom Line**: You were right to question it! The original URL (`https://www.adminer.org`) was wrong. The correct official URL is `https://www.adminer.org/latest.php`. 🎯
