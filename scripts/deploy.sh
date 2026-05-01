#!/bin/bash

# Configuration
APP_DIR="/opt/bigpharma"
DOCKER_IMAGE="your-username/bigpharma-api:latest"

echo "🚀 Starting deployment..."

# Go to app directory
cd $APP_DIR || exit

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose pull api

# Restart services
echo "🔄 Restarting services..."
docker-compose up -d --remove-orphans api nginx

# Cleanup unused images
echo "🧹 Cleaning up old images..."
docker image prune -f

echo "✅ Deployment successful!"
