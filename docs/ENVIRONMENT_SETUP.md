# Environment Setup Guide

This guide explains how to set up and manage environment variables for the Crowdax API.

## Table of Contents

- [Overview](#overview)
- [Environment Variables](#environment-variables)
- [Setup Instructions](#setup-instructions)
- [Development Setup](#development-setup)
- [Production Setup](#production-setup)
- [Troubleshooting](#troubleshooting)

## Overview

The Crowdax API uses environment variables to manage configuration across different environments (development, staging, production). This approach provides:

- **Security**: Sensitive data is kept out of source code
- **Flexibility**: Easy configuration changes without code deployment
- **Environment Isolation**: Different settings for different environments
- **Compliance**: Meets Uganda Data Protection and Privacy Act requirements

## Environment Variables

### Required Variables

| Variable                        | Description                | Default       | Required |
| ------------------------------- | -------------------------- | ------------- | -------- |
| `RAILS_ENV`                     | Rails environment          | `development` | Yes      |
| `DATABASE_URL`                  | Database connection string | -             | Yes      |
| `CROWDAX_API_DATABASE_PASSWORD` | Database password          | -             | Yes      |
| `SECRET_KEY_BASE`               | Rails secret key base      | -             | Yes      |
| `DEVISE_JWT_SECRET_KEY`         | JWT secret key             | -             | Yes      |

### Optional Variables

| Variable            | Description                | Default                  | Required |
| ------------------- | -------------------------- | ------------------------ | -------- |
| `RAILS_MAX_THREADS` | Maximum threads per server | `5`                      | No       |
| `WEB_CONCURRENCY`   | Number of processes        | `2`                      | No       |
| `PORT`              | Server port                | `3000`                   | No       |
| `HOST`              | Server host                | `localhost`              | No       |
| `DEPLOYMENT_DOMAIN` | Deployment domain          | `crowdax-api.loan360.co` | No       |

### Email Configuration

| Variable        | Description          | Default               | Required         |
| --------------- | -------------------- | --------------------- | ---------------- |
| `SMTP_HOST`     | SMTP server host     | -                     | Yes (production) |
| `SMTP_PORT`     | SMTP server port     | `587`                 | No               |
| `SMTP_USERNAME` | SMTP username        | -                     | Yes (production) |
| `SMTP_PASSWORD` | SMTP password        | -                     | Yes (production) |
| `SMTP_DOMAIN`   | SMTP domain          | -                     | No               |
| `MAILER_SENDER` | Default sender email | `noreply@crowdax.com` | No               |

### File Storage

| Variable                     | Description                | Default     | Required         |
| ---------------------------- | -------------------------- | ----------- | ---------------- |
| `AWS_ACCESS_KEY_ID`          | AWS access key             | -           | Yes (production) |
| `AWS_SECRET_ACCESS_KEY`      | AWS secret key             | -           | Yes (production) |
| `AWS_REGION`                 | AWS region                 | `us-east-1` | No               |
| `AWS_BUCKET`                 | S3 bucket name             | -           | Yes (production) |
| `DIGITALOCEAN_SPACES_KEY`    | DigitalOcean Spaces key    | -           | No               |
| `DIGITALOCEAN_SPACES_SECRET` | DigitalOcean Spaces secret | -           | No               |
| `DIGITALOCEAN_SPACES_BUCKET` | DigitalOcean Spaces bucket | -           | No               |
| `DIGITALOCEAN_SPACES_REGION` | DigitalOcean Spaces region | -           | No               |

### Security & Compliance

| Variable              | Description                    | Default | Required |
| --------------------- | ------------------------------ | ------- | -------- |
| `JWT_EXPIRATION_TIME` | JWT token expiration (hours)   | `24`    | No       |
| `PASSWORD_MIN_LENGTH` | Minimum password length        | `6`     | No       |
| `RATE_LIMIT_REQUESTS` | Rate limit requests per minute | `60`    | No       |
| `CORS_ORIGINS`        | Allowed CORS origins           | `*`     | No       |
| `SSL_REDIRECT`        | Force SSL redirect             | `false` | No       |

### Monitoring & Logging

| Variable                | Description           | Default | Required |
| ----------------------- | --------------------- | ------- | -------- |
| `LOG_LEVEL`             | Logging level         | `info`  | No       |
| `SENTRY_DSN`            | Sentry error tracking | -       | No       |
| `NEW_RELIC_LICENSE_KEY` | New Relic license key | -       | No       |
| `NEW_RELIC_APP_NAME`    | New Relic app name    | -       | No       |

## Setup Instructions

### 1. Copy Environment Template

```bash
cp env.template .env
```

### 2. Generate Required Secrets

```bash
# Generate Rails secret key base
rails secret

# Generate JWT secret key
rails secret
```

### 3. Configure Database

For PostgreSQL with the credentials you provided:

```bash
# Database URL format
DATABASE_URL=postgresql://crowdax_25:xqDreWtbNa@localhost:5432/crowdax_api_development

# Or separate variables
CROWDAX_API_DATABASE_PASSWORD=xqDreWtbNa
```

### 4. Set Up Email (Development)

For development, you can use MailHog:

```bash
# Install MailHog (macOS)
brew install mailhog

# Start MailHog
mailhog

# Access at http://localhost:8025
```

### 5. Configure File Storage (Development)

For development, use local storage:

```bash
# No additional configuration needed for local storage
```

## Development Setup

### Complete `.env` Example

```bash
# Rails Configuration
RAILS_ENV=development
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
PORT=3000
HOST=localhost

# Database
DATABASE_URL=postgresql://crowdax_25:xqDreWtbNa@localhost:5432/crowdax_api_development
CROWDAX_API_DATABASE_PASSWORD=xqDreWtbNa

# Security
SECRET_KEY_BASE=your_generated_secret_key_base_here
DEVISE_JWT_SECRET_KEY=your_generated_jwt_secret_key_here

# Email (Development - MailHog)
SMTP_HOST=localhost
SMTP_PORT=1025
MAILER_SENDER=noreply@crowdax.com

# JWT Configuration
JWT_EXPIRATION_TIME=24
PASSWORD_MIN_LENGTH=6

# Rate Limiting
RATE_LIMIT_REQUESTS=60

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# Logging
LOG_LEVEL=debug
```

### Development Commands

```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start development server
rails server

# Start background jobs (if using Sidekiq)
bundle exec sidekiq

# Run tests
rails test
```

## Production Setup

### Production Environment Variables

```bash
# Rails Configuration
RAILS_ENV=production
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=4
PORT=3000

# Database
DATABASE_URL=postgresql://crowdax_prod:secure_password@prod-db-host:5432/crowdax_api_production
CROWDAX_API_DATABASE_PASSWORD=secure_production_password

# Security
SECRET_KEY_BASE=your_production_secret_key_base
DEVISE_JWT_SECRET_KEY=your_production_jwt_secret_key

# Email (Production)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_DOMAIN=crowdax.com
MAILER_SENDER=noreply@crowdax.com

# File Storage (AWS S3 or DigitalOcean Spaces)
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-east-1
AWS_BUCKET=crowdax-api-files

# Or DigitalOcean Spaces
DIGITALOCEAN_SPACES_KEY=your_spaces_key
DIGITALOCEAN_SPACES_SECRET=your_spaces_secret
DIGITALOCEAN_SPACES_BUCKET=crowdax-api-files
DIGITALOCEAN_SPACES_REGION=nyc3

# Security & Compliance
JWT_EXPIRATION_TIME=24
PASSWORD_MIN_LENGTH=8
RATE_LIMIT_REQUESTS=100
CORS_ORIGINS=https://crowdax.com,https://app.crowdax.com
SSL_REDIRECT=true

# Monitoring
LOG_LEVEL=info
SENTRY_DSN=your_sentry_dsn
NEW_RELIC_LICENSE_KEY=your_new_relic_key
NEW_RELIC_APP_NAME=Crowdax API
```

### Production Deployment

```bash
# Precompile assets
rails assets:precompile

# Run database migrations
rails db:migrate

# Start production server
rails server -e production
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Issues

**Error**: `PG::ConnectionBad: could not connect to server`

**Solution**:

```bash
# Check if PostgreSQL is running
brew services list | grep postgresql

# Start PostgreSQL if not running
brew services start postgresql

# Verify connection
psql -U crowdax_25 -h localhost -p 5432 -d crowdax_api_development
```

#### 2. Missing Environment Variables

**Error**: `Missing required environment variable: SECRET_KEY_BASE`

**Solution**:

```bash
# Generate secret key base
rails secret

# Add to .env file
echo "SECRET_KEY_BASE=$(rails secret)" >> .env
```

#### 3. Email Configuration Issues

**Error**: `Net::SMTPAuthenticationError`

**Solution**:

- Check SMTP credentials
- Enable 2-factor authentication for Gmail
- Use app-specific passwords
- Verify SMTP settings in `.env`

#### 4. File Upload Issues

**Error**: `AWS::S3::Errors::AccessDenied`

**Solution**:

- Verify AWS credentials
- Check bucket permissions
- Ensure bucket exists
- Verify region configuration

#### 5. JWT Token Issues

**Error**: `JWT::DecodeError`

**Solution**:

```bash
# Regenerate JWT secret
rails secret

# Update .env file
echo "DEVISE_JWT_SECRET_KEY=$(rails secret)" >> .env

# Restart application
rails server
```

### Environment Validation

Use the validation script to check your environment:

```bash
# Run environment validation
bin/validate-env.sh
```

### Database Setup Issues

If you encounter database permission issues:

```bash
# Connect as superuser
psql postgres

# Create user and database
CREATE USER crowdax_25 WITH PASSWORD 'xqDreWtbNa';
ALTER USER crowdax_25 CREATEDB;
CREATE DATABASE crowdax_api_development OWNER crowdax_25;

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE crowdax_api_development TO crowdax_25;
```

### SSL/HTTPS Setup

For production SSL setup, see [SSL Setup Guide](SSL_SETUP.md).

### Performance Tuning

For production performance optimization:

```bash
# Increase worker processes
WEB_CONCURRENCY=4

# Increase database pool size
RAILS_MAX_THREADS=10

# Enable caching
RAILS_CACHE_STORE=redis_cache_store
```

## Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use strong, unique passwords** for all services
3. **Rotate secrets regularly** (quarterly recommended)
4. **Use environment-specific configurations**
5. **Enable SSL/TLS** in production
6. **Implement rate limiting** to prevent abuse
7. **Monitor and log** all API access
8. **Regular security audits** of environment variables

## Compliance Notes

- All environment variables containing personal data must be encrypted
- Database passwords must meet minimum complexity requirements
- JWT secrets must be at least 32 characters long
- Email configurations must support secure transmission
- File storage must be configured for data protection compliance

## Additional Resources

- [Rails Environment Configuration](https://guides.rubyonrails.org/configuring.html)
- [Devise Configuration](https://github.com/heartcombo/devise)
- [JWT Configuration](https://github.com/waiting-for-dev/devise-jwt)
- [Kamal Deployment Documentation](https://kamal-deploy.org/)
- [DigitalOcean Spaces Documentation](https://docs.digitalocean.com/products/spaces/)
