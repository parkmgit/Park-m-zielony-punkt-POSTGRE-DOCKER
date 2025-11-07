#!/bin/bash

# Setup SSL for trees.park-m.pl using Let's Encrypt
# This script needs to be run on the server

DOMAIN="trees.park-m.pl"
EMAIL="admin@park-m.pl"  # Change this to your email

echo "🔧 Setting up SSL for $DOMAIN..."

# Create necessary directories
mkdir -p letsencrypt
mkdir -p certbot-www
mkdir -p ssl

# Stop nginx if running
docker-compose stop nginx

# Get SSL certificate (staging first for testing)
echo "📝 Getting SSL certificate (staging)..."
docker run --rm \
    -v $(pwd)/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot-www:/var/www/certbot \
    -p 80:80 \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --staging \
    -d $DOMAIN \
    -d www.$DOMAIN

# If staging works, get production certificate
echo "📝 Getting SSL certificate (production)..."
docker run --rm \
    -v $(pwd)/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot-www:/var/www/certbot \
    -p 80:80 \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

# Start nginx
echo "🚀 Starting nginx..."
docker-compose up -d nginx

echo "✅ SSL setup complete!"
echo "🌐 Your site is available at: https://$DOMAIN"
