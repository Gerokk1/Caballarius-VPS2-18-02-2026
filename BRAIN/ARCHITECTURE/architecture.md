# Architecture VPS2 — cblrs.net

## Role
Usine a contenu + hebergeur de sites professionnels pour les etablissements du Camino de Santiago.

## Composants

### 1. Scraper automatise (n8n)
- n8n tourne dans Docker
- Accessible via n8n.cblrs.net (reverse proxy Nginx)
- Workflows :
  - Scraping Google Places API (etablissements le long des Caminos)
  - Enrichissement via Claude API (Anthropic)
  - Generation automatique des sites pros
  - Push des donnees vers VPS1 via API

### 2. Generateur de sites pros
- Templates dans /data/templates/
- Sites generes stockes dans /data/sites/{subdomain}/
- Chaque etablissement scrape obtient un site automatique

### 3. Hebergeur multi-sites
- Nginx wildcard : *.cblrs.net
- Chaque sous-domaine route vers /data/sites/{subdomain}/
- Exemples : bar-el-toro.cblrs.net, albergue-santiago.cblrs.net
- SSL wildcard via Let's Encrypt

### 4. API interne
- Envoie les donnees scrapees vers la BDD du VPS1 (caballarius.eu)
- Communication VPS2 -> VPS1

## Stack technique
- OS : Ubuntu
- Web : Nginx (wildcard vhosts)
- Runtime : PHP 8.3, Node.js 20 LTS
- BDD : MariaDB (staging local avant push VPS1)
- Cache : Redis
- Automation : n8n (Docker)
- SSL : Let's Encrypt / Certbot
- Conteneurs : Docker + Docker Compose

## Structure disque /data (250 Go)
```
/data/
  sites/          <- Sites generes pour les pros
  templates/      <- Templates de sites
  n8n/            <- Persistence donnees n8n
  backups/        <- Sauvegardes
```

## Flux de donnees
```
Google Places API
      |
      v
   n8n (scraping)
      |
      v
Claude API (enrichissement)
      |
      v
MariaDB staging (VPS2)
      |
      +---> Generation site pro -> /data/sites/{slug}/
      |
      +---> API push -> VPS1 (caballarius.eu)
```
