#!/bin/bash

# SSL Deployment Script for Crowdax API on DigitalOcean
# This script automates the SSL setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN=${DOMAIN:-"crowdax-api.yourdomain.com"}
DROPLET_IP=${DROPLET_IP:-"192.168.0.1"}

echo -e "${GREEN}🚀 SSL Deployment Script for Crowdax API${NC}"
echo "=========================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists kamal; then
    print_error "Kamal is not installed. Please install it first."
    exit 1
fi

if ! command_exists docker; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

print_status "Prerequisites check passed"

# Update deploy.yml with domain
echo "Updating deployment configuration..."

# Backup original deploy.yml
cp config/deploy.yml config/deploy.yml.backup

# Update domain in deploy.yml
sed -i.bak "s/crowdax-api.yourdomain.com/$DOMAIN/g" config/deploy.yml

print_status "Deployment configuration updated"

# Check DNS resolution
echo "Checking DNS resolution..."
if ! nslookup "$DOMAIN" >/dev/null 2>&1; then
    print_warning "DNS resolution failed for $DOMAIN"
    print_warning "Please ensure your domain points to $DROPLET_IP"
    echo "You can check with: nslookup $DOMAIN"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_status "DNS resolution successful"
fi

# Deploy with SSL
echo "Deploying with SSL enabled..."
if bin/kamal deploy; then
    print_status "Deployment successful"
else
    print_error "Deployment failed"
    exit 1
fi

# Wait for deployment to stabilize
echo "Waiting for deployment to stabilize..."
sleep 30

# Check SSL certificate
echo "Checking SSL certificate..."
if curl -I "https://$DOMAIN" >/dev/null 2>&1; then
    print_status "SSL certificate is working"
else
    print_warning "SSL certificate not yet available"
    print_warning "This is normal for the first deployment"
    print_warning "Certificate will be issued within a few minutes"
fi

# Test security headers
echo "Testing security headers..."
HEADERS=$(curl -I "https://$DOMAIN" 2>/dev/null || true)
if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    print_status "Security headers are configured"
else
    print_warning "Security headers not yet active"
fi

# SSL Labs test suggestion
echo ""
echo -e "${GREEN}🎉 SSL Setup Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Wait 5-10 minutes for Let's Encrypt certificate to be issued"
echo "2. Test your SSL configuration:"
echo "   - Visit: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo "   - Run: curl -I https://$DOMAIN"
echo "3. Monitor certificate renewal:"
echo "   - bin/kamal logs -f | grep -i ssl"
echo ""
echo "Certificate will auto-renew every 60 days"
echo ""

# Optional: Set up monitoring
read -p "Set up SSL certificate monitoring? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Setting up SSL monitoring..."
    
    # Create monitoring script
    cat > /tmp/ssl-monitor.sh << EOF
#!/bin/bash
DOMAIN="$DOMAIN"
CERT_FILE="/etc/letsencrypt/live/\$DOMAIN/fullchain.pem"

if [ -f "\$CERT_FILE" ]; then
    EXPIRY=\$(openssl x509 -enddate -noout -in "\$CERT_FILE" | cut -d= -f2)
    EXPIRY_EPOCH=\$(date -d "\$EXPIRY" +%s)
    CURRENT_EPOCH=\$(date +%s)
    DAYS_LEFT=\$(( (\$EXPIRY_EPOCH - \$CURRENT_EPOCH) / 86400 ))
    
    if [ \$DAYS_LEFT -lt 30 ]; then
        echo "WARNING: SSL certificate for \$DOMAIN expires in \$DAYS_LEFT days"
        # Add your notification logic here (email, Slack, etc.)
    fi
fi
EOF

    chmod +x /tmp/ssl-monitor.sh
    print_status "SSL monitoring script created at /tmp/ssl-monitor.sh"
    print_warning "Add to crontab: 0 9 * * * /tmp/ssl-monitor.sh"
fi

print_status "SSL deployment script completed successfully!" 