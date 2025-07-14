# 🔒 SSL/HTTPS Setup for Crowdax API

Complete SSL setup with Let's Encrypt certificates for your Crowdax API on DigitalOcean.

## 🚀 Quick Deployment

### 1. Update Your Domain

```bash
# Set your domain
export DOMAIN=api.yourdomain.com

# Update deploy.yml
sed -i "s/crowdax-api.yourdomain.com/$DOMAIN/g" config/deploy.yml
```

### 2. Point DNS to DigitalOcean

Add these A records at your domain registrar:

```
api.yourdomain.com     → Your DigitalOcean droplet IP
www.api.yourdomain.com → Your DigitalOcean droplet IP
```

### 3. Deploy with SSL

```bash
# Automated deployment
./bin/deploy-ssl.sh

# Or manual deployment
bin/kamal deploy
```

### 4. Test SSL Setup

```bash
# Comprehensive SSL testing
./bin/test-ssl.sh

# Quick HTTPS test
curl -I https://api.yourdomain.com
```

## 📁 Files Created

### Configuration Files

- `config/deploy.yml` - Updated with SSL settings
- `config/nginx/ssl-headers.conf` - Security headers configuration

### Scripts

- `bin/deploy-ssl.sh` - Automated SSL deployment
- `bin/ssl-monitor.sh` - SSL certificate monitoring
- `bin/test-ssl.sh` - Comprehensive SSL testing

### Documentation

- `docs/SSL_SETUP.md` - Complete setup guide
- `QUICK_SSL_SETUP.md` - Quick start guide
- `README_SSL.md` - This file

## 🔧 Features Included

### ✅ SSL Certificate Management

- **Automatic Let's Encrypt certificates**
- **Auto-renewal every 60 days**
- **Certificate backup procedures**
- **Expiration monitoring**

### ✅ Security Headers

- **HSTS** (HTTP Strict Transport Security)
- **CSP** (Content Security Policy)
- **XSS Protection**
- **Frame Options** (Clickjacking protection)
- **Referrer Policy**

### ✅ SSL Configuration

- **TLS 1.2/1.3 only**
- **Strong cipher suites**
- **OCSP Stapling**
- **SSL session caching**

### ✅ Monitoring & Testing

- **Daily health checks**
- **Certificate expiration alerts**
- **HTTPS connectivity testing**
- **Security headers verification**

## 🛠️ Usage

### Deploy with SSL

```bash
# Automated deployment
./bin/deploy-ssl.sh

# Manual deployment
bin/kamal deploy
```

### Monitor SSL Health

```bash
# Daily health check
./bin/ssl-monitor.sh check

# Test HTTPS connectivity
./bin/ssl-monitor.sh test

# Backup certificates
./bin/ssl-monitor.sh backup

# Force renewal
./bin/ssl-monitor.sh renew
```

### Test SSL Configuration

```bash
# Comprehensive testing
./bin/test-ssl.sh

# Quick tests
curl -I https://api.yourdomain.com
openssl s_client -connect api.yourdomain.com:443
```

## 📊 Monitoring Setup

### Daily Monitoring

```bash
# Add to crontab
0 9 * * * /path/to/crowdax-api/bin/ssl-monitor.sh check
```

### Alert Configuration

Edit `bin/ssl-monitor.sh` to add your notification system:

- Email alerts
- Slack notifications
- Discord webhooks
- SMS alerts

## 🔍 Troubleshooting

### Common Issues

1. **DNS Not Propagated**

   ```bash
   nslookup api.yourdomain.com
   # Wait up to 48 hours for DNS propagation
   ```

2. **Certificate Not Issued**

   ```bash
   bin/kamal logs -f | grep -i ssl
   # Check deployment logs
   ```

3. **SSL Certificate Expired**

   ```bash
   bin/kamal app exec "certbot renew --force-renewal"
   ```

4. **Security Headers Missing**
   ```bash
   curl -I https://api.yourdomain.com | grep -i "strict-transport-security"
   ```

### SSL Labs Testing

Visit: https://www.ssllabs.com/ssltest/analyze.html?d=api.yourdomain.com

## 🔒 Security Best Practices

### Implemented

- ✅ **HSTS** - Forces HTTPS-only connections
- ✅ **CSP** - Content Security Policy protection
- ✅ **Strong Ciphers** - TLS 1.2/1.3 only
- ✅ **OCSP Stapling** - Improved SSL performance
- ✅ **Certificate Auto-renewal** - Never expires
- ✅ **Security Headers** - Comprehensive protection

### Recommended

- 🔄 **Regular SSL Labs testing** (monthly)
- 🔄 **Certificate backup verification** (weekly)
- 🔄 **Monitoring alert testing** (monthly)
- 🔄 **Disaster recovery testing** (quarterly)

## 📈 Performance

### SSL Optimizations

- **Session caching** - Faster SSL handshakes
- **OCSP stapling** - Reduced certificate validation time
- **Strong ciphers** - Optimal security/performance balance
- **HTTP/2 support** - Improved performance

### Monitoring Metrics

- Certificate expiration days
- HTTPS response time
- SSL handshake time
- Security header presence

## 🚨 Alerts & Notifications

### Certificate Alerts

- 30 days before expiration
- Certificate renewal failures
- HTTPS connectivity issues

### Security Alerts

- Missing security headers
- Weak cipher detection
- SSL Labs rating changes

## 📚 Documentation

### Guides

- `docs/SSL_SETUP.md` - Complete setup guide
- `QUICK_SSL_SETUP.md` - Quick start guide
- `README_SSL.md` - This overview

### Scripts

- `bin/deploy-ssl.sh` - Automated deployment
- `bin/ssl-monitor.sh` - Health monitoring
- `bin/test-ssl.sh` - Comprehensive testing

## 🎯 Next Steps

1. **Deploy your application** with SSL enabled
2. **Test the SSL configuration** thoroughly
3. **Set up monitoring alerts** for your team
4. **Document the setup** for your organization
5. **Regular security audits** (monthly/quarterly)

---

**Ready to deploy?** Just update your domain and run `./bin/deploy-ssl.sh`! 🚀

For support, check the troubleshooting section or review the full documentation in `docs/SSL_SETUP.md`.
