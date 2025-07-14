# Token-Based Authentication API

This API uses JWT (JSON Web Tokens) for authentication. All protected endpoints require a valid token in the Authorization header.

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
    "message": "Password has been reset successfully."
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

### 8. Request Email Confirmation

**POST** `/users/confirmation`

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
    "message": "Confirmation instructions have been sent to your email."
  }
}
```

### 9. Confirm Email

**GET** `/users/confirmation?confirmation_token=token_from_email`

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Email confirmed successfully."
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

### 10. Update Account

**PUT** `/users`

Headers:

```
Authorization: Bearer <token>
```

Request body:

```json
{
  "user": {
    "email": "newemail@example.com",
    "current_password": "currentpassword",
    "password": "newpassword123",
    "password_confirmation": "newpassword123",
    "role": "investor"
  }
}
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Account updated successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "newemail@example.com",
      "role": "investor",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    }
  }
}
```

### 11. Delete Account

**DELETE** `/users`

Headers:

```
Authorization: Bearer <token>
```

Response:

```json
{
  "status": {
    "code": 200,
    "message": "Account deleted successfully."
  }
}
```

## Protected API Endpoints

All API endpoints under `/api/v1/` require authentication.

### User Profile

**GET** `/api/v1/users/profile`

Headers:

```
Authorization: Bearer <token>
```

### Update Profile

**PUT** `/api/v1/users/profile`

Headers:

```
Authorization: Bearer <token>
```

Request body:

```json
{
  "user": {
    "email": "newemail@example.com",
    "role": "investor"
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
    "message": "Dashboard data retrieved successfully"
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
    "stats": {
      "total_logins": 5,
      "last_sign_in": "2024-01-01T10:00:00.000Z",
      "role": "entrepreneur"
    }
  }
}
```

## Error Responses

### Unauthorized (401)

```json
{
  "status": {
    "code": 401,
    "message": "Authentication required. Please provide a valid token."
  }
}
```

### Forbidden (403)

```json
{
  "status": {
    "code": 403,
    "message": "Forbidden"
  }
}
```

### Not Found (404)

```json
{
  "status": {
    "code": 404,
    "message": "Email not found."
  }
}
```

### Unprocessable Entity (422)

```json
{
  "status": {
    "code": 422,
    "message": "Validation errors occurred"
  },
  "errors": ["Email is invalid", "Password is too short"]
}
```

## Token Configuration

- **Expiration**: 30 minutes
- **Algorithm**: HS256
- **Secret**: Uses Rails application secret key base

## Email Configuration

- **Sender**: noreply@crowdax.com
- **Password Reset**: 6 hours expiration
- **Email Confirmation**: 3 days expiration
- **Development**: Uses localhost:1025 (MailHog recommended)

## Usage Examples

### JavaScript/Fetch

```javascript
// Register
const registerResponse = await fetch("/users", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    user: {
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "entrepreneur",
    },
  }),
});

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

// Request password reset
await fetch("/users/password", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    user: {
      email: "user@example.com",
    },
  }),
});

// Use token for authenticated requests
const profileResponse = await fetch("/api/v1/users/profile", {
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
});
```

### cURL

```bash
# Register
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123","password_confirmation":"password123","role":"entrepreneur"}}'

# Login
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123"}}'

# Request password reset
curl -X POST http://localhost:3000/users/password \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com"}}'

# Use token
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json"
```

## Development Setup

For email testing in development, install MailHog:

```bash
# macOS
brew install mailhog

# Start MailHog
mailhog

# Access web interface at http://localhost:8025
```

This will capture all emails sent by the application for testing password reset and email confirmation functionality.
