#!/bin/bash

# =============================================================================
# CROWDAX API ENVIRONMENT SETUP SCRIPT
# =============================================================================
# This script helps you set up your environment variables for the Crowdax API

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

# Check if .env.local already exists
if [ -f ".env.local" ]; then
    print_warning ".env.local already exists. Do you want to overwrite it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled. Your existing .env.local file was preserved."
        exit 0
    fi
fi

# Copy template to .env.local
if [ -f "env.template" ]; then
    cp env.template .env.local
    print_success "Created .env.local from template"
else
    print_error "env.template not found. Please create it first."
    exit 1
fi

# Generate a secure Rails master key if not exists
if [ ! -f "config/master.key" ]; then
    print_status "Generating Rails master key..."
    rails credentials:edit
    print_success "Rails master key generated"
else
    print_status "Rails master key already exists"
fi

# Generate a secure encryption key
ENCRYPTION_KEY=$(openssl rand -hex 32)
sed -i.bak "s/your_32_character_encryption_key_here/$ENCRYPTION_KEY/" .env.local
print_success "Generated secure encryption key"

# Generate a secure JWT secret key
JWT_SECRET_KEY=$(openssl rand -hex 32)
sed -i.bak "s/your_jwt_secret_key_here/$JWT_SECRET_KEY/" .env.local
print_success "Generated secure JWT secret key"

# Remove backup files
rm -f .env.local.bak

print_success "Environment setup completed!"
print_status ""
print_status "Next steps:"
print_status "1. Edit .env.local with your actual values"
print_status "2. Set up your database credentials"
print_status "3. Configure DigitalOcean Spaces credentials"
print_status "4. Update deployment settings"
print_status "5. Configure email settings"
print_status ""
print_warning "IMPORTANT: Never commit .env.local to version control!"
print_status "The .env.local file is already in .gitignore" 