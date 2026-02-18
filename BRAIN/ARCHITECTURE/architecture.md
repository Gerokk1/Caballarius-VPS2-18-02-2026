# Architecture VPS2 — cblrs.net

## Role
Usine a contenu + hebergeur de sites professionnels pour les etablissements du Camino de Santiago.
Objectif : 20 000-25 000 etablissements sur 326 routes de pelerinage europeennes.

## Composants

### 1. OpenClaw Agent (Bunker Mode)
- Container Docker isole (openclaw-bunker)
- Cerveau : Kimi K2.5 via OpenRouter
- 8 skills custom pour scraping + enrichissement + generation
- Workspace : /data/openclaw/workspace/

### 2. n8n Automation (Superviseur)
- Docker container, accessible via n8n.cblrs.net
- 4 workflows superviseur : planificateur, QC, rapport, watchdog
- Orchestre les missions de scraping + monitoring

### 3. MariaDB Staging
- BDD caballarius_staging : 14 tables
- 10 pays pre-inseres (ES, FR, PT, IT, DE, CH, AT, BE, NL, GB)
- 2 users : cblrs_user (full), staging_user (SELECT/INSERT/UPDATE)
- Stockage intermediaire avant sync vers VPS1

### 4. Generateur de sites pros
- Templates dans /data/templates/
- Sites generes dans /data/sites/{subdomain}/
- Servis par Nginx wildcard *.cblrs.net

### 5. API sync VPS1
- Push des donnees enrichies vers caballarius.eu
- HTTPS uniquement, token API

## Schema BDD — caballarius_staging (14 tables)

```
countries (1)
  |
  +-- regions (2) --> localities (5)
  |                      |
  +-- routes (3)         +-- establishments (7)
       |                      |
       +-- stages (4)         +-- establishment_photos (8)
       |                      +-- establishment_content (9)
       +-- route_localities   +-- establishment_prices (10)
            (6, pivot)        +-- establishment_sources (11)
                              +-- pro_sites (12)

scrape_jobs (13) -- tracking de tous les jobs
quality_checks (14) -- controle qualite automatise
```

### Tables detaillees

| # | Table | Description | FK vers |
|---|-------|-------------|---------|
| 1 | countries | Pays (ES, FR, PT, IT...) — 10 pre-inseres | - |
| 2 | regions | Regions/communautes | countries |
| 3 | routes | 326 routes pelerinage | countries |
| 4 | stages | Etapes de chaque route | routes, localities |
| 5 | localities | Villes/villages sur les routes | regions |
| 6 | route_localities | Pivot route <-> localite | routes, localities |
| 7 | establishments | 20-25K etablissements scrapes | localities |
| 8 | establishment_photos | Photos (Google, FB, IG...) | establishments |
| 9 | establishment_content | Contenu 3 langues + 3 profils | establishments |
| 10 | establishment_prices | Prix par profil (Chevalier/Moine/Pelerin) | establishments |
| 11 | establishment_sources | Donnees brutes des sources | establishments |
| 12 | pro_sites | Sites web generes ({subdomain}.cblrs.net) | establishments |
| 13 | scrape_jobs | Tracking de tous les jobs | - |
| 14 | quality_checks | Controle qualite (anomalies, doublons, coherence) | establishments |

### Table quality_checks (nouvelle)
```sql
CREATE TABLE quality_checks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  check_type VARCHAR(50) NOT NULL,        -- wrong_location, missing_data, incoherent_price, duplicate
  establishment_id INT,
  severity ENUM('info','warning','critical') DEFAULT 'info',
  description TEXT,
  auto_resolved BOOLEAN DEFAULT FALSE,
  resolved_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,
  FOREIGN KEY (establishment_id) REFERENCES establishments(id)
);
```

### Categories d'etablissements (32)
- HEBERGEMENTS : albergue, hotel, gite, pension, camping
- RESTAURATION : restaurant, bar, cafe, boulangerie, epicerie, supermarche
- SANTE : pharmacie, medecin, hopital, podologue
- SERVICES PELERIN : fontaine, laverie, banque, dab, poste, office_tourisme, location_velo, transport_bagages, taxi
- CULTURE : eglise, cathedrale, monastere, musee, monument, point_de_vue
- COUPS DE POUCE : artisan, coup_de_pouce

## Pipeline des 8 Skills OpenClaw

```
Localite (lat/lng)
     |
     v
[01-scrape-google] --> establishments + photos + sources
     |
     v
[02-scrape-facebook] --> photos + sources (enrichissement)
[03-scrape-instagram] --> photos geolocalisees
[04-scrape-tourisme] --> contexte culturel/patrimoine
[05-scrape-forums] --> avis pelerins (Gronze, CaminoWays...)
     |
     v (toutes les donnees scrapees)
[06-enrichir-contenu] --> Kimi K2.5 genere :
     |                     - 3 langues (FR/ES/EN)
     |                     - 3 profils (Chevalier/Moine/Pelerin)
     |                     - SEO, highlights, prix estimes
     v
[07-generer-site] --> HTML dans /data/sites/{subdomain}/
     |                 accessible via {subdomain}.cblrs.net
     v
[08-sync-vps1] --> API push vers caballarius.eu (production)
```

## N8N Superviseur (4 workflows)

```
[01-planificateur]     Cron 4h   → Query pending localities → OpenClaw scraping
[02-controle-qualite]  Cron 2h   → Check recent + duplicates → Kimi K2.5 analyse → quality_checks
[03-rapport-quotidien] Cron 20h  → Stats du jour → Kimi rapport → Telegram
[04-watchdog]          Cron 30m  → Check OpenClaw/jobs/disk/OpenRouter → Auto-fix + Telegram alerts
```

## Stack technique
- OS : Ubuntu (kernel 6.8.0-71-generic)
- Web : Nginx 1.24 (wildcard vhosts *.cblrs.net)
- Runtime : PHP 8.3, Node.js 20 LTS
- BDD : MariaDB 10.11 (caballarius_staging, 14 tables)
- Cache : Redis
- Agent IA : OpenClaw 2026.2.17 (Docker, bunker mode)
- LLM : Kimi K2.5 via OpenRouter (principal), Gemini 2.5 Flash (fallback)
- Automation : n8n (Docker) — 4 workflows superviseur
- SSL : Let's Encrypt / Certbot
- Conteneurs : Docker 29.2.1 + Docker Compose 5.0.2

## Structure disque /data (250 Go)
```
/data/
  sites/           <- Sites generes (20-25K sous-domaines)
  templates/       <- Templates HTML (caballarius-v1)
  n8n/             <- Persistence donnees n8n + workflows JSON
    workflows/     <- 4 workflows superviseur (JSON)
  openclaw/        <- Agent IA (config + workspace + skills)
  backups/         <- Sauvegardes
```

## Flux de donnees complet
```
Google Places API + Facebook + Instagram + Forums + Offices Tourisme
      |
      v
   OpenClaw (8 skills, orchestration IA)
      |             ^
      v             |
MariaDB staging (14 tables, VPS2)    <-- n8n superviseur (4 workflows)
      |                                    - planificateur (lance missions)
      +---> Kimi K2.5 (enrichissement    - QC (verifie qualite)
      |     3 langues, 3 profils)         - rapport (stats quotidiennes)
      |                                    - watchdog (monitoring infra)
      +---> Generation site pro -> /data/sites/{slug}/ -> {slug}.cblrs.net
      |
      +---> API push -> VPS1 (caballarius.eu) -> BDD production
```
