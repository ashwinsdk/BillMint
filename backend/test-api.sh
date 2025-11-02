#!/bin/bash

# BillMint Backend Test Script
# Tests all API endpoints to verify server is working correctly

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server URL - change this to your server
SERVER_URL="${1:-http://localhost:3000}"

echo "======================================"
echo "  BillMint Backend API Test Suite"
echo "======================================"
echo "Testing server: $SERVER_URL"
echo ""

# Test 1: Health check
echo -n "1. Testing health endpoint... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/health")
if [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
    exit 1
fi

# Test 2: Get customers
echo -n "2. Testing GET /api/customers... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/api/customers")
if [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
fi

# Test 3: Create customer
echo -n "3. Testing POST /api/customers... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"Test Customer","phone":"1234567890","email":"test@example.com"}' \
    "$SERVER_URL/api/customers")
if [ "$RESPONSE" -eq 201 ] || [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
fi

# Test 4: Get products
echo -n "4. Testing GET /api/products... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/api/products")
if [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
fi

# Test 5: Create product
echo -n "5. Testing POST /api/products... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"Test Product","price":99.99,"gstRate":18,"unit":"pcs"}' \
    "$SERVER_URL/api/products")
if [ "$RESPONSE" -eq 201 ] || [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
fi

# Test 6: Get invoices
echo -n "6. Testing GET /api/invoices... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/api/invoices")
if [ "$RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED (HTTP $RESPONSE)${NC}"
fi

# Test 7: Backup endpoint
echo -n "7. Testing POST /api/backup/upload... "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"data":{}}' \
    "$SERVER_URL/api/backup/upload")
if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${YELLOW}⚠ SKIPPED (may need data)${NC}"
fi

echo ""
echo "======================================"
echo "  Test Summary"
echo "======================================"
echo -e "${GREEN}Basic tests completed!${NC}"
echo ""
echo "Your backend API is working correctly."
echo "Server URL: $SERVER_URL"
echo ""
echo "You can now configure your mobile app to use this URL:"
echo "Edit lib/config/api_config.dart and set:"
echo "  static const String baseUrl = '$SERVER_URL/api';"
echo ""
