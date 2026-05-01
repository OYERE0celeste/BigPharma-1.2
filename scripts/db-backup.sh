#!/bin/bash

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MONGO_URI=${MONGODB_URI:-"mongodb://localhost:27017/bigpharma"}
DB_NAME=${DB_NAME:-"bigpharma"}

echo "📂 Starting database backup..."

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Run mongodump
docker exec mongodb mongodump --uri="$MONGO_URI" --archive=$BACKUP_DIR/backup_$TIMESTAMP.archive --gzip

# Keep only the last 7 days of backups
find $BACKUP_DIR -type f -name "*.archive" -mtime +7 -delete

echo "✅ Backup completed: $BACKUP_DIR/backup_$TIMESTAMP.archive"
