# Environment Variables Setup Guide

This guide explains how to set up and manage environment variables for the Crowdax API.

## Overview

The Crowdax API uses environment variables to manage configuration across different environments (development, staging, production). This approach provides:

- **Security**: Sensitive information is kept out of version control
- **Flexibility**: Different configurations for different environments
- **Maintainability**: Easy to update settings without code changes
- **Compliance**: Better security practices for financial applications

## Quick Setup

### 1. Automatic Setup (Recommended)

Run the setup script to automatically create your environment file:

```bash
bin/setup-env.sh
```

This script will:

- Copy the template to `.env.local`
- Generate secure encryption keys
- Generate secure JWT secret keys
- Create Rails master key if needed

### 2. Manual Setup

If you prefer manual setup:

```bash
# Copy the template
cp env.template .env.local

# Edit with your values
nano .env.local
```

## Environment Variables Reference

### Application Configuration

| Variable               | Description                      | Default                 | Required |
| ---------------------- | -------------------------------- | ----------------------- | -------- |
| `RAILS_ENV`            | Rails environment                | `development`           | Yes      |
| `RAILS_MASTER_KEY`     | Rails master key for credentials | -                       | Yes      |
| `PLATFORM_NAME`        | Application name                 | `Crowdax`               | No       |
| `PLATFORM_DESCRIPTION` | Application description          | -                       | No       |
| `APP_HOST`             | Application host                 | `localhost:3000`        | No       |
| `APP_URL`              | Application URL                  | `http://localhost:3000` | No       |

### Database Configuration

| Variable                        | Description                | Default | Required |
| ------------------------------- | -------------------------- | ------- | -------- |
| `DATABASE_URL`                  | Database connection URL    | -       | Yes      |
| `CROWDAX_API_DATABASE_PASSWORD` | Database password          | -       | Yes      |
| `RAILS_MAX_THREADS`             | Database pool size         | `5`     | No       |
| `WEB_CONCURRENCY`               | Web server concurrency     | `2`     | No       |
| `JOB_CONCURRENCY`               | Job processing concurrency | `1`     | No       |

### Storage Configuration (DigitalOcean Spaces)

| Variable             | Description                     | Default | Required |
| -------------------- | ------------------------------- | ------- | -------- |
| `DO_SPACES_KEY`      | DigitalOcean Spaces access key  | -       | Yes      |
| `DO_SPACES_SECRET`   | DigitalOcean Spaces secret key  | -       | Yes      |
| `DO_SPACES_REGION`   | DigitalOcean Spaces region      | `nyc3`  | No       |
| `DO_SPACES_BUCKET`   | DigitalOcean Spaces bucket name | -       | Yes      |
| `DO_SPACES_ENDPOINT` | DigitalOcean Spaces endpoint    | -       | No       |

### Email Configuration

| Variable                    | Description          | Default               | Required |
| --------------------------- | -------------------- | --------------------- | -------- |
| `SMTP_HOST`                 | SMTP server host     | `localhost`           | No       |
| `SMTP_PORT`                 | SMTP server port     | `1025`                | No       |
| `SMTP_DOMAIN`               | SMTP domain          | `localhost`           | No       |
| `SMTP_USERNAME`             | SMTP username        | -                     | No       |
| `SMTP_PASSWORD`             | SMTP password        | -                     | No       |
| `SMTP_AUTHENTICATION`       | SMTP authentication  | `plain`               | No       |
| `SMTP_ENABLE_STARTTLS_AUTO` | Enable STARTTLS      | `false`               | No       |
| `MAILER_SENDER`             | Default sender email | `noreply@crowdax.com` | No       |

### JWT Authentication

| Variable              | Description                   | Default               | Required |
| --------------------- | ----------------------------- | --------------------- | -------- |
| `JWT_SECRET_KEY`      | JWT secret key                | Rails secret key base | No       |
| `JWT_EXPIRATION_TIME` | JWT expiration time (seconds) | `1800`                | No       |

### CORS Configuration

| Variable               | Description                     | Default              | Required |
| ---------------------- | ------------------------------- | -------------------- | -------- |
| `CORS_ALLOWED_ORIGINS` | Comma-separated allowed origins | Development defaults | No       |

### Deployment Configuration

| Variable                  | Description              | Default                  | Required |
| ------------------------- | ------------------------ | ------------------------ | -------- |
| `KAMAL_REGISTRY_PASSWORD` | Docker registry password | -                        | Yes      |
| `KAMAL_REGISTRY_USERNAME` | Docker registry username | `your-user`              | No       |
| `DEPLOYMENT_HOST`         | Deployment server IP     | `192.168.0.1`            | No       |
| `DEPLOYMENT_DOMAIN`       | Deployment domain        | `crowdax-api.loan360.co` | No       |

### External Services

| Variable                   | Description              | Default                       | Required |
| -------------------------- | ------------------------ | ----------------------------- | -------- |
| `TERMS_AND_CONDITIONS_URL` | Terms and conditions URL | `https://example.com/terms`   | No       |
| `PRIVACY_POLICY_URL`       | Privacy policy URL       | `https://example.com/privacy` | No       |
| `CONTACT_EMAIL`            | Contact email            | `support@crowdax.com`         | No       |
| `CONTACT_PHONE`            | Contact phone            | `+1234567890`                 | No       |

### Security Configuration

| Variable         | Description              | Default   | Required |
| ---------------- | ------------------------ | --------- | -------- |
| `ENCRYPTION_KEY` | File encryption key      | Generated | No       |
| `FORCE_SSL`      | Force SSL connections    | `true`    | No       |
| `ASSUME_SSL`     | Assume SSL in production | `true`    | No       |

### Feature Flags

| Variable                      | Description                 | Default | Required |
| ----------------------------- | --------------------------- | ------- | -------- |
| `ENABLE_BREACH_NOTIFICATIONS` | Enable breach notifications | `true`  | No       |
| `ENABLE_DATA_SUBJECT_RIGHTS`  | Enable data subject rights  | `true`  | No       |
| `ENABLE_AUDIT_LOGGING`        | Enable audit logging        | `true`  | No       |
| `ENABLE_KYC_VERIFICATION`     | Enable KYC verification     | `true`  | No       |

### Compliance Settings

| Variable                   | Description                | Default | Required |
| -------------------------- | -------------------------- | ------- | -------- |
| `DATA_RETENTION_DAYS`      | Data retention period      | `2555`  | No       |
| `BREACH_NOTIFICATION_DAYS` | Breach notification period | `72`    | No       |
| `CONSENT_EXPIRATION_DAYS`  | Consent expiration period  | `365`   | No       |

## Environment-Specific Configuration

### Development Environment

For development, you can use the default values in most cases. Key settings:

```bash
RAILS_ENV=development
DATABASE_URL=postgresql://postgres:password@localhost:5432/crowdax_api_development
SMTP_HOST=localhost
SMTP_PORT=1025
```

### Production Environment

For production, ensure all sensitive values are properly set:

```bash
RAILS_ENV=production
RAILS_MASTER_KEY=your_actual_master_key
DATABASE_URL=your_production_database_url
DO_SPACES_KEY=your_actual_spaces_key
DO_SPACES_SECRET=your_actual_spaces_secret
JWT_SECRET_KEY=your_actual_jwt_secret
ENCRYPTION_KEY=your_actual_encryption_key
```

### Staging Environment

For staging, use production-like settings but with staging-specific values:

```bash
RAILS_ENV=staging
DATABASE_URL=your_staging_database_url
DO_SPACES_BUCKET=your-staging-bucket
```

## Security Best Practices

### 1. Never Commit Sensitive Data

- The `.env.local` file is already in `.gitignore`
- Never commit actual credentials to version control
- Use different values for each environment

### 2. Use Strong Keys

- Generate strong, unique keys for each environment
- Use the setup script to generate secure keys
- Rotate keys regularly

### 3. Environment Isolation

- Use separate databases for each environment
- Use separate storage buckets for each environment
- Use different API keys for each environment

### 4. Access Control

- Limit access to production environment variables
- Use secrets management in production
- Monitor access to sensitive configuration

## Troubleshooting

### Common Issues

#### 1. "Rails master key not found"

```bash
# Generate a new master key
rails credentials:edit
```

#### 2. "Database connection failed"

Check your `DATABASE_URL` and `CROWDAX_API_DATABASE_PASSWORD`:

```bash
# Test database connection
rails dbconsole
```

#### 3. "Storage service not configured"

Ensure DigitalOcean Spaces credentials are set:

```bash
# Check if variables are set
echo $DO_SPACES_KEY
echo $DO_SPACES_SECRET
```

#### 4. "JWT authentication failed"

Check JWT configuration:

```bash
# Verify JWT secret is set
echo $JWT_SECRET_KEY
```

### Validation Script

Run this script to validate your environment configuration:

```bash
bin/validate-env.sh
```

## Deployment Considerations

### Kamal Deployment

For Kamal deployment, ensure these variables are set:

```bash
KAMAL_REGISTRY_PASSWORD=your_registry_password
DEPLOYMENT_HOST=your_server_ip
DEPLOYMENT_DOMAIN=your_domain.com
```

### Docker Deployment

For Docker deployment, pass environment variables:

```bash
docker run -e RAILS_ENV=production \
  -e DATABASE_URL=your_db_url \
  -e DO_SPACES_KEY=your_key \
  -e DO_SPACES_SECRET=your_secret \
  crowdax_api
```

## Monitoring and Maintenance

### Regular Tasks

1. **Rotate Keys**: Regularly rotate encryption and JWT keys
2. **Update Passwords**: Update database and service passwords
3. **Review Access**: Review who has access to production credentials
4. **Backup Configuration**: Backup your environment configuration

### Monitoring

- Monitor for unauthorized access attempts
- Log configuration changes
- Alert on missing required variables

## Support

If you encounter issues with environment configuration:

1. Check the troubleshooting section above
2. Verify all required variables are set
3. Ensure proper file permissions
4. Check Rails logs for configuration errors

For additional help, refer to:

- [Rails Environment Configuration](https://guides.rubyonrails.org/configuring.html)
- [Kamal Deployment Documentation](https://kamal-deploy.org/)
- [DigitalOcean Spaces Documentation](https://docs.digitalocean.com/products/spaces/)
