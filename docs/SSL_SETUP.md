# SSL/HTTPS Setup Guide for Crowdax API

This guide will help you set up HTTPS with Let's Encrypt certificates for your Crowdax API.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Domain Configuration](#domain-configuration)
- [SSL Certificate Setup](#ssl-certificate-setup)
- [Testing SSL](#testing-ssl)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:

- A server with Ubuntu 20.04+ or 22.04+
- A registered domain name
- Root or sudo access to your server
- Docker and Docker Compose installed
- The Crowdax API deployed and running

## Domain Configuration

### 1. DNS Setup

Configure your domain's DNS records:

1. **Add A records** pointing to your server IP:

   ```
   api.yourdomain.com     → Your server IP
   www.api.yourdomain.com → Your server IP
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

## Testing SSL

Test your SSL setup using:

```bash
curl -v https://api.yourdomain.com
```

Or use [SSL Labs](https://www.ssllabs.com/ssltest/) for a full report.

## Maintenance

- Renew certificates regularly (Certbot can automate this)
- Monitor certificate expiration

## Troubleshooting

1. Check the troubleshooting section above
2. Verify DNS configuration
3. Check firewall settings
4. Review error logs
5. Test with SSL Labs

For additional help, refer to:

- [Let's Encrypt Community](https://community.letsencrypt.org/)

**Note**: Replace `api.yourdomain.com` with your actual domain name throughout this guide.
