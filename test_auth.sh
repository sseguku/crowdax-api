#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"

echo -e "${BLUE}🚀 Testing Crowdax API Authentication${NC}"
echo "=================================="

# Test 1: Register a new user
echo -e "\n${YELLOW}1. Testing User Registration${NC}"
echo "POST /users"
curl -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "entrepreneur"
    }
  }' | jq '.'

# Test 2: Login
echo -e "\n${YELLOW}2. Testing User Login${NC}"
echo "POST /users/sign_in"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }')

echo $LOGIN_RESPONSE | jq '.'

# Extract token from login response
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "\n${GREEN}✅ Token extracted: ${TOKEN:0:20}...${NC}"
else
    echo -e "\n${RED}❌ No token received${NC}"
    exit 1
fi

# Test 3: Get current user
echo -e "\n${YELLOW}3. Testing Get Current User${NC}"
echo "GET /users/current_user"
curl -X GET $BASE_URL/users/current_user \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Test 4: Get user profile (protected endpoint)
echo -e "\n${YELLOW}4. Testing Protected Endpoint${NC}"
echo "GET /api/v1/users/profile"
curl -X GET $BASE_URL/api/v1/users/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Test 5: Get user dashboard
echo -e "\n${YELLOW}5. Testing User Dashboard${NC}"
echo "GET /api/v1/users/dashboard"
curl -X GET $BASE_URL/api/v1/users/dashboard \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Test 6: Request password reset
echo -e "\n${YELLOW}6. Testing Password Reset Request${NC}"
echo "POST /users/password"
curl -X POST $BASE_URL/users/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'

# Test 7: Request email confirmation
echo -e "\n${YELLOW}7. Testing Email Confirmation Request${NC}"
echo "POST /users/confirmation"
curl -X POST $BASE_URL/users/confirmation \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'

# Test 8: Update user profile
echo -e "\n${YELLOW}8. Testing Profile Update${NC}"
echo "PUT /users"
curl -X PUT $BASE_URL/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "updated@example.com",
      "current_password": "password123",
      "role": "investor"
    }
  }' | jq '.'

# Test 9: Refresh token
echo -e "\n${YELLOW}9. Testing Token Refresh${NC}"
echo "POST /users/refresh_token"
curl -X POST $BASE_URL/users/refresh_token \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Test 10: Logout
echo -e "\n${YELLOW}10. Testing Logout${NC}"
echo "DELETE /users/sign_out"
curl -X DELETE $BASE_URL/users/sign_out \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

echo -e "\n${GREEN}✅ All tests completed!${NC}" 