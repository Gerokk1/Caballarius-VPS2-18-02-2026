#!/bin/bash
# backup.sh — Sauvegarde des donnees critiques
# Usage: ./scripts/backup.sh

set -e

DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR="/data/backups/$DATE"

echo "=== Sauvegarde $DATE ==="
mkdir -p "$BACKUP_DIR"

# Backup MariaDB
echo "Backup MariaDB..."
sudo mariadb-dump --all-databases > "$BACKUP_DIR/mariadb_all.sql"
echo "MariaDB OK"

# Backup sites
echo "Backup sites..."
tar -czf "$BACKUP_DIR/sites.tar.gz" -C /data sites/
echo "Sites OK"

# Backup n8n data
echo "Backup n8n..."
tar -czf "$BACKUP_DIR/n8n.tar.gz" -C /data n8n/data/
echo "n8n OK"

# Backup nginx configs
echo "Backup nginx..."
tar -czf "$BACKUP_DIR/nginx.tar.gz" -C /etc/nginx sites-available/ sites-enabled/
echo "Nginx OK"

# Cleanup old backups (keep 7 days)
find /data/backups -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

echo "=== Sauvegarde terminee: $BACKUP_DIR ==="
du -sh "$BACKUP_DIR"
