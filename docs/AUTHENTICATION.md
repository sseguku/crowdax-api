# Token-Based Authentication API

This API uses JWT (JSON Web Tokens) for authentication. All protected endpoints require a valid token in the Authorization header.

## Quick Start Guide

### 1. Start the Rails Server

```bash
cd /path/to/crowdax-api
rails server -p 3000
```

### 2. Get a Bearer Token

```bash
# Login to get your Bearer token
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "admin@example.com",
      "password": "password123"
    }
  }'
```

### 3. Use the Token

```bash
# Extract the token from the response and use it
curl -X GET http://localhost:3000/api/v1/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

### 4. Test with Provided Script

```bash
# Make the script executable and run it
chmod +x get_users.sh
./get_users.sh
```

## Table of Contents

- [Quick Start Guide](#quick-start-guide)
- [Authentication Endpoints](#authentication-endpoints)
- [Getting Bearer Tokens](#getting-bearer-tokens)
- [Protected API Endpoints](#protected-api-endpoints)
- [User Management Endpoints](#user-management-endpoints)
- [Error Responses](#error-responses)
- [Client Examples](#client-examples)
- [Testing the API](#testing-the-api)

## Authentication Endpoints

### 1. Register

**POST** `/users`

Request body:

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "entrepreneur"
  }
}
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Account created successfully. Please check your email to confirm your account."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "entrepreneur",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    }
  }
}
```

### 2. Login

**POST** `/users/sign_in`

Request body:

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Logged in successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "entrepreneur",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 3. Logout

**DELETE** `/users/sign_out`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Logged out successfully."
  }
}
```

### 4. Get Current User

**GET** `/users/current_user`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "User authenticated."
  },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "role": "entrepreneur",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "created_date": "01/01/2024"
  }
}
```

### 5. Refresh Token

**POST** `/users/refresh_token`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Token refreshed successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "entrepreneur",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 6. Request Password Reset

**POST** `/users/password`

Request body:

```json
{
  "user": {
    "email": "user@example.com"
  }
}
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Password reset instructions have been sent to your email."
  }
}
```

### 7. Reset Password

**PUT** `/users/password`

Request body:

```json
{
  "user": {
    "reset_password_token": "reset_token_from_email",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
  }
}
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Password updated successfully."
  }
}
```

### 8. Confirm Email

**GET** `/users/confirmation?confirmation_token=<token>`

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Email confirmed successfully."
  }
}
```

## Getting Bearer Tokens

### Step-by-Step Process

1. **Login to Get Token**

   ```bash
   curl -X POST http://localhost:3000/users/sign_in \
     -H "Content-Type: application/json" \
     -d '{
       "user": {
         "email": "admin@example.com",
         "password": "password123"
       }
     }'
   ```

2. **Extract Token from Response**
   The response will contain a `token` field in the `data` object:

   ```json
   {
     "status": {
       "code": 200,
       "message": "Logged in successfully."
     },
     "data": {
       "user": { ... },
       "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzM0NTY3ODk5fQ..."
     }
   }
   ```

3. **Use Token in Requests**
   ```bash
   curl -X GET http://localhost:3000/api/v1/admin/users \
     -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzM0NTY3ODk5fQ..." \
     -H "Content-Type: application/json"
   ```

### Available Test Users

For testing purposes, these users are available:

| Email                  | Password      | Role         | Description       |
| ---------------------- | ------------- | ------------ | ----------------- |
| `admin@example.com`    | `password123` | admin        | Full admin access |
| `test@example.com`     | `password123` | entrepreneur | Entrepreneur user |
| `investor@example.com` | `password123` | investor     | Investor user     |
| `visitor@example.com`  | `password123` | visitor      | Visitor user      |

### Token Management

- **Expiration**: Tokens expire after 24 hours
- **Refresh**: Use `/users/refresh_token` to get a new token
- **Logout**: Use `/users/sign_out` to invalidate the token
- **Security**: Store tokens securely and never expose them in client-side code

## Public Registration Endpoints (No Authentication Required)

### Entrepreneur Registration

**POST** `/api/v1/public/entrepreneur_registration`

Request body:

```json
{
  "user": {
    "email": "founder@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "Jane",
    "last_name": "Doe",
    "phone_number": "+256123456789",
    "company_name": "InnovateX",
    "industry": "technology",
    "business_stage": "growth_stage",
    "founded_date": "2021-01-01",
    "website": "https://innovatex.com",
    "business_description": "AI-powered logistics platform.",
    "problem_being_solved": "Inefficient supply chains",
    "target_market": "East Africa",
    "competitive_advantage": "Proprietary AI algorithms",
    "funding_amount_needed": 500000,
    "funding_purpose": "Product development and marketing",
    "current_annual_revenue_min": 100000,
    "current_annual_revenue_max": 200000,
    "projected_annual_revenue_min": 300000,
    "projected_annual_revenue_max": 600000,
    "team_size_min": 5,
    "team_size_max": 10,
    "number_of_co_founders": 2,
    "tin": "123456789",
    "legal_structure": "limited_liability_company"
  }
}
```

Response (success):

```json
{
  "status": {
    "code": 200,
    "message": "Entrepreneur registration successful. Please check your email to confirm your account."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "founder@example.com",
      "role": "entrepreneur",
      "first_name": "Jane",
      "last_name": "Doe",
      "company_name": "InnovateX",
      ...
    }
  }
}
```

### Investor Registration

**POST** `/api/v1/public/investor_registration`

Request body:

```json
{
  "user": {
    "email": "investor@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "John",
    "last_name": "Smith",
    "phone_number": "+256987654321",
    "company_name": "Smith Capital",
    "job_title": "Managing Partner",
    "industry": "finance",
    "years_of_experience_min": 5,
    "years_of_experience_max": 10,
    "typical_investment_amount_min": 10000,
    "typical_investment_amount_max": 50000,
    "investment_frequency": "annually",
    "preferred_industries": "technology,healthcare",
    "preferred_investment_stages": "growth_stage,scaling",
    "annual_income_min": 100000,
    "annual_income_max": 200000,
    "net_worth_min": 500000,
    "net_worth_max": 1000000,
    "accredited_investor": true,
    "risk_tolerance": "moderate",
    "previous_investment_experience": "Angel investor in 5 startups",
    "investment_goals": "Long-term growth",
    "minimum_investment": 10000,
    "maximum_investment": 100000,
    "terms_of_service_accepted": true,
    "privacy_policy_accepted": true
  }
}
```

Response (success):

```json
{
  "status": {
    "code": 200,
    "message": "Investor registration successful. Please check your email to confirm your account."
  },
  "data": {
    "user": {
      "id": 2,
      "email": "investor@example.com",
      "role": "investor",
      "first_name": "John",
      "last_name": "Smith",
      "company_name": "Smith Capital",
      ...
    }
  }
}
```

#### Notes

- All fields marked above are required unless otherwise specified by the frontend.
- These endpoints are public and do **not** require authentication.
- Validation errors will return a 422 status and a list of errors.
- For the full list of allowed values for fields like `industry`, `business_stage`, `legal_structure`, etc., use the `/api/v1/public/metadata` endpoint.

## Protected API Endpoints

All API endpoints under `/api/v1/` require authentication.

### User Profile Management

**GET** `/api/v1/users/profile`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Profile retrieved successfully."
  },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "role": "entrepreneur",
    "profile": {
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+256123456789",
      "address": "Kampala, Uganda"
    }
  }
}
```

**PUT** `/api/v1/users/profile`

Headers:

```
Authorization: Bearer <token>
Content-Type: application/json
```

Request body:

```json
{
  "user": {
    "profile": {
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+256123456789",
      "address": "Kampala, Uganda"
    }
  }
}
```

### User Dashboard

**GET** `/api/v1/users/dashboard`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Dashboard data retrieved successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "entrepreneur"
    },
    "stats": {
      "total_campaigns": 5,
      "active_campaigns": 2,
      "total_investments": 15000000,
      "pending_kyc": false
    },
    "recent_activity": [
      {
        "id": 1,
        "type": "campaign_created",
        "description": "Created new campaign: Tech Startup Funding",
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

### KYC Management

**GET** `/api/v1/kycs`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "KYC records retrieved successfully."
  },
  "data": [
    {
      "id": 1,
      "status": "approved",
      "submitted_at": "2024-01-01T00:00:00.000Z",
      "approved_at": "2024-01-02T00:00:00.000Z"
    }
  ]
}
```

**POST** `/api/v1/kycs`

Headers:

```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

Request body (multipart form):

```
kyc[document_type]: national_id
kyc[document]: [file upload]
kyc[additional_info]: Additional verification information
```

### Campaign Management

**GET** `/api/v1/campaigns`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Campaigns retrieved successfully."
  },
  "data": [
    {
      "id": 1,
      "title": "Tech Startup Funding",
      "description": "Funding for innovative tech solutions",
      "target_amount": 50000000,
      "current_amount": 25000000,
      "status": "active",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**POST** `/api/v1/campaigns`

Headers:

```
Authorization: Bearer <token>
Content-Type: application/json
```

Request body:

```json
{
  "campaign": {
    "title": "Tech Startup Funding",
    "description": "Funding for innovative tech solutions",
    "target_amount": 50000000,
    "category": "technology",
    "duration_days": 30
  }
}
```

### Public Endpoints (No Authentication Required)

**GET** `/api/v1/public/campaigns`

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Public campaigns retrieved successfully."
  },
  "data": [
    {
      "id": 1,
      "title": "Tech Startup Funding",
      "description": "Funding for innovative tech solutions",
      "target_amount": 50000000,
      "current_amount": 25000000,
      "status": "active",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**GET** `/api/v1/public/statistics`

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Statistics retrieved successfully."
  },
  "data": {
    "total_campaigns": 150,
    "total_investments": 2500000000,
    "active_campaigns": 45,
    "total_users": 1200
  }
}
```

## User Management Endpoints

### Admin User Management (Admin Access Required)

#### 1. List All Users

**GET** `/api/v1/admin/users`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Users list retrieved successfully"
  },
  "data": [
    {
      "id": 1,
      "email": "admin@example.com",
      "role": "admin",
      "first_name": "Admin",
      "last_name": "User",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### 2. Get Specific User

**GET** `/api/v1/admin/users/:id`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "User details retrieved successfully"
  },
  "data": {
    "id": 1,
    "email": "admin@example.com",
    "role": "admin",
    "first_name": "Admin",
    "last_name": "User",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### 3. Update User

**PUT** `/api/v1/admin/users/:id`

Headers:

```
Authorization: Bearer <token>
Content-Type: application/json
```

Request body:

```json
{
  "user": {
    "email": "updated@example.com",
    "role": "investor"
  }
}
```

#### 4. Delete User

**DELETE** `/api/v1/admin/users/:id`

Headers:

```
Authorization: Bearer <token>
```

#### 5. Export Users Data

**GET** `/api/v1/admin/export_users`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Users data exported successfully"
  },
  "data": {
    "total_count": 5,
    "users": [...],
    "exported_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### Role-Specific User Management

#### Entrepreneurs Management

**GET** `/api/v1/admin/entrepreneurs`

Query Parameters:

- `status`: Filter by KYC status (`kyc_verified`, `kyc_pending`, `kyc_rejected`, `no_kyc`)
- `has_campaigns`: Filter by campaign status (`true`, `false`)

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Entrepreneurs retrieved successfully."
  },
  "data": [
    {
      "id": 2,
      "email": "founder@example.com",
      "role": "entrepreneur",
      "first_name": "Jane",
      "last_name": "Doe",
      "company_name": "InnovateX",
      "industry": "technology",
      "kyc_status": "approved",
      "campaigns_count": 2
    }
  ]
}
```

#### Investors Management

**GET** `/api/v1/admin/investors`

Query Parameters:

- `investment_status`: Filter by investment status (`has_investments`, `no_investments`, `confirmed_investments`)
- `min_investment`: Filter by minimum investment amount

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Investors retrieved successfully."
  },
  "data": [
    {
      "id": 3,
      "email": "investor@example.com",
      "role": "investor",
      "first_name": "John",
      "last_name": "Smith",
      "company_name": "Smith Capital",
      "total_invested": 500000,
      "investments_count": 3
    }
  ]
}
```

### General User Endpoints

#### List All Users (Admin Only)

**GET** `/api/v1/users`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Users retrieved successfully."
  },
  "data": [
    {
      "id": 1,
      "email": "admin@example.com",
      "role": "admin",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Access Control

- **Admin Users**: Can access all user management endpoints
- **Backadmin Users**: Can access most user management endpoints
- **Regular Users**: Can only access their own profile and data
- **Unauthenticated**: Cannot access any protected endpoints

## Error Responses

### Authentication Errors

**401 Unauthorized**

```json
{
  "status": {
    "code": 401,
    "message": "You need to sign in or sign up before continuing."
  }
}
```

**422 Unprocessable Entity**

```json
{
  "status": {
    "code": 422,
    "message": "Invalid email or password."
  },
  "errors": {
    "email": ["is invalid"],
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

### Validation Errors

**422 Unprocessable Entity**

```json
{
  "status": {
    "code": 422,
    "message": "Validation failed."
  },
  "errors": {
    "title": ["can't be blank"],
    "target_amount": ["must be greater than 0"]
  }
}
```

### Not Found Errors

**404 Not Found**

```json
{
  "status": {
    "code": 404,
    "message": "Resource not found."
  }
}
```

## Client Examples

### JavaScript/Fetch API

#### Complete Authentication Flow

```javascript
class CrowdaxAPI {
  constructor(baseURL = "http://localhost:3000") {
    this.baseURL = baseURL;
    this.token = null;
  }

  // Login and get token
  async login(email, password) {
    const response = await fetch(`${this.baseURL}/users/sign_in`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user: { email, password },
      }),
    });

    const data = await response.json();

    if (data.status.code === 200) {
      this.token = data.data.token;
      return data;
    } else {
      throw new Error(data.status.message);
    }
  }

  // Get all users (admin only)
  async getAllUsers() {
    if (!this.token) {
      throw new Error("Not authenticated");
    }

    const response = await fetch(`${this.baseURL}/api/v1/admin/users`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
    });

    return await response.json();
  }

  // Get user profile
  async getProfile() {
    if (!this.token) {
      throw new Error("Not authenticated");
    }

    const response = await fetch(`${this.baseURL}/api/v1/users/profile`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
    });

    return await response.json();
  }

  // Logout
  async logout() {
    if (!this.token) {
      throw new Error("Not authenticated");
    }

    const response = await fetch(`${this.baseURL}/users/sign_out`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
    });

    this.token = null;
    return await response.json();
  }
}

// Usage example
const api = new CrowdaxAPI();

// Login
api
  .login("admin@example.com", "password123")
  .then((data) => {
    console.log("Logged in:", data);
    return api.getAllUsers();
  })
  .then((users) => {
    console.log("All users:", users);
  })
  .catch((error) => {
    console.error("Error:", error);
  });
```

### cURL Examples

#### Authentication and User Management

```bash
#!/bin/bash

BASE_URL="http://localhost:3000"

# 1. Login to get token
echo "Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "admin@example.com",
      "password": "password123"
    }
  }')

echo $LOGIN_RESPONSE | jq '.'

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo "Token extracted: ${TOKEN:0:50}..."

    # 2. Get all users
    echo "Getting all users..."
    curl -X GET $BASE_URL/api/v1/admin/users \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" | jq '.'

    # 3. Get entrepreneurs
    echo "Getting entrepreneurs..."
    curl -X GET $BASE_URL/api/v1/admin/entrepreneurs \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" | jq '.'

    # 4. Get investors
    echo "Getting investors..."
    curl -X GET $BASE_URL/api/v1/admin/investors \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" | jq '.'

    # 5. Logout
    echo "Logging out..."
    curl -X DELETE $BASE_URL/users/sign_out \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" | jq '.'
else
    echo "Failed to extract token"
fi
```

#### Individual Commands

```bash
# Login
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "admin@example.com",
      "password": "password123"
    }
  }'

# Get all users with token
curl -X GET http://localhost:3000/api/v1/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"

# Get specific user
curl -X GET http://localhost:3000/api/v1/admin/users/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"

# Update user
curl -X PUT http://localhost:3000/api/v1/admin/users/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "updated@example.com"
    }
  }'

# Delete user
curl -X DELETE http://localhost:3000/api/v1/admin/users/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

### Python Requests

#### Complete API Client

```python
import requests
import json
from typing import Optional, Dict, Any

class CrowdaxAPI:
    def __init__(self, base_url: str = "http://localhost:3000"):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.session = requests.Session()

    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login and get authentication token"""
        url = f"{self.base_url}/users/sign_in"
        data = {
            "user": {
                "email": email,
                "password": password
            }
        }

        response = self.session.post(url, json=data)
        response.raise_for_status()

        result = response.json()
        if result["status"]["code"] == 200:
            self.token = result["data"]["token"]
            self.session.headers.update({
                "Authorization": f"Bearer {self.token}"
            })

        return result

    def get_all_users(self) -> Dict[str, Any]:
        """Get all users (admin only)"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/users"
        response = self.session.get(url)
        response.raise_for_status()

        return response.json()

    def get_user(self, user_id: int) -> Dict[str, Any]:
        """Get specific user details"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/users/{user_id}"
        response = self.session.get(url)
        response.raise_for_status()

        return response.json()

    def update_user(self, user_id: int, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update user details"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/users/{user_id}"
        data = {"user": user_data}
        response = self.session.put(url, json=data)
        response.raise_for_status()

        return response.json()

    def delete_user(self, user_id: int) -> Dict[str, Any]:
        """Delete user"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/users/{user_id}"
        response = self.session.delete(url)
        response.raise_for_status()

        return response.json()

    def get_entrepreneurs(self, **filters) -> Dict[str, Any]:
        """Get entrepreneurs with optional filters"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/entrepreneurs"
        response = self.session.get(url, params=filters)
        response.raise_for_status()

        return response.json()

    def get_investors(self, **filters) -> Dict[str, Any]:
        """Get investors with optional filters"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/api/v1/admin/investors"
        response = self.session.get(url, params=filters)
        response.raise_for_status()

        return response.json()

    def logout(self) -> Dict[str, Any]:
        """Logout and invalidate token"""
        if not self.token:
            raise ValueError("Not authenticated. Call login() first.")

        url = f"{self.base_url}/users/sign_out"
        response = self.session.delete(url)
        response.raise_for_status()

        self.token = None
        self.session.headers.pop("Authorization", None)

        return response.json()

# Usage example
if __name__ == "__main__":
    api = CrowdaxAPI()

    try:
        # Login
        login_result = api.login("admin@example.com", "password123")
        print("Login successful:", login_result["status"]["message"])

        # Get all users
        users = api.get_all_users()
        print(f"Found {len(users['data'])} users")

        # Get entrepreneurs
        entrepreneurs = api.get_entrepreneurs(status="kyc_verified")
        print(f"Found {len(entrepreneurs['data'])} verified entrepreneurs")

        # Get investors
        investors = api.get_investors(investment_status="has_investments")
        print(f"Found {len(investors['data'])} investors with investments")

        # Logout
        logout_result = api.logout()
        print("Logout successful:", logout_result["status"]["message"])

    except Exception as e:
        print(f"Error: {e}")
```

### Node.js/axios Example

```javascript
const axios = require("axios");

class CrowdaxAPI {
  constructor(baseURL = "http://localhost:3000") {
    this.baseURL = baseURL;
    this.token = null;
    this.client = axios.create({
      baseURL,
      headers: {
        "Content-Type": "application/json",
      },
    });
  }

  async login(email, password) {
    const response = await this.client.post("/users/sign_in", {
      user: { email, password },
    });

    if (response.data.status.code === 200) {
      this.token = response.data.data.token;
      this.client.defaults.headers.common[
        "Authorization"
      ] = `Bearer ${this.token}`;
    }

    return response.data;
  }

  async getAllUsers() {
    const response = await this.client.get("/api/v1/admin/users");
    return response.data;
  }

  async logout() {
    const response = await this.client.delete("/users/sign_out");
    this.token = null;
    delete this.client.defaults.headers.common["Authorization"];
    return response.data;
  }
}

// Usage
const api = new CrowdaxAPI();
api
  .login("admin@example.com", "password123")
  .then(() => api.getAllUsers())
  .then((users) => console.log(users))
  .then(() => api.logout())
  .catch(console.error);
```

## Security Considerations

1. **Token Storage**: Store JWT tokens securely (HttpOnly cookies for web apps, secure storage for mobile apps)
2. **Token Expiration**: Tokens expire after 24 hours by default
3. **HTTPS**: Always use HTTPS in production
4. **Rate Limiting**: API endpoints are rate-limited to prevent abuse
5. **Input Validation**: All inputs are validated and sanitized
6. **CORS**: Configure CORS properly for your frontend domain

## Testing the API

### Automated Testing Scripts

#### 1. Authentication Testing

```bash
# Test all authentication endpoints
./test_auth.sh
```

#### 2. User Management Testing

```bash
# Test user listing and management
./get_users.sh
```

#### 3. Rails Test Suite

```bash
# Run all API tests
rails test test/controllers/api/v1/

# Run specific test files
rails test test/controllers/api/v1/users_controller_test.rb
rails test test/controllers/api/v1/admin_controller_test.rb
```

### Manual Testing Examples

#### Test User Authentication Flow

```bash
# 1. Start the server
rails server -p 3000

# 2. Login as admin
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "admin@example.com",
      "password": "password123"
    }
  }'

# 3. Extract token and list users
TOKEN="your_extracted_token_here"
curl -X GET http://localhost:3000/api/v1/admin/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

#### Test Different User Roles

```bash
# Test entrepreneur access
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'

# Test investor access
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "investor@example.com",
      "password": "password123"
    }
  }'
```

#### Test Error Cases

```bash
# Test invalid credentials
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "wrong@example.com",
      "password": "wrongpassword"
    }
  }'

# Test unauthorized access
curl -X GET http://localhost:3000/api/v1/admin/users \
  -H "Content-Type: application/json"
```

### Testing Tools

#### 1. cURL

- **Pros**: Available everywhere, good for automation
- **Cons**: Verbose syntax, no GUI

#### 2. Postman

- **Setup**: Import the API collection
- **Features**: GUI, environment variables, automated testing

#### 3. Insomnia

- **Setup**: Import the API collection
- **Features**: Clean interface, good for development

#### 4. HTTPie

```bash
# Install HTTPie
pip install httpie

# Use for testing
http POST localhost:3000/users/sign_in user:='{"email":"admin@example.com","password":"password123"}'
http GET localhost:3000/api/v1/admin/users Authorization:"Bearer $TOKEN"
```

### Environment Setup for Testing

#### 1. Development Environment

```bash
# Set up the database
rails db:create
rails db:migrate
rails db:seed

# Load test data
rails db:fixtures:load RAILS_ENV=development
```

#### 2. Test Environment

```bash
# Set up test database
rails db:create RAILS_ENV=test
rails db:migrate RAILS_ENV=test
rails db:fixtures:load RAILS_ENV=test
```

### Common Testing Scenarios

#### 1. Authentication Flow

- [ ] User registration
- [ ] User login
- [ ] Token extraction
- [ ] Protected endpoint access
- [ ] Token refresh
- [ ] User logout

#### 2. User Management

- [ ] List all users (admin)
- [ ] Get specific user (admin)
- [ ] Update user (admin)
- [ ] Delete user (admin)
- [ ] Export users (admin)

#### 3. Role-Based Access

- [ ] Admin access to all endpoints
- [ ] Entrepreneur access to own data
- [ ] Investor access to own data
- [ ] Unauthorized access rejection

#### 4. Error Handling

- [ ] Invalid credentials
- [ ] Expired tokens
- [ ] Missing tokens
- [ ] Invalid permissions

### Performance Testing

#### Load Testing with Apache Bench

```bash
# Test login endpoint
ab -n 100 -c 10 -p login_data.json -T application/json http://localhost:3000/users/sign_in

# Test protected endpoint
ab -n 100 -c 10 -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/admin/users
```

#### Memory and CPU Monitoring

```bash
# Monitor Rails process
top -p $(pgrep -f "rails server")

# Monitor memory usage
ps aux | grep rails
```

For more detailed testing information, see `TESTING_GUIDE.md` and `quick_test.md`.
