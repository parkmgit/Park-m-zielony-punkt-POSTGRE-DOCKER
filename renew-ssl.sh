#!/bin/bash

# SSL Certificate Renewal Script
# Add to crontab to run automatically: 0 3 * * * /path/to/renew-ssl.sh

DOMAIN="trees.park-m.pl"

echo "🔄 Checking SSL certificate renewal for $DOMAIN..."

# Renew certificate
docker run --rm \
    -v $(pwd)/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot-www:/var/www/certbot \
    -p 80:80 \
    certbot/certbot renew \
    --webroot \
    --webroot-path=/var/www/certbot

# Restart nginx to load new certificate
if [ $? -eq 0 ]; then
    echo "✅ Certificate renewed successfully"
    echo "🔄 Restarting nginx..."
    docker-compose restart nginx
    echo "✅ Nginx restarted with new certificate"
else
    echo "❌ Certificate renewal failed"
    exit 1
fi
