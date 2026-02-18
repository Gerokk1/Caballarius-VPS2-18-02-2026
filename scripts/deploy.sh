#!/bin/bash
# deploy.sh — Deploiement des configs depuis le repo vers le serveur
# Usage: ./scripts/deploy.sh

set -e

echo "=== Deploiement configs Nginx ==="
sudo cp nginx/cblrs-main.conf /etc/nginx/sites-available/cblrs-main
sudo cp nginx/cblrs-wildcard.conf /etc/nginx/sites-available/cblrs-wildcard
sudo cp nginx/cblrs-n8n.conf /etc/nginx/sites-available/cblrs-n8n

sudo ln -sf /etc/nginx/sites-available/cblrs-main /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/cblrs-wildcard /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/cblrs-n8n /etc/nginx/sites-enabled/

sudo nginx -t && sudo systemctl reload nginx
echo "Nginx OK"

echo "=== Deploiement docker-compose n8n ==="
sudo cp docker-compose.yml /data/n8n/docker-compose.yml
cd /data/n8n && sudo docker compose up -d
echo "n8n OK"

echo "=== Deploiement termine ==="
