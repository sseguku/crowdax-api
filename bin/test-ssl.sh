#!/bin/bash

# SSL Testing Script for Crowdax API
# This script performs comprehensive SSL testing

set -e

# Configuration
DOMAIN=${DOMAIN:-"crowdax-api.yourdomain.com"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "${BLUE}🔒 SSL Testing Script for Crowdax API${NC}"
echo "=========================================="
echo "Domain: $DOMAIN"
echo ""

# Test 1: DNS Resolution
echo "1. Testing DNS resolution..."
if nslookup "$DOMAIN" >/dev/null 2>&1; then
    print_status "DNS resolution successful"
else
    print_error "DNS resolution failed"
    exit 1
fi

# Test 2: HTTP to HTTPS redirect
echo ""
echo "2. Testing HTTP to HTTPS redirect..."
if curl -I "http://$DOMAIN" 2>/dev/null | grep -q "301\|302"; then
    print_status "HTTP to HTTPS redirect working"
else
    print_warning "HTTP to HTTPS redirect not detected"
fi

# Test 3: HTTPS connectivity
echo ""
echo "3. Testing HTTPS connectivity..."
if curl -I "https://$DOMAIN" >/dev/null 2>&1; then
    print_status "HTTPS connectivity successful"
else
    print_error "HTTPS connectivity failed"
    exit 1
fi

# Test 4: SSL certificate details
echo ""
echo "4. Testing SSL certificate..."
CERT_INFO=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" < /dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || true)

if [ -n "$CERT_INFO" ]; then
    print_status "SSL certificate found"
    echo "$CERT_INFO"
else
    print_error "SSL certificate not found"
fi

# Test 5: Security headers
echo ""
echo "5. Testing security headers..."
HEADERS=$(curl -I "https://$DOMAIN" 2>/dev/null || true)

echo "Checking security headers:"
if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    print_status "HSTS header present"
else
    print_warning "HSTS header missing"
fi

if echo "$HEADERS" | grep -q "X-Frame-Options"; then
    print_status "X-Frame-Options header present"
else
    print_warning "X-Frame-Options header missing"
fi

if echo "$HEADERS" | grep -q "X-Content-Type-Options"; then
    print_status "X-Content-Type-Options header present"
else
    print_warning "X-Content-Type-Options header missing"
fi

if echo "$HEADERS" | grep -q "X-XSS-Protection"; then
    print_status "X-XSS-Protection header present"
else
    print_warning "X-XSS-Protection header missing"
fi

if echo "$HEADERS" | grep -q "Content-Security-Policy"; then
    print_status "CSP header present"
else
    print_warning "CSP header missing"
fi

# Test 6: SSL Labs rating suggestion
echo ""
echo "6. SSL Labs rating check..."
print_info "For detailed SSL analysis, visit:"
echo "https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"

# Test 7: Certificate expiration
echo ""
echo "7. Checking certificate expiration..."
if command -v openssl >/dev/null 2>&1; then
    EXPIRY=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" < /dev/null 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || echo "0")
        CURRENT_EPOCH=$(date +%s)
        DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
        
        if [ $DAYS_LEFT -gt 0 ]; then
            print_status "Certificate expires in $DAYS_LEFT days"
        else
            print_error "Certificate has expired"
        fi
    else
        print_warning "Could not determine certificate expiration"
    fi
else
    print_warning "OpenSSL not available for detailed certificate check"
fi

# Test 8: Cipher suite check
echo ""
echo "8. Testing cipher suites..."
CIPHERS=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" < /dev/null 2>/dev/null | grep "Cipher is" || true)

if [ -n "$CIPHERS" ]; then
    print_status "Cipher suite information:"
    echo "$CIPHERS"
else
    print_warning "Could not determine cipher suite"
fi

# Test 9: OCSP Stapling
echo ""
echo "9. Testing OCSP Stapling..."
OCSP=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" -status < /dev/null 2>/dev/null | grep "OCSP Response Status" || true)

if echo "$OCSP" | grep -q "successful"; then
    print_status "OCSP Stapling working"
else
    print_warning "OCSP Stapling not detected"
fi

# Test 10: API endpoint test
echo ""
echo "10. Testing API endpoints..."
API_ENDPOINTS=(
    "/api/v1/health"
    "/api/v1/users/profile"
    "/api/v1/campaigns"
)

for endpoint in "${API_ENDPOINTS[@]}"; do
    if curl -I "https://$DOMAIN$endpoint" >/dev/null 2>&1; then
        print_status "API endpoint $endpoint accessible"
    else
        print_warning "API endpoint $endpoint not accessible"
    fi
done

# Summary
echo ""
echo -e "${BLUE}📊 SSL Test Summary${NC}"
echo "===================="

if command -v curl >/dev/null 2>&1 && curl -I "https://$DOMAIN" >/dev/null 2>&1; then
    print_status "HTTPS is working"
else
    print_error "HTTPS is not working"
fi

if nslookup "$DOMAIN" >/dev/null 2>&1; then
    print_status "DNS is configured"
else
    print_error "DNS is not configured"
fi

echo ""
print_info "Next steps:"
echo "1. Visit SSL Labs for detailed analysis: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo "2. Set up monitoring: ./bin/ssl-monitor.sh check"
echo "3. Add to crontab for daily checks: 0 9 * * * ./bin/ssl-monitor.sh check"
echo ""

print_status "SSL testing completed!" 