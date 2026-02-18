#!/bin/bash
# create-site.sh — Creer un nouveau site pro
# Usage: ./scripts/create-site.sh <subdomain> [template]
# Exemple: ./scripts/create-site.sh bar-el-toro basic

set -e

SUBDOMAIN=$1
TEMPLATE=${2:-basic}

if [ -z "$SUBDOMAIN" ]; then
    echo "Usage: $0 <subdomain> [template]"
    echo "Exemple: $0 bar-el-toro basic"
    exit 1
fi

SITE_DIR="/data/sites/$SUBDOMAIN/public"

if [ -d "$SITE_DIR" ]; then
    echo "ERREUR: Le site $SUBDOMAIN existe deja dans $SITE_DIR"
    exit 1
fi

echo "Creation du site $SUBDOMAIN..."
sudo mkdir -p "$SITE_DIR"

# Copier le template si disponible
TEMPLATE_DIR="/data/templates/$TEMPLATE"
if [ -d "$TEMPLATE_DIR" ]; then
    sudo cp -r "$TEMPLATE_DIR/"* "$SITE_DIR/"
    echo "Template '$TEMPLATE' applique"
else
    echo "<html><head><title>$SUBDOMAIN</title></head><body><h1>$SUBDOMAIN.cblrs.net</h1><p>Site en construction</p></body></html>" | sudo tee "$SITE_DIR/index.html" > /dev/null
    echo "Page par defaut creee (pas de template '$TEMPLATE')"
fi

sudo chown -R www-data:www-data "/data/sites/$SUBDOMAIN"
sudo chmod -R 775 "/data/sites/$SUBDOMAIN"

echo "Site cree: https://$SUBDOMAIN.cblrs.net"
echo "Dossier: $SITE_DIR"
