#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  Inception Bonus Services Test Suite"
echo "========================================="
echo ""

# Test counter
PASSED=0
FAILED=0

# Function to test and report
test_service() {
    local name=$1
    local command=$2
    local expected=$3

    echo -n "Testing $name... "
    result=$(eval "$command" 2>&1)

    if echo "$result" | grep -q "$expected"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAILED++))
        return 1
    fi
}

echo "=== 1. REDIS (Cache) ==="
test_service "Redis ping" \
    "docker exec -it redis redis-cli ping 2>/dev/null" \
    "PONG"

test_service "Redis connection from WordPress" \
    "docker exec -it wordpress sh -c 'apk add redis 2>/dev/null && redis-cli -h redis ping 2>/dev/null'" \
    "PONG"

test_service "Redis memory configuration" \
    "docker exec -it redis redis-cli CONFIG GET maxmemory 2>/dev/null" \
    "256mb"

echo ""
echo "=== 2. ADMINER (Database GUI) ==="
test_service "Adminer web interface" \
    "curl -sk https://ytabia.42.fr/adminer" \
    "Adminer"

test_service "Adminer container running" \
    "docker ps | grep adminer" \
    "adminer"

test_service "Adminer PHP-FPM listening" \
    "docker exec -it adminer sh -c 'apk add net-tools 2>/dev/null && netstat -tuln | grep 9000'" \
    "9000"

echo ""
echo "=== 3. FTP (File Access) ==="
test_service "FTP container running" \
    "docker ps | grep ftp" \
    "ftp"

test_service "FTP port 21 exposed" \
    "docker ps | grep ftp" \
    "21->21"

test_service "FTP passive ports exposed" \
    "docker ps | grep ftp" \
    "21100-21110"

test_service "FTP user exists" \
    "docker exec -it ftp cat /etc/passwd 2>/dev/null" \
    "ftpuser"

echo ""
echo "=== 4. STATIC SITE (Showcase) ==="
test_service "Static site web interface" \
    "curl -sk https://ytabia.42.fr/static_site/" \
    "LLM Gateway Project"

test_service "Static site container running" \
    "docker ps | grep static_site" \
    "static_site"

test_service "Static site nginx listening" \
    "docker exec -it static_site sh -c 'apk add net-tools 2>/dev/null && netstat -tuln | grep 8080'" \
    "8080"

echo ""
echo "=== 5. NETWORK CONNECTIVITY ==="
test_service "All containers on inception network" \
    "docker network inspect inception 2>/dev/null | grep -c 'Name.*redis\\|Name.*adminer\\|Name.*ftp\\|Name.*static_site'" \
    "4"

test_service "Redis reachable from nginx" \
    "docker exec -it nginx sh -c 'apt-get update -qq && apt-get install -y -qq netcat && nc -zv redis 6379 2>&1'" \
    "succeeded"

echo ""
echo "========================================="
echo "  Test Summary"
echo "========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All bonus services are working correctly!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed. Please review the output above.${NC}"
    exit 1
fi
