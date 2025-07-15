#!/bin/bash

# =============================================================================
# CROWDAX API ENVIRONMENT VALIDATION SCRIPT
# =============================================================================
# This script validates your environment configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if variable is set
check_variable() {
    local var_name=$1
    local required=$2
    local value=${!var_name}
    
    if [ -z "$value" ]; then
        if [ "$required" = "true" ]; then
            print_error "$var_name is not set (REQUIRED)"
            return 1
        else
            print_warning "$var_name is not set (optional)"
            return 0
        fi
    else
        if [ "$required" = "true" ]; then
            print_success "$var_name is set"
        else
            print_status "$var_name is set"
        fi
        return 0
    fi
}

# Function to check if file exists
check_file() {
    local file_path=$1
    local required=$2
    
    if [ -f "$file_path" ]; then
        print_success "$file_path exists"
        return 0
    else
        if [ "$required" = "true" ]; then
            print_error "$file_path does not exist (REQUIRED)"
            return 1
        else
            print_warning "$file_path does not exist (optional)"
            return 0
        fi
    fi
}

# Initialize error counter
errors=0

print_status "Validating Crowdax API environment configuration..."
echo ""

# Check if .env.local exists
if [ -f ".env.local" ]; then
    print_success ".env.local file exists"
    # Source the environment file
    set -a
    source .env.local
    set +a
else
    print_error ".env.local file does not exist"
    print_status "Run 'bin/setup-env.sh' to create it"
    errors=$((errors + 1))
fi

echo ""
print_status "Checking required environment variables..."

# Required variables
check_variable "RAILS_ENV" "true" || errors=$((errors + 1))
check_variable "RAILS_MASTER_KEY" "true" || errors=$((errors + 1))
check_variable "DATABASE_URL" "true" || errors=$((errors + 1))
check_variable "CROWDAX_API_DATABASE_PASSWORD" "true" || errors=$((errors + 1))

echo ""
print_status "Checking storage configuration..."

# Storage variables
check_variable "DO_SPACES_KEY" "true" || errors=$((errors + 1))
check_variable "DO_SPACES_SECRET" "true" || errors=$((errors + 1))
check_variable "DO_SPACES_BUCKET" "true" || errors=$((errors + 1))
check_variable "DO_SPACES_REGION" "false"
check_variable "DO_SPACES_ENDPOINT" "false"

echo ""
print_status "Checking security configuration..."

# Security variables
check_variable "JWT_SECRET_KEY" "false"
check_variable "ENCRYPTION_KEY" "false"

echo ""
print_status "Checking deployment configuration..."

# Deployment variables
check_variable "KAMAL_REGISTRY_PASSWORD" "true" || errors=$((errors + 1))
check_variable "DEPLOYMENT_HOST" "false"
check_variable "DEPLOYMENT_DOMAIN" "false"

echo ""
print_status "Checking email configuration..."

# Email variables
check_variable "SMTP_HOST" "false"
check_variable "SMTP_PORT" "false"
check_variable "MAILER_SENDER" "false"

echo ""
print_status "Checking application configuration..."

# Application variables
check_variable "PLATFORM_NAME" "false"
check_variable "PLATFORM_DESCRIPTION" "false"
check_variable "APP_HOST" "false"
check_variable "APP_URL" "false"

echo ""
print_status "Checking external services..."

# External services
check_variable "TERMS_AND_CONDITIONS_URL" "false"
check_variable "PRIVACY_POLICY_URL" "false"
check_variable "CONTACT_EMAIL" "false"
check_variable "CONTACT_PHONE" "false"

echo ""
print_status "Checking CORS configuration..."

# CORS variables
check_variable "CORS_ALLOWED_ORIGINS" "false"

echo ""
print_status "Checking required files..."

# Required files
check_file "config/master.key" "true" || errors=$((errors + 1))
check_file "config/credentials.yml.enc" "true" || errors=$((errors + 1))

echo ""
print_status "Checking database connection..."

# Test database connection if DATABASE_URL is set
if [ -n "$DATABASE_URL" ]; then
    if command -v psql &> /dev/null; then
        if psql "$DATABASE_URL" -c "SELECT 1;" &> /dev/null; then
            print_success "Database connection successful"
        else
            print_error "Database connection failed"
            errors=$((errors + 1))
        fi
    else
        print_warning "psql not found, skipping database connection test"
    fi
else
    print_warning "DATABASE_URL not set, skipping database connection test"
fi

echo ""
print_status "Checking Rails environment..."

# Check Rails environment
if [ -n "$RAILS_ENV" ]; then
    case $RAILS_ENV in
        "development"|"test"|"production"|"staging")
            print_success "RAILS_ENV is valid: $RAILS_ENV"
            ;;
        *)
            print_error "RAILS_ENV is invalid: $RAILS_ENV"
            errors=$((errors + 1))
            ;;
    esac
else
    print_error "RAILS_ENV is not set"
    errors=$((errors + 1))
fi

echo ""
print_status "Validation Summary"

if [ $errors -eq 0 ]; then
    print_success "All required configuration is valid!"
    print_status "Your environment is ready to use."
else
    print_error "Found $errors error(s) in configuration"
    print_status "Please fix the issues above before proceeding."
    print_status "Run 'bin/setup-env.sh' for help with setup."
fi

echo ""
print_status "Next steps:"
print_status "1. Start the Rails server: bin/rails server"
print_status "2. Run database migrations: bin/rails db:migrate"
print_status "3. Test the API endpoints"
print_status "4. Deploy to production when ready"

exit $errors 