# Caballarius VPS2 — cblrs.net

Usine a contenu + hebergeur de sites professionnels pour les etablissements du Camino de Santiago.

## Architecture

- **Scraping** : n8n + Google Places API + Claude API
- **Generation** : Sites pros automatiques pour chaque etablissement
- **Hebergement** : Nginx wildcard *.cblrs.net
- **Staging** : MariaDB locale avant push vers VPS1

## Structure

```
docker-compose.yml    # n8n Docker
nginx/                # Configs vhosts Nginx
templates/            # Templates sites pros
scripts/              # Scripts utilitaires
  deploy.sh           # Deploiement configs
  create-site.sh      # Creer un site pro
  backup.sh           # Sauvegarde
BRAIN/                # Memoire persistante du projet
```

## Stack

Nginx 1.24 | PHP 8.3 | MariaDB 10.11 | Redis | Node.js 20 | Docker | n8n

## Domaines

- `cblrs.net` — Dashboard principal
- `n8n.cblrs.net` — Interface n8n
- `*.cblrs.net` — Sites des etablissements
