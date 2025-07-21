#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"

echo -e "${BLUE}🔐 Getting Bearer Token and Listing Users${NC}"
echo "=============================================="

# Step 1: Login to get token
echo -e "\n${YELLOW}1. Logging in to get Bearer token...${NC}"
echo "POST /users/sign_in"

LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "admin@example.com",
      "password": "password123"
    }
  }')

echo $LOGIN_RESPONSE | jq '.'

# Extract token from login response
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "\n${GREEN}✅ Token extracted successfully!${NC}"
    echo -e "${BLUE}Token: ${TOKEN:0:50}...${NC}"
else
    echo -e "\n${RED}❌ Failed to extract token${NC}"
    echo -e "${RED}Response: $LOGIN_RESPONSE${NC}"
    exit 1
fi

# Step 2: Use token to get all users
echo -e "\n${YELLOW}2. Getting all users with Bearer token...${NC}"
echo "GET /api/v1/admin/users"

USERS_RESPONSE=$(curl -s -X GET $BASE_URL/api/v1/admin/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo $USERS_RESPONSE | jq '.'

# Step 3: Alternative - Get users from general endpoint
echo -e "\n${YELLOW}3. Getting users from general endpoint...${NC}"
echo "GET /api/v1/users"

GENERAL_USERS_RESPONSE=$(curl -s -X GET $BASE_URL/api/v1/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo $GENERAL_USERS_RESPONSE | jq '.'

# Step 4: Get entrepreneurs specifically
echo -e "\n${YELLOW}4. Getting entrepreneurs only...${NC}"
echo "GET /api/v1/admin/entrepreneurs"

ENTREPRENEURS_RESPONSE=$(curl -s -X GET $BASE_URL/api/v1/admin/entrepreneurs \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo $ENTREPRENEURS_RESPONSE | jq '.'

# Step 5: Get investors specifically
echo -e "\n${YELLOW}5. Getting investors only...${NC}"
echo "GET /api/v1/admin/investors"

INVESTORS_RESPONSE=$(curl -s -X GET $BASE_URL/api/v1/admin/investors \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo $INVESTORS_RESPONSE | jq '.'

echo -e "\n${GREEN}✅ All user listing tests completed!${NC}"
echo -e "${BLUE}Your Bearer token: Bearer $TOKEN${NC}" 