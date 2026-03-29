#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
APP_DIR="/home/vagrant/youtube-repo"

mkdir -p $BACKUP_DIR

echo "Starting backup at $DATE"

# Backup application
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz $APP_DIR

echo "Backup completed: $BACKUP_DIR/app_backup_$DATE.tar.gz"

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Old backups cleaned up"
