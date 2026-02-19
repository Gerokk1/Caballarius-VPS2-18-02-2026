# ETAT ACTUEL DU PROJET — VPS2

**Derniere mise a jour : 2026-02-19 07:30**

## Resume
VPS2 (cblrs.net) PLEINEMENT OPERATIONNEL. HTTPS actif. OpenClaw bunker mode + securite audit 25/25. BDD staging 14 tables, 38 pays, 305 routes, 2356 localites, 1795 etapes, langues dynamiques. TOUTES les 305 routes ont des etapes (0 manquante). 2 skills actifs (01 + 06) tournent avec Kimi K2.5 via OpenRouter. 4 workflows n8n ACTIFS avec Kimi K2.5 + Telegram. Bot Telegram connecte.

## Ce qui fonctionne
- [x] https://cblrs.net → 200 (SSL, redirect HTTP→HTTPS)
- [x] https://www.cblrs.net → 200 (SSL)
- [x] https://n8n.cblrs.net → 200 (SSL, reverse proxy vers Docker n8n)
- [x] http://test.cblrs.net → 200 (wildcard vhost fonctionne)
- [x] SSH ubuntu@83.228.211.132:22
- [x] Disque 250 Go monte (/data, 233 Go libres)
- [x] Securite : UFW, Fail2Ban, SSH durci, unattended upgrades
- [x] Stack : Nginx 1.24, PHP 8.3, MariaDB 10.11, Redis, Node.js 20, Docker 29, Certbot 2.9
- [x] n8n Docker UP (v2.8.3) — 4 workflows ACTIFS
- [x] Structure /data (sites/, templates/, n8n/, backups/)
- [x] Repo GitHub (Gerokk1/Caballarius-VPS2-18-02-2026)
- [x] Ports 80/443/5678 ouverts (Infomaniak Security Group)
- [x] DNS *.cblrs.net → 83.228.211.132
- [x] Telegram bot @caballarius_vps2_bot connecte (chat_id: 8585838701)

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
### Schema : 15 tables
countries, regions, routes, stages, localities, route_localities, establishments, establishment_photos, establishment_content, establishment_prices, establishment_sources, locality_content, pro_sites, scrape_jobs, quality_checks

### Donnees actuelles (2026-02-19 07h)
| Table | Rows | Notes |
|-------|------|-------|
| countries | 38 | Toute l'Europe, colonne languages JSON, priorites 1-38 |
| routes | 305 | 17 pays, slug=code, total_km, gpx_file URL .rar |
| regions | 0 | A peupler |
| localities | 2356 | Seeders VPS1 (778) + GPX/KML import (1578) |
| stages | 1795 | 305/305 routes couvertes, km + d+/d- + heures |
| route_localities | 2830 | Liens route-localite avec order_on_route |
| establishments | ~109 | Skill 01 en cours (Kimi K2.5, 8 localites scrapees) |
| locality_content | ~47 | Skill 06 en cours (Kimi K2.5, 17 localites enrichies) |
| Autres tables | 0 | Se rempliront au fil du pipeline |

### Modifications recentes
- establishment_content.lang = VARCHAR(5) (etait ENUM, supporte toutes langues ISO 639-1)
- countries.languages = JSON (langues officielles par pays, ex: CH=["de","fr","it","rm"])
- locality_content table CREEE (session 11) — descriptions multilingues par localite
- establishments.source ENUM etendu avec 'sonar_pro'
- UNIQUE KEY (name, locality_id) sur establishments

### Users BDD
- cblrs_user : full privileges (voir CREDENTIALS/)
- staging_user : SELECT/INSERT/UPDATE depuis 172.% (Docker n8n) + localhost

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
- [x] package.json workspace avec mysql2

### Statut skills
| Skill | Statut | Notes |
|-------|--------|-------|
| 01-scrape-sonar | ACTIF (nohup) | Adapte Kimi K2.5 via OpenRouter, 2 passes (hebergement+resto, services+patrimoine), 32 categories, batch 20 |
| 02-scrape-facebook | SQUELETTE | Pages FB, photos, avis |
| 03-scrape-instagram | SQUELETTE | Photos geolocalisees, hashtags camino |
| 04-scrape-tourisme | SQUELETTE | Offices tourisme, Wikipedia, patrimoine |
| 05-scrape-forums | SQUELETTE | Gronze, CaminoWays, Reddit |
| 06-enrichir-contenu | ACTIF (nohup) | Kimi K2.5, langues dynamiques (locales+fr+en), repairJSON(), batch 50, table locality_content |
| 07-generer-site | SQUELETTE | Template caballarius-v1, deploy /data/sites/ |
| 08-sync-vps1 | SQUELETTE | API push vers caballarius.eu |

- Phase 1 (maintenant) : Kimi K2.5 gratuit via OpenRouter
- Phase 2 (semaine prochaine) : Sonar Pro en 2eme passe verification

## N8N Workflows (4 superviseur)
- [x] 4 workflows IMPORTES ET ACTIFS dans n8n Docker
- [x] Kimi K2.5 comme cerveau IA (Code nodes avec fetch OpenRouter)
- [x] Telegram notifications (workflows 02, 03, 04)
- [x] MariaDB accessible depuis Docker (extra_hosts + staging_user 172.%)
- [x] OPENROUTER_API_KEY + TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID dans /data/n8n/.env

| Workflow | Cron | Kimi | Telegram | Notes |
|----------|------|------|----------|-------|
| 01 Planificateur | 02h00 | Oui | Non | Analyse BDD, decide priorites |
| 02 Controle Qualite | 06h00 | Oui | Oui | Doublons, hallucinations, qualite |
| 03 Rapport Quotidien | 07h00 | Oui | Oui | KPI, progres, recommandations |
| 04 Watchdog | 15min | Non | Si alerte | Stuck jobs, error rate, OpenRouter health |

**IMPORTANT** : Les MySQL credentials dans les workflows ont id="create-in-ui". Il faut creer le credential MariaDB manuellement dans n8n UI (https://n8n.cblrs.net) puis l'assigner aux workflows.

## Telegram Bot
- Bot : @caballarius_vps2_bot ("Caballarius VPS2")
- Chat ID : 8585838701 (Gero Nimo)
- Usage : notifications unidirectionnelles (rapports, alertes watchdog)
- Token dans /data/n8n/.env + BRAIN/CREDENTIALS

## Certificats SSL
- cblrs.net + www.cblrs.net : valide jusqu'au 2026-05-19 (auto-renouvellement)
- n8n.cblrs.net : valide jusqu'au 2026-05-19 (auto-renouvellement)
- *.cblrs.net (wildcard) : PAS ENCORE — sites pros servis en HTTP

## ============================================================
## CE QUI RESTE A FAIRE (prochaines sessions)
## ============================================================

### PRIORITE 1 — Skills en cours (surveiller)
- [x] Skill 01 (scrape establishments) tourne en nohup — surveiller progression
- [x] Skill 06 (enrichir localites) tourne en nohup — surveiller progression
- [ ] Verifier qualite des donnees apres 24h de scraping
- [ ] Semaine prochaine : Sonar Pro en 2eme passe

### PRIORITE 2 — n8n configuration manuelle
- [ ] Creer credential MySQL dans n8n UI (host=host.docker.internal, user=staging_user, pass=Stg!Cblrs2026_QC#Secure, db=caballarius_staging)
- [ ] Assigner le credential aux 4 workflows
- [ ] Tester manuellement chaque workflow depuis n8n UI

### PRIORITE 3 — Implementer les skills restants
- [ ] 02-scrape-facebook : Graph API ou browser scraping
- [ ] 03-scrape-instagram : Browser tool, geoloc + hashtags
- [ ] 04-scrape-tourisme : Fetch + parse offices tourisme
- [ ] 05-scrape-forums : Gronze, Reddit, rate limit 1/3s
- [ ] 07-generer-site : Template HTML caballarius-v1
- [ ] 08-sync-vps1 : API push avec retries

### PRIORITE 4 — Infrastructure
- [ ] Creer API key Google AI Studio (Gemini 2.5 Flash fallback)
- [ ] Creer API key Google Places
- [ ] Wildcard SSL via acme.sh + API Infomaniak
- [ ] Template HTML Caballarius v1 dans /data/templates/
- [ ] Ajouter jails Fail2Ban Nginx
- [ ] Peupler table regions
- [ ] Cross-reference nco.ign.es (etapes espagnoles)
