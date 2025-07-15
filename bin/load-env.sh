#!/bin/bash

# =============================================================================
# CROWDAX API ENVIRONMENT LOADER
# =============================================================================
# This script loads environment variables for development and testing

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if .env.local exists
if [ -f ".env.local" ]; then
    print_status "Loading environment variables from .env.local..."
    
    # Export all variables from .env.local
    set -a
    source .env.local
    set +a
    
    print_success "Environment variables loaded successfully"
    
    # Show current environment
    echo ""
    print_status "Current environment: $RAILS_ENV"
    print_status "Database URL: ${DATABASE_URL:-'Not set'}"
    print_status "Storage bucket: ${DO_SPACES_BUCKET:-'Not set'}"
    
else
    print_status "No .env.local file found"
    print_status "Run 'bin/setup-env.sh' to create it"
fi

# Export the function to make it available to child processes
export -f print_status
export -f print_success 