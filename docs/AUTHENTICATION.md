# Token-Based Authentication API

This API uses JWT (JSON Web Tokens) for authentication. All protected endpoints require a valid token in the Authorization header.

## Table of Contents

- [Authentication Endpoints](#authentication-endpoints)
- [Protected API Endpoints](#protected-api-endpoints)
- [Error Responses](#error-responses)
- [Client Examples](#client-examples)

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

```javascript
// Login
const loginResponse = await fetch("/users/sign_in", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    user: {
      email: "user@example.com",
      password: "password123",
    },
  }),
});

const loginData = await loginResponse.json();
const token = loginData.data.token;

// Get user profile
const profileResponse = await fetch("/api/v1/users/profile", {
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
});

const profileData = await profileResponse.json();
console.log(profileData);
```

### cURL Examples

```bash
# Login
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123"
    }
  }'

# Get profile with token
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"

# Create campaign
curl -X POST http://localhost:3000/api/v1/campaigns \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "campaign": {
      "title": "Tech Startup Funding",
      "description": "Funding for innovative tech solutions",
      "target_amount": 50000000
    }
  }'
```

### Python Requests

```python
import requests

# Login
login_data = {
    "user": {
        "email": "user@example.com",
        "password": "password123"
    }
}

response = requests.post("http://localhost:3000/users/sign_in", json=login_data)
token = response.json()["data"]["token"]

# Get profile
headers = {"Authorization": f"Bearer {token}"}
profile_response = requests.get("http://localhost:3000/api/v1/users/profile", headers=headers)
print(profile_response.json())
```

## Security Considerations

1. **Token Storage**: Store JWT tokens securely (HttpOnly cookies for web apps, secure storage for mobile apps)
2. **Token Expiration**: Tokens expire after 24 hours by default
3. **HTTPS**: Always use HTTPS in production
4. **Rate Limiting**: API endpoints are rate-limited to prevent abuse
5. **Input Validation**: All inputs are validated and sanitized
6. **CORS**: Configure CORS properly for your frontend domain

## Testing

Use the provided test scripts in the project root:

```bash
# Test authentication
./test_auth.sh

# Run API tests
rails test test/controllers/api/v1/
```

For more testing examples, see `TESTING_GUIDE.md` and `quick_test.md`.
