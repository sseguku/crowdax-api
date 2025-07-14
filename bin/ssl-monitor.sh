#!/bin/bash

# SSL Certificate Monitoring Script
# This script monitors SSL certificate expiration and sends alerts

set -e

# Configuration
DOMAIN=${DOMAIN:-"crowdax-api.yourdomain.com"}
ALERT_DAYS=${ALERT_DAYS:-30}
LOG_FILE="/var/log/ssl-monitor.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send alert (customize this for your notification system)
send_alert() {
    local message="$1"
    log_message "ALERT: $message"
    
    # Example: Send email alert
    # echo "$message" | mail -s "SSL Certificate Alert" admin@yourdomain.com
    
    # Example: Send Slack notification
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "{\"text\":\"$message\"}" \
    #   https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
    
    # Example: Send Discord notification
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "{\"content\":\"$message\"}" \
    #   https://discord.com/api/webhooks/YOUR/WEBHOOK
    
    echo "$message"
}

# Function to check certificate expiration
check_certificate() {
    local domain="$1"
    local cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"
    
    if [ ! -f "$cert_file" ]; then
        send_alert "SSL certificate file not found for $domain"
        return 1
    fi
    
    # Get certificate expiration date
    local expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
    local expiry_epoch=$(date -d "$expiry_date" +%s)
    local current_epoch=$(date +%s)
    local days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))
    
    log_message "Certificate for $domain expires in $days_left days"
    
    if [ $days_left -lt $ALERT_DAYS ]; then
        send_alert "SSL certificate for $domain expires in $days_left days"
        return 1
    fi
    
    return 0
}

# Function to test HTTPS connectivity
test_https() {
    local domain="$1"
    
    if curl -I "https://$domain" >/dev/null 2>&1; then
        log_message "HTTPS connectivity test passed for $domain"
        return 0
    else
        send_alert "HTTPS connectivity test failed for $domain"
        return 1
    fi
}

# Function to check SSL Labs rating (if available)
check_ssl_labs() {
    local domain="$1"
    
    # This is a basic check - for full SSL Labs integration, you'd need their API
    log_message "SSL Labs rating check for $domain (manual verification recommended)"
    
    # You can implement SSL Labs API integration here
    # curl -s "https://api.ssllabs.com/api/v3/analyze?host=$domain" | jq '.endpoints[0].grade'
}

# Function to check certificate renewal
check_renewal() {
    local domain="$1"
    
    # Check if certbot renewal is working
    if docker exec crowdax_api-web-1 certbot certificates | grep -q "$domain"; then
        log_message "Certificate renewal check passed for $domain"
        return 0
    else
        send_alert "Certificate renewal check failed for $domain"
        return 1
    fi
}

# Function to backup certificates
backup_certificates() {
    local domain="$1"
    local backup_dir="/backup/ssl"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$backup_dir"
    
    if docker exec crowdax_api-web-1 tar -czf "/tmp/ssl-backup-$timestamp.tar.gz" -C /etc/letsencrypt .; then
        docker cp crowdax_api-web-1:/tmp/ssl-backup-$timestamp.tar.gz "$backup_dir/"
        log_message "SSL certificates backed up to $backup_dir/ssl-backup-$timestamp.tar.gz"
        return 0
    else
        send_alert "SSL certificate backup failed for $domain"
        return 1
    fi
}

# Main monitoring function
main() {
    log_message "Starting SSL certificate monitoring for $DOMAIN"
    
    local status=0
    
    # Check certificate expiration
    if ! check_certificate "$DOMAIN"; then
        status=1
    fi
    
    # Test HTTPS connectivity
    if ! test_https "$DOMAIN"; then
        status=1
    fi
    
    # Check certificate renewal
    if ! check_renewal "$DOMAIN"; then
        status=1
    fi
    
    # Check SSL Labs rating (informational)
    check_ssl_labs "$DOMAIN"
    
    # Backup certificates (weekly)
    if [ "$(date +%u)" = "1" ]; then  # Monday
        backup_certificates "$DOMAIN"
    fi
    
    if [ $status -eq 0 ]; then
        log_message "SSL monitoring completed successfully"
    else
        log_message "SSL monitoring completed with issues"
    fi
    
    return $status
}

# Handle command line arguments
case "${1:-}" in
    "check")
        main
        ;;
    "backup")
        backup_certificates "$DOMAIN"
        ;;
    "test")
        test_https "$DOMAIN"
        ;;
    "renew")
        docker exec crowdax_api-web-1 certbot renew --force-renewal
        ;;
    *)
        echo "Usage: $0 {check|backup|test|renew}"
        echo ""
        echo "Commands:"
        echo "  check  - Run full SSL monitoring check"
        echo "  backup - Backup SSL certificates"
        echo "  test   - Test HTTPS connectivity"
        echo "  renew  - Force certificate renewal"
        echo ""
        echo "Environment variables:"
        echo "  DOMAIN       - Domain to monitor (default: crowdax-api.yourdomain.com)"
        echo "  ALERT_DAYS   - Days before expiration to alert (default: 30)"
        echo "  LOG_FILE     - Log file path (default: /var/log/ssl-monitor.log)"
        exit 1
        ;;
esac 