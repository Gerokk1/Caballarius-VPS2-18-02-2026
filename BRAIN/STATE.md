# ETAT ACTUEL DU PROJET — VPS2

**Derniere mise a jour : 2026-02-18 20:05**

## Resume
VPS2 (cblrs.net) PLEINEMENT OPERATIONNEL. HTTPS actif. OpenClaw bunker mode + securite audit 25/25. BDD staging 14 tables, 38 pays, 305 routes, 2356 localites, 1795 etapes, langues dynamiques. TOUTES les 305 routes ont des etapes (0 manquante). 8 skills custom (squelettes). 4 workflows n8n (squelettes JSON).

## Ce qui fonctionne
- [x] https://cblrs.net → 200 (SSL, redirect HTTP→HTTPS)
- [x] https://www.cblrs.net → 200 (SSL)
- [x] https://n8n.cblrs.net → 200 (SSL, reverse proxy vers Docker n8n)
- [x] http://test.cblrs.net → 200 (wildcard vhost fonctionne)
- [x] SSH ubuntu@83.228.211.132:22
- [x] Disque 250 Go monte (/data, 233 Go libres)
- [x] Securite : UFW, Fail2Ban, SSH durci, unattended upgrades
- [x] Stack : Nginx 1.24, PHP 8.3, MariaDB 10.11, Redis, Node.js 20, Docker 29, Certbot 2.9
- [x] n8n Docker UP
- [x] Structure /data (sites/, templates/, n8n/, backups/)
- [x] Repo GitHub (Gerokk1/Caballarius-VPS2-18-02-2026)
- [x] Ports 80/443/5678 ouverts (Infomaniak Security Group)
- [x] DNS *.cblrs.net → 83.228.211.132

## OpenClaw (Bunker Mode)
- [x] Container openclaw-bunker UP (alpine/openclaw:latest v2026.2.17)
- [x] Gateway ecoute ws://0.0.0.0:18789
- [x] Port 127.0.0.1:18789 uniquement (localhost, PAS expose)
- [x] Reseau Docker isole (openclaw-isolated, separe de n8n)
- [x] Auth token requis (401 sans token)
- [x] Modele principal : openrouter/moonshotai/kimi-k2.5
- [x] Config : /data/openclaw/config/openclaw.json
- [x] Workspace : /data/openclaw/workspace
- [x] API key OpenRouter configuree et testee (Kimi K2.5 repond)
- [ ] API key Google AI Studio (Gemini 2.5 Flash) — placeholder
- [x] Anti-prompt injection (HEARTBEAT.md)
- [x] Exec security (tools.exec.security=allowlist)
- [x] Audit securite 25/25 (cap_drop ALL, no-new-privileges, chmod 600)

## BDD Staging (MariaDB caballarius_staging)
### Schema : 14 tables
countries, regions, routes, stages, localities, route_localities, establishments, establishment_photos, establishment_content, establishment_prices, establishment_sources, pro_sites, scrape_jobs, quality_checks

### Donnees actuelles
| Table | Rows | Notes |
|-------|------|-------|
| countries | 38 | Toute l'Europe, colonne languages JSON, priorites 1-38 |
| routes | 305 | 17 pays, slug=code, total_km, gpx_file URL .rar |
| regions | 0 | A peupler |
| localities | 2356 | Seeders VPS1 (778) + GPX/KML import (1578) |
| stages | 1795 | 305/305 routes couvertes, km + d+/d- + heures |
| route_localities | 2830 | Liens route-localite avec order_on_route |
| establishments | 0 | A scraper (objectif 20-25K) |
| Autres tables | 0 | Se rempliront au fil du pipeline |

### Modifications recentes
- establishment_content.lang = VARCHAR(5) (etait ENUM, supporte toutes langues ISO 639-1)
- countries.languages = JSON (langues officielles par pays, ex: CH=["de","fr","it","rm"])

### Users BDD
- cblrs_user : full privileges (voir CREDENTIALS/)
- staging_user : SELECT/INSERT/UPDATE (voir CREDENTIALS/)

### Sources de donnees
- caminosantiago.org = SOURCE MASTER (305 routes KML/KMZ/GPX, 1599 localites geocodees)
- VPS1 seeders = SOURCE ETAPES (43 chemins, 778 localites, 742 etapes detaillees avec GPS)
- nco.ign.es = SOURCE VALIDATION (Espagne uniquement, IGN officiel)

### Scripts importants sur VPS2
- /tmp/parse_seeders.py : Parse seeders PHP VPS1 → localites + stages
- /data/openclaw/workspace/skills/00-import-gpx/import_gpx.py : Download RAR, extract KML, geocode, insert
- /data/openclaw/workspace/skills/00-import-gpx/complete_stages.py : Cree stages depuis KML/KMZ/GPX

### Backup
- /data/backups/staging_2026-02-18.sql (83 Ko) — schema + pays + routes seulement
- /data/backups/staging_2026-02-18_2005.sql (740 Ko) — complet avec 2356 localites + 1795 etapes

## Skills OpenClaw (8 custom)
- [x] 8 skills dans /data/openclaw/workspace/skills/ (16 fichiers)
- Statut : SQUELETTES (fonctions vides avec TODO)
- 01-scrape-google : Google Places API, 17 categories, rayon 1km
- 02-scrape-facebook : Pages FB, photos, avis
- 03-scrape-instagram : Photos geolocalisees, hashtags camino
- 04-scrape-tourisme : Offices tourisme, Wikipedia, patrimoine
- 05-scrape-forums : Gronze, CaminoWays, Reddit, avis pelerins
- 06-enrichir-contenu : Kimi K2.5, langues DYNAMIQUES (locales+fr+en), 3 profils
- 07-generer-site : Template caballarius-v1, deploy /data/sites/
- 08-sync-vps1 : API push vers caballarius.eu, HTTPS, retries
- Doc : BRAIN/CLAW/skills.md

## N8N Workflows (4 superviseur)
- [x] 4 fichiers JSON dans /data/n8n/workflows/
- 01-planificateur : Cron 4h, 20 localites pending → OpenClaw
- 02-controle-qualite : Cron 2h, anomalies + Kimi K2.5 → quality_checks
- 03-rapport-quotidien : Cron 20h, stats → Kimi rapport → Telegram
- 04-watchdog : Cron 30min, check infra → auto-fix → alertes Telegram
- Statut : SQUELETTES JSON (pas encore importes dans n8n)
- Doc : BRAIN/N8N/workflows.md

## Certificats SSL
- cblrs.net + www.cblrs.net : valide jusqu'au 2026-05-19 (auto-renouvellement)
- n8n.cblrs.net : valide jusqu'au 2026-05-19 (auto-renouvellement)
- *.cblrs.net (wildcard) : PAS ENCORE — sites pros servis en HTTP

## ============================================================
## CE QUI RESTE A FAIRE (prochaines sessions)
## ============================================================

### PRIORITE 1 — Localites + Etapes : FAIT (sessions 7+8)
- [x] 43 seeders PHP du VPS1 parses (parse_seeders.py) → 778 loc, 742 stages
- [x] GPX/KML import des 305 routes (import_gpx.py) → 1599 geocodees via Nominatim
- [x] complete_stages.py pour les 265 routes manquantes → 1053 stages supplementaires
- [x] Support KMZ + GPX ajoute pour les 3 derniers fichiers atypiques
- [x] 305/305 routes ont des etapes (0 manquante)
- [x] 2356 localites, 1795 etapes, 2830 route_localities
- [ ] Cross-reference avec nco.ign.es pour les etapes espagnoles
- [ ] Peupler la table regions

### PRIORITE 2 — Implementer le code des 8 skills
- [ ] 01-scrape-google : Google Places API (NEED API KEY)
- [ ] 02-scrape-facebook : Graph API ou browser scraping
- [ ] 03-scrape-instagram : Browser tool, geoloc + hashtags
- [ ] 04-scrape-tourisme : Fetch + parse offices tourisme
- [ ] 05-scrape-forums : Gronze, Reddit, rate limit 1/3s
- [ ] 06-enrichir-contenu : Kimi K2.5, langues dynamiques (structure prete)
- [ ] 07-generer-site : Template HTML caballarius-v1
- [ ] 08-sync-vps1 : API push avec retries

### PRIORITE 3 — Infrastructure
- [ ] Importer les 4 workflows dans n8n + configurer credentials
- [ ] Creer API key Google AI Studio (Gemini 2.5 Flash fallback)
- [ ] Creer API key Google Places
- [ ] Configurer Telegram bot (rapports + alertes)
- [ ] Wildcard SSL via acme.sh + API Infomaniak
- [ ] Template HTML Caballarius v1 dans /data/templates/
- [ ] Ajouter jails Fail2Ban Nginx
