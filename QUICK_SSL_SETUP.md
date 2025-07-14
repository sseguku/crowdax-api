# Quick SSL Setup for Crowdax API

## 🚀 Quick Start (5 minutes)

### 1. Update Your Domain

Replace `crowdax-api.yourdomain.com` with your actual domain in:

- `config/deploy.yml` (line 15)
- Environment variable: `export DOMAIN=your-actual-domain.com`

### 2. Point DNS to DigitalOcean

Add these A records at your domain registrar:

```
api.yourdomain.com     → Your DigitalOcean droplet IP
www.api.yourdomain.com → Your DigitalOcean droplet IP
```

### 3. Deploy with SSL

```bash
# Set your domain
export DOMAIN=api.yourdomain.com

# Run the automated SSL deployment
./bin/deploy-ssl.sh
```

### 4. Verify Setup

```bash
# Test HTTPS
curl -I https://api.yourdomain.com

# Check SSL certificate
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com

# Test SSL Labs (online)
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=api.yourdomain.com
```

## 🔧 Manual Setup (if needed)

### 1. Update deploy.yml

```yaml
proxy:
  ssl: true
  host: api.yourdomain.com # Your domain here
  files:
    - config/nginx/ssl-headers.conf:/etc/nginx/conf.d/ssl-headers.conf
```

### 2. Deploy

```bash
bin/kamal deploy
```

### 3. Monitor

```bash
# Check logs
bin/kamal logs -f

# Monitor SSL health
./bin/ssl-monitor.sh check
```

## 📋 What's Included

✅ **Automatic Let's Encrypt certificates**  
✅ **Security headers** (HSTS, CSP, etc.)  
✅ **Strong SSL ciphers** (TLS 1.2/1.3)  
✅ **Auto-renewal** (every 60 days)  
✅ **Monitoring scripts**  
✅ **Backup procedures**

## 🛠️ Troubleshooting

### Certificate Not Issued

```bash
# Check DNS propagation
nslookup api.yourdomain.com

# Check deployment logs
bin/kamal logs -f | grep -i ssl
```

### Force Renewal

```bash
bin/kamal app exec "certbot renew --force-renewal"
```

### Test Security Headers

```bash
curl -I https://api.yourdomain.com | grep -i "strict-transport-security"
```

## 📊 Monitoring

### Daily Health Check

```bash
# Add to crontab
0 9 * * * /path/to/crowdax-api/bin/ssl-monitor.sh check
```

### Manual Checks

```bash
# Test connectivity
./bin/ssl-monitor.sh test

# Backup certificates
./bin/ssl-monitor.sh backup

# Force renewal
./bin/ssl-monitor.sh renew
```

## 🔒 Security Features

- **HSTS**: Forces HTTPS-only connections
- **CSP**: Content Security Policy protection
- **XSS Protection**: Cross-site scripting protection
- **Frame Options**: Clickjacking protection
- **OCSP Stapling**: Improved SSL performance
- **Strong Ciphers**: TLS 1.2/1.3 only

## 📞 Support

If you encounter issues:

1. Check the full guide: `docs/SSL_SETUP.md`
2. Review logs: `bin/kamal logs -f`
3. Test connectivity: `./bin/ssl-monitor.sh test`

---

**Ready to deploy?** Just update your domain and run `./bin/deploy-ssl.sh`! 🎉
