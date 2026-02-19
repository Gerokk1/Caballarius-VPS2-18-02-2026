# ETAT ACTUEL DU PROJET — VPS2

**Derniere mise a jour : 2026-02-19 15:00 (session 14)**

## Resume
VPS2 (cblrs.net) PLEINEMENT OPERATIONNEL. Skills 01 + 06 migres sous OpenClaw avec Gemini 2.5 Flash (gratuit). Secrets dans `.env` gitignored. 4 agents DB avec moindre privilege. OpenRouter bloque (compte, pas la cle). n8n 4 workflows actifs. Bot Telegram connecte. 1077 establishments, 233 locality_content. 2275 localites en cours de scraping + enrichissement.

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

## OpenClaw (Bunker Mode) — OPERATIONNEL
- [x] Container openclaw-bunker UP (alpine/openclaw:latest)
- [x] Gateway ws://0.0.0.0:18789 (localhost only)
- [x] Reseau Docker isole (openclaw-isolated)
- [x] Auth token requis (401 sans token)
- [x] Hooks REST API activee (`POST /hooks/agent`)
- [x] Cron jobs configures (exec direct, PAS agentTurn)
- [x] Anti-prompt injection (HEARTBEAT.md)
- [x] Exec security (tools.exec.security=allowlist)
- [x] cap_drop ALL, no-new-privileges, chmod 600
- [x] Secrets dans `/data/openclaw/.env` (gitignored, chmod 600)
- [x] `env_file` dans docker-compose (plus de secrets dans git)
- [x] extra_hosts: host.docker.internal (acces MariaDB)
- [x] mysql2 installe dans workspace
- [x] Skills 01 + 06 ACTIFS dans le container

### AI Provider
- **Actif : Google AI Studio (Gemini 2.5 Flash)** — gratuit, `AI_PROVIDER=google`
- Fallback : OpenRouter (Kimi K2.5) — BLOQUE ("User not found", 3 cles testees, probleme compte)
- Variable `AI_PROVIDER` dans docker-compose switch entre `google` et `openrouter`

### Cron Jobs (exec direct)
| Job | Schedule | Agent | Commande |
|-----|----------|-------|----------|
| scrape-sonar | 0 3 * * * (Paris) | Le Scribe | `node index.js --batch 20` |
| enrichir-contenu | 0 4 * * * (Paris) | Le Batisseur | `node index.js --batch 50` |

Format : `payload.kind: "exec"` — execution directe sans LLM intermediaire.

## BDD Staging (MariaDB caballarius_staging)
### Schema : 15 tables
countries, regions, routes, stages, localities, route_localities, establishments, establishment_photos, establishment_content, establishment_prices, establishment_sources, locality_content, pro_sites, scrape_jobs, quality_checks

### Donnees actuelles (2026-02-19 15h00)
| Table | Rows | Notes |
|-------|------|-------|
| countries | 38 | Toute l'Europe, colonne languages JSON, priorites 1-38 |
| routes | 305 | 17 pays, slug=code, total_km, gpx_file URL .rar |
| regions | 0 | A peupler |
| localities | 2356 | Seeders VPS1 (778) + GPX/KML import (1578) |
| stages | 1795 | 305/305 routes couvertes, km + d+/d- + heures |
| route_localities | 2830 | Liens route-localite avec order_on_route |
| establishments | 1077 | 81 localites scrapees, 15 categories representees |
| locality_content | 233 | 79 localites enrichies (es+fr+en), 9 Gemini + 224 Kimi |
| scrape_jobs | ~3500 | 81 sonar done, 76 enrichment done, reste = erreurs API key |

### Users BDD (moindre privilege)
| User | Agent | Privileges |
|------|-------|-----------|
| cblrs_user | Legacy | Full privileges |
| staging_user | n8n QC | SELECT/INSERT/UPDATE depuis 172.% + localhost |
| scribe_user | Le Scribe | SELECT/UPDATE localities, INSERT/UPDATE establishments + sources + scrape_jobs |
| batisseur_user | Le Batisseur | SELECT estab/loc/routes, CREATE + INSERT/UPDATE locality_content + scrape_jobs |
| heraut_user | Le Heraut | SELECT * (lecture seule) |
| veilleur_user | Le Veilleur | SELECT + INSERT scrape_jobs, quality_checks |

### Qualite donnees (audit 2026-02-19)
| Champ | Completude |
|-------|-----------|
| name | 100% |
| address | 100% |
| GPS (lat/lng) | 100% |
| phone | 56% |
| website | 21% |
| email | ~5% |

0 doublons, 0 GPS hors Europe. Categories : 171 albergue, 113 restaurant, 86 epicerie, 82 hotel, 68 musee, 68 bar...

### Sources de donnees
- caminosantiago.org = SOURCE MASTER (305 routes, 1599 localites geocodees)
- VPS1 seeders = SOURCE ETAPES (43 chemins, 778 localites, 742 etapes)
- nco.ign.es = SOURCE VALIDATION (Espagne, IGN officiel)

## Skills OpenClaw (9 custom, dont 2 actifs)
| Skill | Statut | Mode | AI Provider | Notes |
|-------|--------|------|-------------|-------|
| 00-import-gpx | TERMINE | Python host | — | 305 routes, 2356 localites, 1795 etapes |
| 01-scrape-sonar | **ACTIF** | **Container OpenClaw** | Gemini 2.5 Flash | 2 passes, 32 categories, batch 20 |
| 02-scrape-facebook | SQUELETTE | — | — | Pages FB, photos, avis |
| 03-scrape-instagram | SQUELETTE | — | — | Photos geolocalisees, hashtags camino |
| 04-scrape-tourisme | SQUELETTE | — | — | Offices tourisme, Wikipedia |
| 05-scrape-forums | SQUELETTE | — | — | Gronze, CaminoWays, Reddit |
| 06-enrichir-contenu | **ACTIF** | **Container OpenClaw** | Gemini 2.5 Flash | Langues dynamiques, repairJSON(), batch 50 |
| 07-generer-site | SQUELETTE | — | — | Template caballarius-v1 |
| 08-sync-vps1 | SQUELETTE | — | — | API push vers caballarius.eu |

Skills dual-provider : `AI_PROVIDER=google` (defaut) ou `AI_PROVIDER=openrouter` (fallback).
SKILL.md avec frontmatter YAML pour auto-decouverte.

## N8N Workflows (4 superviseur)
| Workflow | Cron | Kimi | Telegram | Notes |
|----------|------|------|----------|-------|
| 01 Planificateur | 02h00 | Oui | Non | Analyse BDD, decide priorites |
| 02 Controle Qualite | 06h00 | Oui | Oui | Doublons, hallucinations |
| 03 Rapport Quotidien | 07h00 | Oui | Oui | KPI, progres, recommandations |
| 04 Watchdog | 15min | Non | Si alerte | Stuck jobs, error rate, health check |

- [x] Watchdog execution #5 = SUCCESS (fix node refs + continueOnFail)
- [ ] **PAS ENCORE connecte a OpenClaw** (tache 5 pending)

## Telegram Bot
- Bot : @caballarius_vps2_bot
- Chat ID : 8585838701 (Gero Nimo)
- Usage : notifications unidirectionnelles (rapports, alertes watchdog)

## Certificats SSL
- cblrs.net + www.cblrs.net : valide jusqu'au 2026-05-19
- n8n.cblrs.net : valide jusqu'au 2026-05-19
- *.cblrs.net (wildcard) : PAS ENCORE

## Documentation BRAIN
- [x] BRAIN/CLAW/SECURITY.md — regles securite, 4 agents, kill switch
- [x] BRAIN/CLAW/SKILLS-FORMAT.md — format SKILL.md, frontmatter YAML, cron, hooks
- [x] BRAIN/CLAW/architecture-openclaw-n8n.md — architecture integration
- [x] BRAIN/CREDENTIALS/credentials.md — tous les acces (gitignored)

## ============================================================
## CE QUI RESTE A FAIRE
## ============================================================

### PRIORITE 1 — Connecter n8n a OpenClaw (tache 5)
- [ ] Creer credential SSH dans n8n (host.docker.internal, ubuntu, private key)
- [ ] Ajouter NODES_EXCLUDE=[] dans .env n8n (reactiver Execute Command)
- [ ] Modifier workflow 04 (Veilleur) : SSH nodes pour check/restart skills
- [ ] Tester restart automatique d'un skill crashe

### PRIORITE 2 — Resoudre OpenRouter
- [ ] Comprendre pourquoi le compte retourne "User not found" (3 cles testees)
- [ ] Contacter support OpenRouter si necessaire
- [ ] Reactiver comme fallback AI provider

### PRIORITE 3 — Surveiller skills en cours
- [ ] Skills 01 + 06 tournent avec Gemini 2.5 Flash
- [ ] 2275 localites a scraper + enrichir
- [ ] Verifier progression + qualite apres quelques heures

### PRIORITE 4 — Implementer skills restants
- [ ] 02-scrape-facebook : Graph API ou browser scraping
- [ ] 03-scrape-instagram : Browser tool, geoloc + hashtags
- [ ] 04-scrape-tourisme : Fetch + parse offices tourisme
- [ ] 05-scrape-forums : Gronze, Reddit, rate limit
- [ ] 07-generer-site : Template HTML caballarius-v1
- [ ] 08-sync-vps1 : API push avec retries

### PRIORITE 5 — Infrastructure
- [ ] Migrer vers .env file pour n8n aussi (meme pattern que OpenClaw)
- [ ] Wildcard SSL via acme.sh + API Infomaniak
- [ ] Template HTML Caballarius v1
- [ ] Peupler table regions
- [ ] Cross-reference nco.ign.es
