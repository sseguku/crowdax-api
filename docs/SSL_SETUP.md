# SSL/HTTPS Setup Guide for Crowdax API on DigitalOcean

This guide will help you set up HTTPS with Let's Encrypt certificates on DigitalOcean for your Crowdax API.

## Prerequisites

1. **Domain Name**: You need a domain name pointing to your DigitalOcean droplet
2. **DigitalOcean Droplet**: Running Ubuntu 22.04 or later
3. **Kamal Deployment**: Already configured and working

## Step 1: Domain Configuration

### 1.1 Point Your Domain to DigitalOcean

1. Go to your domain registrar (GoDaddy, Namecheap, etc.)
2. Update your domain's DNS settings:
   - Add an A record: `api.yourdomain.com` → Your DigitalOcean droplet IP
   - Add an A record: `www.api.yourdomain.com` → Your DigitalOcean droplet IP

### 1.2 Verify DNS Propagation

```bash
# Check if your domain resolves to your server
nslookup api.yourdomain.com
dig api.yourdomain.com
```

## Step 2: Update Kamal Configuration

### 2.1 Update deploy.yml

```yaml
# config/deploy.yml
proxy:
  ssl: true
  host: api.yourdomain.com # Replace with your actual domain
```

### 2.2 Set Environment Variables

```bash
# Set your domain in environment
export DOMAIN=api.yourdomain.com
```

## Step 3: Deploy with SSL

### 3.1 Deploy Your Application

```bash
# Deploy with SSL enabled
bin/kamal deploy

# Check deployment status
bin/kamal status
```

### 3.2 Verify SSL Certificate

```bash
# Check if SSL certificate is working
curl -I https://api.yourdomain.com

# Test SSL certificate details
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com
```

## Step 4: SSL Certificate Management

### 4.1 Automatic Renewal

Kamal automatically handles Let's Encrypt certificate renewal. The certificates are renewed automatically when they're within 30 days of expiration.

### 4.2 Manual Certificate Check

```bash
# SSH into your server
ssh root@your-droplet-ip

# Check certificate status
docker exec crowdax_api-web-1 certbot certificates

# Check certificate expiration
docker exec crowdax_api-web-1 openssl x509 -in /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem -text -noout | grep "Not After"
```

### 4.3 Force Certificate Renewal

```bash
# Force renewal (if needed)
bin/kamal app exec "certbot renew --force-renewal"
```

## Step 5: Security Headers

### 5.1 Add Security Headers

Create a custom nginx configuration for additional security headers:

```bash
# Create custom nginx config
mkdir -p config/nginx
```

Create `config/nginx/ssl-headers.conf`:

```nginx
# Security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:; frame-ancestors 'self';" always;

# Remove server version
server_tokens off;
```

### 5.2 Update deploy.yml to include custom nginx config

```yaml
# config/deploy.yml
proxy:
  ssl: true
  host: api.yourdomain.com
  files:
    - config/nginx/ssl-headers.conf:/etc/nginx/conf.d/ssl-headers.conf
```

## Step 6: SSL Testing

### 6.1 Test SSL Configuration

```bash
# Test with SSL Labs (online)
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=api.yourdomain.com

# Test with curl
curl -I https://api.yourdomain.com

# Test with OpenSSL
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com
```

### 6.2 Check Security Headers

```bash
# Check security headers
curl -I https://api.yourdomain.com | grep -i "strict-transport-security\|x-frame-options\|x-content-type-options"
```

## Step 7: Monitoring and Maintenance

### 7.1 Set Up Monitoring

```bash
# Create a monitoring script
cat > /usr/local/bin/ssl-monitor.sh << 'EOF'
#!/bin/bash
DOMAIN="api.yourdomain.com"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$CERT_FILE" ]; then
    EXPIRY=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

    if [ $DAYS_LEFT -lt 30 ]; then
        echo "WARNING: SSL certificate for $DOMAIN expires in $DAYS_LEFT days"
        # Add your notification logic here
    fi
fi
EOF

chmod +x /usr/local/bin/ssl-monitor.sh

# Add to crontab for daily monitoring
echo "0 9 * * * /usr/local/bin/ssl-monitor.sh" | crontab -
```

### 7.2 Log Monitoring

```bash
# Monitor SSL-related logs
bin/kamal logs -f | grep -i ssl\|cert\|letsencrypt
```

## Troubleshooting

### Common Issues

1. **DNS Not Propagated**

   ```bash
   # Wait for DNS propagation (can take up to 48 hours)
   dig api.yourdomain.com
   ```

2. **Certificate Not Issued**

   ```bash
   # Check nginx logs
   bin/kamal logs -f

   # Check certbot logs
   docker exec crowdax_api-web-1 certbot logs
   ```

3. **SSL Certificate Expired**

   ```bash
   # Force renewal
   bin/kamal app exec "certbot renew --force-renewal"
   ```

4. **Mixed Content Issues**
   - Ensure all resources (CSS, JS, images) are served over HTTPS
   - Update any hardcoded HTTP URLs in your application

### SSL Configuration Best Practices

1. **Use Strong Ciphers**

   - Kamal automatically configures strong ciphers
   - Test with SSL Labs for A+ rating

2. **Enable HSTS**

   - Already configured in security headers
   - Ensures browsers only connect via HTTPS

3. **Regular Monitoring**

   - Set up certificate expiration monitoring
   - Monitor SSL Labs rating

4. **Backup Certificates**
   ```bash
   # Backup certificates
   docker exec crowdax_api-web-1 tar -czf /tmp/ssl-backup.tar.gz /etc/letsencrypt
   ```

## Verification Checklist

- [ ] Domain points to DigitalOcean droplet
- [ ] Kamal deployment successful with SSL enabled
- [ ] SSL certificate issued by Let's Encrypt
- [ ] HTTPS redirects working
- [ ] Security headers configured
- [ ] SSL Labs rating A or A+
- [ ] Certificate auto-renewal working
- [ ] Monitoring scripts in place

## Next Steps

1. **Set up monitoring alerts** for certificate expiration
2. **Configure backup procedures** for SSL certificates
3. **Test disaster recovery** procedures
4. **Document the setup** for your team

---

**Note**: Replace `api.yourdomain.com` with your actual domain name throughout this guide.
