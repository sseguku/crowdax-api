# SSL/HTTPS Setup Guide for Crowdax API

This guide will help you set up HTTPS with Let's Encrypt certificates on DigitalOcean for your Crowdax API.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Domain Configuration](#domain-configuration)
- [SSL Certificate Setup](#ssl-certificate-setup)
- [Nginx Configuration](#nginx-configuration)
- [Testing SSL](#testing-ssl)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:

- A DigitalOcean droplet with Ubuntu 20.04+ or 22.04+
- A registered domain name
- Root or sudo access to your server
- Docker and Docker Compose installed
- The Crowdax API deployed and running

## Domain Configuration

### 1. DNS Setup

Configure your domain's DNS records:

1. **Add A records** pointing to your DigitalOcean droplet IP:

   ```
   api.yourdomain.com     → Your DigitalOcean droplet IP
   www.api.yourdomain.com → Your DigitalOcean droplet IP
   ```

2. **Verify DNS propagation**:
   ```bash
   nslookup api.yourdomain.com
   dig api.yourdomain.com
   ```

### 2. Wait for DNS Propagation

DNS changes can take up to 48 hours to propagate globally. You can check propagation using:

```bash
# Check from multiple locations
dig +short api.yourdomain.com @8.8.8.8
dig +short api.yourdomain.com @1.1.1.1
```

## SSL Certificate Setup

### 1. Environment Configuration

Set your domain in your environment:

```bash
# Add to your .env file or environment variables
export DOMAIN=api.yourdomain.com
```

### 2. Let's Encrypt Certificate

#### Option A: Automatic Setup (Recommended)

Use the provided SSL setup script:

```bash
# Make script executable
chmod +x bin/ssl-setup.sh

# Run SSL setup
./bin/ssl-setup.sh
```

#### Option B: Manual Setup

1. **Install Certbot**:

   ```bash
   sudo apt update
   sudo apt install certbot
   ```

2. **Obtain SSL Certificate**:

   ```bash
   sudo certbot certonly --standalone -d api.yourdomain.com
   ```

3. **Verify Certificate**:
   ```bash
   sudo certbot certificates
   ```

### 3. Certificate Files Location

Certificates will be stored in:

```
/etc/letsencrypt/live/api.yourdomain.com/
├── fullchain.pem
├── privkey.pem
├── chain.pem
└── cert.pem
```

## Nginx Configuration

### 1. SSL Configuration

Create SSL configuration file:

```bash
sudo nano /etc/nginx/sites-available/crowdax-api
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com www.api.yourdomain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com www.api.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    # SSL Security Headers
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Proxy Configuration
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Health check endpoint
    location /up {
        proxy_pass http://localhost:3000/up;
        access_log off;
    }

    # Static files (if any)
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_pass http://localhost:3000;
    }
}
```

### 2. Enable Site

```bash
# Create symlink
sudo ln -s /etc/nginx/sites-available/crowdax-api /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### 3. Firewall Configuration

```bash
# Allow HTTPS traffic
sudo ufw allow 443/tcp

# Allow HTTP (for Let's Encrypt challenges)
sudo ufw allow 80/tcp

# Check firewall status
sudo ufw status
```

## Testing SSL

### 1. Basic HTTPS Test

```bash
# Test HTTPS response
curl -I https://api.yourdomain.com

# Test SSL certificate
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com
```

### 2. SSL Labs Test

Visit SSL Labs to get a comprehensive SSL rating:

```
https://www.ssllabs.com/ssltest/analyze.html?d=api.yourdomain.com
```

### 3. Security Headers Test

```bash
# Test security headers
curl -I https://api.yourdomain.com | grep -i "strict-transport-security\|x-frame-options\|x-content-type-options"
```

### 4. API Endpoint Test

```bash
# Test API health endpoint
curl https://api.yourdomain.com/up

# Test public API endpoint
curl https://api.yourdomain.com/api/v1/public/statistics
```

## Maintenance

### 1. Certificate Renewal

Let's Encrypt certificates expire after 90 days. Set up automatic renewal:

```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab for automatic renewal
sudo crontab -e
```

Add this line to run renewal twice daily:

```
0 12 * * * /usr/bin/certbot renew --quiet
```

### 2. Certificate Monitoring

Create a monitoring script:

```bash
#!/bin/bash
DOMAIN="api.yourdomain.com"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$CERT_FILE" ]; then
    EXPIRY=$(openssl x509 -in "$CERT_FILE" -text -noout | grep "Not After" | cut -d: -f2-)
    echo "Certificate for $DOMAIN expires: $EXPIRY"
else
    echo "Certificate file not found for $DOMAIN"
fi
```

### 3. Backup SSL Configuration

```bash
# Backup SSL certificates
sudo tar -czf /tmp/ssl-backup-$(date +%Y%m%d).tar.gz /etc/letsencrypt

# Backup Nginx configuration
sudo tar -czf /tmp/nginx-backup-$(date +%Y%m%d).tar.gz /etc/nginx
```

## Troubleshooting

### Common Issues

#### 1. Certificate Not Found

**Error**: `ssl_certificate: cannot load certificate`

**Solution**:

```bash
# Check certificate exists
sudo ls -la /etc/letsencrypt/live/api.yourdomain.com/

# Verify certificate validity
sudo certbot certificates

# Re-obtain certificate if needed
sudo certbot certonly --standalone -d api.yourdomain.com
```

#### 2. DNS Resolution Issues

**Error**: `Could not connect to api.yourdomain.com`

**Solution**:

```bash
# Check DNS resolution
nslookup api.yourdomain.com
dig api.yourdomain.com

# Check from multiple DNS servers
dig api.yourdomain.com @8.8.8.8
dig api.yourdomain.com @1.1.1.1
```

#### 3. Nginx Configuration Errors

**Error**: `nginx: configuration file test failed`

**Solution**:

```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check Nginx access logs
sudo tail -f /var/log/nginx/access.log
```

#### 4. Let's Encrypt Rate Limiting

**Error**: `Too many certificates already issued`

**Solution**:

- Wait for rate limit reset (7 days)
- Use staging environment for testing:
  ```bash
  sudo certbot certonly --standalone --staging -d api.yourdomain.com
  ```

#### 5. Port 80/443 Already in Use

**Error**: `Port 80 is already in use`

**Solution**:

```bash
# Check what's using the ports
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Stop conflicting services
sudo systemctl stop apache2  # if Apache is running
sudo systemctl stop nginx    # if Nginx is already running
```

### SSL Certificate Validation

#### Check Certificate Details

```bash
# View certificate information
sudo openssl x509 -in /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem -text -noout

# Check certificate expiration
sudo openssl x509 -in /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem -noout -dates
```

#### Verify Certificate Chain

```bash
# Verify certificate chain
sudo openssl verify -CAfile /etc/letsencrypt/live/api.yourdomain.com/chain.pem /etc/letsencrypt/live/api.yourdomain.com/cert.pem
```

### Performance Optimization

#### SSL Configuration Optimization

```nginx
# Add to your Nginx SSL configuration
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
```

#### HTTP/2 Optimization

```nginx
# Enable HTTP/2
listen 443 ssl http2;

# Optimize for HTTP/2
http2_push_preload on;
```

## Security Best Practices

### 1. SSL Configuration

- Use TLS 1.2 and 1.3 only
- Disable weak ciphers
- Enable HSTS
- Use secure cipher suites

### 2. Security Headers

- Implement Content Security Policy (CSP)
- Add X-Frame-Options
- Add X-Content-Type-Options
- Add X-XSS-Protection

### 3. Certificate Management

- Monitor certificate expiration
- Set up automatic renewal
- Backup certificates regularly
- Use strong private keys

### 4. Monitoring

- Monitor SSL certificate expiration
- Set up alerts for certificate issues
- Log SSL-related errors
- Monitor SSL Labs ratings

## Additional Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Nginx SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [SSL Labs Test](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

## Support

If you encounter SSL-related issues:

1. Check the troubleshooting section above
2. Verify DNS configuration
3. Check firewall settings
4. Review Nginx error logs
5. Test with SSL Labs

For additional help, refer to:

- [Let's Encrypt Community](https://community.letsencrypt.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [DigitalOcean SSL Tutorials](https://www.digitalocean.com/community/tutorials?q=ssl)

**Note**: Replace `api.yourdomain.com` with your actual domain name throughout this guide.
