# Quick Test Commands

## Prerequisites

1. Start Rails server: `rails s`
2. Install jq for JSON formatting: `brew install jq` (macOS)

## Test Commands

### 1. Register User

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

### 2. Login & Get Token

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

### 3. Test Protected Endpoint (replace TOKEN with actual token)

```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" | jq '.'
```

### 4. Request Password Reset

```bash
curl -X POST http://localhost:3000/users/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'
```

### 5. Request Email Confirmation

```bash
curl -X POST http://localhost:3000/users/confirmation \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com"
    }
  }' | jq '.'
```

## Email Testing Setup

### Install MailHog (for email testing)

```bash
# macOS
brew install mailhog

# Start MailHog
mailhog

# Access web interface at http://localhost:8025
```

### Alternative: Use Rails console to check emails

```bash
rails console
```

Then in console:

```ruby
# Check if emails are being sent
ActionMailer::Base.deliveries.last
```
