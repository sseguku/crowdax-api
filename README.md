# Crowdax API

A comprehensive API for the Crowdax platform, built with Ruby on Rails and designed for Uganda's financial and data protection regulations.

## Features

- **JWT Authentication**: Secure token-based authentication
- **KYC Verification**: Know Your Customer verification system
- **Campaign Management**: Investment campaign creation and management
- **Breach Notification System**: Automated data breach detection and notification
- **Data Subject Rights**: GDPR-compliant data subject rights management
- **Audit Logging**: Comprehensive audit trail for compliance
- **SSL/HTTPS**: Secure communication with Let's Encrypt certificates
- **DigitalOcean Spaces**: Secure file storage and management

## Quick Start

### Prerequisites

- Ruby 3.4.4
- PostgreSQL
- Docker (for deployment)
- DigitalOcean account (for Spaces storage)

### 1. Environment Setup

```bash
# Set up environment variables
bin/setup-env.sh

# Validate configuration
bin/validate-env.sh
```

### 2. Database Setup

```bash
# Create and migrate database
bin/rails db:create db:migrate

# Seed initial data
bin/rails db:seed
```

### 3. Start the Server

```bash
# Start development server
bin/rails server
```

The API will be available at `http://localhost:3000`

## Environment Configuration

The application uses environment variables for configuration. See [Environment Setup Guide](docs/ENVIRONMENT_SETUP.md) for detailed instructions.

### Quick Environment Setup

1. Copy the template: `cp env.template .env.local`
2. Edit `.env.local` with your values
3. Run validation: `bin/validate-env.sh`

## API Documentation

- [Authentication Guide](docs/AUTHENTICATION.md)
- [SSL Setup Guide](docs/SSL_SETUP.md)
- [Testing Guide](TESTING_GUIDE.md)

## Development

### Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/controllers/api/v1/users_controller_test.rb
```

### Code Quality

```bash
# Run linting
bin/rubocop

# Security scan
bin/brakeman
```

## Deployment

### SSL Setup

```bash
# Deploy with SSL
bin/deploy-ssl.sh

# Monitor SSL certificate
bin/ssl-monitor.sh
```

### Kamal Deployment

```bash
# Deploy to production
bin/kamal deploy

# Check deployment status
bin/kamal status
```

## Security & Compliance

- **Data Protection**: Compliant with Uganda's Data Protection and Privacy Act
- **Financial Regulations**: Adheres to Bank of Uganda guidelines
- **Audit Trail**: Comprehensive logging for regulatory compliance
- **Encryption**: File-level encryption for sensitive data
- **Access Control**: Role-based authorization system

## Support

For issues and questions:

- Check the [documentation](docs/)
- Review [troubleshooting guides](docs/ENVIRONMENT_SETUP.md#troubleshooting)
- Run validation scripts: `bin/validate-env.sh`

## License

This project is proprietary and confidential.
