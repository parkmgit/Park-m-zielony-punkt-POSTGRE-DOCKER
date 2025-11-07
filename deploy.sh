#!/bin/bash

# Park M Trees - Deployment Script
# Usage: ./deploy.sh

set -e

echo "🚀 Starting deployment of Park M Trees..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p letsencrypt
mkdir -p certbot-www
mkdir -p ssl

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Build and start containers
echo "🔨 Building and starting containers..."
docker-compose up -d --build

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Initialize database
echo "🗄️ Initializing database..."
curl -f http://localhost/api/init || echo "Database initialization might have failed, please check logs"

# Show status
echo "📊 Container status:"
docker-compose ps

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your application is available at: http://localhost"
echo ""
echo "📝 Next steps:"
echo "1. Configure your domain to point to this server"
echo "2. Run ./setup-ssl.sh to enable HTTPS"
echo "3. Visit https://trees.park-m.pl"
echo ""
echo "🔧 Useful commands:"
echo "- View logs: docker-compose logs"
echo "- Stop app: docker-compose down"
echo "- Update app: docker-compose up -d --build"
