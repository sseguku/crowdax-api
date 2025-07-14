# 🧪 Testing Guide for Crowdax API Authentication

This guide covers multiple ways to test your authentication system.

## 📋 Prerequisites

1. **Start the Rails server:**

   ```bash
   rails s
   ```

2. **Install jq for JSON formatting (macOS):**

   ```bash
   brew install jq
   ```

3. **For email testing, install MailHog:**
   ```bash
   brew install mailhog
   mailhog  # Start MailHog
   # Access web interface at http://localhost:8025
   ```

## 🚀 Quick Start Testing

### Method 1: Automated Test Script

```bash
# Run the comprehensive test script
./test_auth.sh
```

### Method 2: Manual cURL Commands

Copy and paste these commands one by one:

#### 1. Register a new user

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "entrepreneur"
    }
  }' | jq '.'
```

#### 2. Login and get token

```bash
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }' | jq '.'
```

#### 3. Test protected endpoint (replace YOUR_TOKEN with actual token)

```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" | jq '.'
```

## 🧪 Rails Test Suite

### Run all tests

```bash
rails test
```

### Run specific test files

```bash
# Test authentication endpoints
rails test test/controllers/users/sessions_controller_test.rb

# Test protected API endpoints
rails test test/controllers/api/v1/users_controller_test.rb
```

### Run individual tests

```bash
rails test test/controllers/users/sessions_controller_test.rb:15
```

## 📧 Email Testing

### Using MailHog (Recommended)

1. Start MailHog: `mailhog`
2. Access web interface: http://localhost:8025
3. Send test emails via API endpoints
4. Check MailHog interface for received emails

### Using Rails Console

```bash
rails console
```

```ruby
# Check if emails are being sent
ActionMailer::Base.deliveries.last

# Manually send a confirmation email
user = User.find_by(email: 'test@example.com')
user.send_confirmation_instructions

# Manually send a password reset email
user.send_reset_password_instructions
```

## 🔍 Testing Individual Features

### 1. User Registration

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newuser@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "entrepreneur"
    }
  }' | jq '.'
```

**Expected Response:**

```json
{
  "status": {
    "code": 200,
    "message": "Account created successfully. Please check your email to confirm your account."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "newuser@example.com",
      "role": "entrepreneur",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    }
  }
}
```

### 2. User Login

```bash
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }' | jq '.'
```

**Expected Response:**

```json
{
  "status": {
    "code": 200,
    "message": "Logged in successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "test@example.com",
      "role": "entrepreneur",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "created_date": "01/01/2024"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 3. Password Reset

```bash
# Request password reset
curl -X POST http://localhost:3000/users/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'

# Check MailHog for reset email
# Use the token from email to reset password
curl -X PUT http://localhost:3000/users/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "reset_password_token": "TOKEN_FROM_EMAIL",
      "password": "newpassword123",
      "password_confirmation": "newpassword123"
    }
  }' | jq '.'
```

### 4. Email Confirmation

```bash
# Request confirmation email
curl -X POST http://localhost:3000/users/confirmation \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'

# Confirm email with token from email
curl -X GET "http://localhost:3000/users/confirmation?confirmation_token=TOKEN_FROM_EMAIL" | jq '.'
```

### 5. Protected Endpoints

```bash
# Get user profile (requires token)
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Get user dashboard
curl -X GET http://localhost:3000/api/v1/users/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" | jq '.'

# Update user profile
curl -X PUT http://localhost:3000/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "updated@example.com",
      "current_password": "password123",
      "role": "investor"
    }
  }' | jq '.'
```

## 🐛 Debugging Tips

### 1. Check Rails logs

```bash
tail -f log/development.log
```

### 2. Check email delivery

```ruby
# In Rails console
ActionMailer::Base.deliveries.count
ActionMailer::Base.deliveries.last
```

### 3. Check JWT token

```ruby
# In Rails console
require 'jwt'
token = "YOUR_TOKEN_HERE"
decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
puts decoded
```

### 4. Test token validation

```bash
# Test with invalid token
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer invalid_token" \
  -H "Content-Type: application/json" | jq '.'
```

## 📊 Expected Test Results

### Successful Responses

- ✅ Registration: 200 status with user data
- ✅ Login: 200 status with token
- ✅ Protected endpoints: 200 status with data
- ✅ Password reset: 200 status
- ✅ Email confirmation: 200 status

### Error Responses

- ❌ Invalid credentials: 401 status
- ❌ Missing token: 401 status
- ❌ Invalid token: 401 status
- ❌ Validation errors: 422 status
- ❌ Email not found: 404 status

## 🎯 Testing Checklist

- [ ] User registration works
- [ ] Email confirmation is sent
- [ ] Login with valid credentials works
- [ ] Login with invalid credentials fails
- [ ] Token-based authentication works
- [ ] Protected endpoints require authentication
- [ ] Password reset request works
- [ ] Password reset with token works
- [ ] Email confirmation request works
- [ ] Email confirmation with token works
- [ ] Token refresh works
- [ ] Logout works
- [ ] Account update works
- [ ] Account deletion works

## 🚨 Common Issues

### 1. "No token received"

- Check if user exists in database
- Verify password is correct
- Check Rails logs for errors

### 2. "Authentication required"

- Ensure token is included in Authorization header
- Check token format: `Bearer TOKEN`
- Verify token hasn't expired

### 3. "Email not found"

- Check if user exists in database
- Verify email address is correct
- Check if user is confirmed

### 4. Emails not being sent

- Check MailHog is running
- Verify SMTP configuration
- Check Rails logs for email errors

## 📝 Notes

- Tokens expire after 30 minutes
- Password reset tokens expire after 6 hours
- Email confirmation tokens expire after 3 days
- All responses are in JSON format
- Error messages are descriptive and helpful
