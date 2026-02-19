# Architecture d'integration OpenClaw / n8n — Caballarius VPS2

**Derniere mise a jour : 2026-02-19**

---

## Vue d'ensemble

Le systeme Caballarius repose sur deux moteurs complementaires qui operent sur VPS2 (83.228.211.132) :

- **OpenClaw** : systeme multi-agents executant les taches de scraping, enrichissement et generation de contenu
- **n8n** : automate de workflows supervisant, controlant et rapportant l'activite des agents

Les deux systemes partagent une base de donnees MariaDB (`caballarius_staging`) comme point d'integration central. Le modele IA **Kimi K2.5** (`moonshotai/kimi-k2.5`) via OpenRouter sert de cerveau analytique pour les deux systemes.

---

## Infrastructure technique

### OpenClaw (Bunker Mode)
- **Container** : `openclaw-bunker` (alpine/openclaw:latest v2026.2.17)
- **Gateway** : `ws://127.0.0.1:18789` (WebSocket, localhost uniquement, non expose)
- **Reseau Docker** : `openclaw-isolated` (isole du reseau n8n)
- **Authentification** : Token requis (401 sans token)
- **Config** : `/data/openclaw/config/openclaw.json`
- **Workspace** : `/data/openclaw/workspace/`
- **Securite** : cap_drop ALL, no-new-privileges, chmod 600, audit 25/25

### n8n (Docker)
- **URL** : `https://n8n.cblrs.net` (SSL, reverse proxy Nginx)
- **Version** : v2.8.3
- **Donnees** : `/data/n8n/`
- **Acces BDD** : via `host.docker.internal` (extra_hosts Docker)
- **Variables** : `OPENROUTER_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` dans `/data/n8n/.env`

### MariaDB (caballarius_staging)
- **Acces** : `sudo mariadb` (auth socket), pas de mot de passe root
- **Users** : `cblrs_user` (full), `staging_user` (SELECT/INSERT/UPDATE depuis 172.% et localhost)
- **Tables cles** : 15 tables (countries, routes, stages, localities, establishments, locality_content, scrape_jobs, quality_checks, pro_sites, etc.)

### Kimi K2.5 (cerveau IA)
- **Modele** : `moonshotai/kimi-k2.5` via OpenRouter
- **Endpoint** : `https://openrouter.ai/api/v1/chat/completions`
- **Usage** : generation de contenu (skill 06), analyse de donnees (workflows 01, 02, 03), rapports
- **Format** : `response_format=json_object` pour les sorties structurees

### Telegram
- **Bot** : `@caballarius_vps2_bot` ("Caballarius VPS2")
- **Chat ID** : `8585838701` (Gero Nimo)
- **Direction** : unidirectionnelle (VPS2 vers utilisateur)
- **Methode** : appels `fetch()` vers `api.telegram.org` dans les Code nodes n8n

---

## Les quatre agents

Le systeme est organise autour de quatre agents logiques. Chaque agent combine un ou plusieurs skills OpenClaw avec un ou plusieurs workflows n8n.

### 1. Le Scribe (Le Planificateur)

**Role** : Planifier et coordonner le travail des autres agents.

| Composant | Detail |
|-----------|--------|
| Workflow n8n | `01-planificateur.json` |
| Declencheur | Cron 02h00 |
| Skill OpenClaw | Aucun directement (orchestre les autres) |

**Fonctionnement** :
1. Le workflow n8n interroge la BDD pour obtenir les statistiques globales (localites pending, taux de scraping, erreurs)
2. Kimi K2.5 analyse ces metriques et decide des priorites : quels skills lancer, quelles tailles de batch, quels pays traiter en premier
3. Le Scribe ajuste les parametres de batch et l'ordonnancement des taches

**Tables BDD utilisees** : `localities` (scrape_status), `countries` (priority), `scrape_jobs` (status, timestamps)

---

### 2. Le Batisseur (L'Enrichisseur et Generateur)

**Role** : Enrichir le contenu des localites et generer les sites web des professionnels.

| Composant | Detail |
|-----------|--------|
| Skills OpenClaw | `06-enrichir-contenu`, `07-generer-site` |
| Workflows n8n | Supervision via 02-Controle Qualite |
| Statut | Skill 06 ACTIF (nohup), Skill 07 SQUELETTE |

**Skill 06 — Enrichir contenu** :
- Genere des descriptions multilingues pour chaque localite via Kimi K2.5
- Langues dynamiques basees sur `countries.languages` (JSON) + fr + en toujours inclus
- Produit par langue : description (200-400 mots), description_short, highlights, SEO title/description, 3 profils (chevalier/moine/pelerin)
- Ecriture dans `locality_content` (ON DUPLICATE UPDATE)
- Tourne en `nohup` sur le host VPS2, batch de 50

**Skill 07 — Generer site** (a implementer) :
- Template `caballarius-v1` (fond nuit etoilee, accent or, Cinzel + EB Garamond)
- Deploiement dans `/data/sites/{subdomain}/public/index.html`
- Vhost wildcard Nginx : `{subdomain}.cblrs.net`
- Ecriture dans `pro_sites` (subdomain, html_path, deployed_at, is_live)

**Supervision n8n** :
- Le workflow 02 (Controle Qualite) verifie la qualite du contenu genere par Le Batisseur
- Detection de doublons, hallucinations, incoherences de prix
- Resultats dans `quality_checks`

**Tables BDD utilisees** : `localities`, `locality_content`, `establishments`, `establishment_content`, `establishment_prices`, `pro_sites`, `countries`

---

### 3. Le Heraut (Le Rapporteur)

**Role** : Communiquer l'etat du projet et les resultats via des rapports structures.

| Composant | Detail |
|-----------|--------|
| Workflow n8n | `03-rapport-quotidien.json` |
| Declencheur | Cron 07h00 |
| Canal | Telegram (`@caballarius_vps2_bot`) |

**Fonctionnement** :
1. Le workflow collecte 12 metriques depuis la BDD (nouveaux du jour, total, scraped, enriched, sites generes, synced, localites done/pending, erreurs, QC, issues critiques ouvertes, sites live)
2. Recupere le top 5 des localites par nombre d'etablissements
3. Kimi K2.5 redige un rapport concis en francais avec KPIs, pourcentage de progression, comptages, et recommandations
4. Envoi automatique via Telegram

**Tables BDD utilisees** : `establishments`, `localities`, `scrape_jobs`, `quality_checks`, `pro_sites`

---

### 4. Le Veilleur (Le Gardien)

**Role** : Surveiller l'infrastructure, detecter les anomalies, et reparer automatiquement les problemes.

| Composant | Detail |
|-----------|--------|
| Workflows n8n | `04-watchdog.json`, `02-controle-qualite.json` |
| Declencheurs | Toutes les 15min (watchdog), Cron 06h00 (QC) |
| Alertes | Telegram (uniquement si WARNING ou CRITICAL) |

**Workflow 04 — Watchdog** (toutes les 15 minutes) :
1. Verifie que le container OpenClaw est UP (`docker ps`)
2. Detecte les jobs bloques (status `running` depuis > 1h)
3. Surveille l'espace disque `/data` (alerte > 80%, critique > 95%)
4. Teste la disponibilite d'OpenRouter (GET `/api/v1/models`, timeout 5s)
5. Agrege les alertes (CRITICAL/WARNING)
6. Corrige automatiquement les jobs bloques (UPDATE -> status `error`)
7. Envoie une alerte Telegram si des problemes sont detectes

**Workflow 02 — Controle Qualite** (Cron 06h00) :
1. Interroge les etablissements crees dans les dernieres heures
2. Calcule la distance haversine par rapport a la localite attendue
3. Detecte : mauvaise localisation (> 1km), donnees manquantes, prix incoherents
4. Kimi K2.5 analyse les cas suspects et propose des corrections
5. Insere les resultats dans `quality_checks` (check_type, severity, description)
6. Notification Telegram avec le score qualite et les issues

**Tables BDD utilisees** : `scrape_jobs`, `establishments`, `quality_checks`

---

## Schema d'integration

```
+------------------------------------------------------------------+
|                          VPS2 (cblrs.net)                        |
|                                                                  |
|  +---------------------------+  +-----------------------------+  |
|  |      OpenClaw (Docker)    |  |        n8n (Docker)         |  |
|  |   ws://127.0.0.1:18789   |  |   https://n8n.cblrs.net     |  |
|  |   openclaw-isolated net   |  |                             |  |
|  |                           |  |   01 Planificateur (02h)    |  |
|  |   Config: openclaw.json   |  |   02 Controle QC (06h)     |  |
|  |   Modele: Kimi K2.5       |  |   03 Rapport (07h)         |  |
|  +---------------------------+  |   04 Watchdog (15min)       |  |
|                                 +-----------------------------+  |
|                                        |                         |
|  Skills (nohup sur host VPS2)          | host.docker.internal    |
|  +--------------------+               |                         |
|  | 01-scrape-sonar    |-----+         |                         |
|  | 06-enrichir-contenu|-----+         |                         |
|  | 07-generer-site    |-----+         |                         |
|  | (02,03,04,05,08)   |-----+         |                         |
|  +--------------------+     |         |                         |
|                             v         v                         |
|                  +------------------------+                      |
|                  |  MariaDB               |                      |
|                  |  caballarius_staging    |                      |
|                  |  15 tables             |                      |
|                  +------------------------+                      |
|                                                                  |
|                  +------------------------+                      |
|                  |  OpenRouter (externe)  |                      |
|                  |  Kimi K2.5             |<-- fetch() n8n       |
|                  |  moonshotai/kimi-k2.5  |<-- skills OpenClaw   |
|                  +------------------------+                      |
|                                                                  |
|                  +------------------------+                      |
|                  |  Telegram (externe)    |                      |
|                  |  @caballarius_vps2_bot |<-- fetch() n8n       |
|                  |  chat_id: 8585838701  |    (workflows 02-04)  |
|                  +------------------------+                      |
+------------------------------------------------------------------+
```

---

## Flux de donnees

### Pipeline principal (scraping -> enrichissement -> generation)

```
localities (pending)
    |
    v
Skill 01 : scrape-sonar (Kimi K2.5)
    |  -> establishments, establishment_sources
    |  -> scrape_jobs (status tracking)
    v
Skill 06 : enrichir-contenu (Kimi K2.5)
    |  -> locality_content (multilingue)
    |  -> establishment_content, establishment_prices
    v
Skill 07 : generer-site (a venir)
    |  -> /data/sites/{subdomain}/
    |  -> pro_sites (BDD)
    v
Skill 08 : sync-vps1 (a venir)
    |  -> POST HTTPS vers caballarius.eu
    v
Pipeline termine
```

### Pipeline de supervision (n8n)

```
02h00 : Le Scribe analyse BDD -> decide priorites batch
06h00 : Le Veilleur (QC) verifie qualite -> quality_checks + Telegram
07h00 : Le Heraut genere rapport KPI -> Telegram
15min  : Le Veilleur (Watchdog) surveille infra -> Telegram si alerte
```

---

## Table de correspondance agents / composants

| Agent | Role | Skills OpenClaw | Workflows n8n | Telegram |
|-------|------|----------------|---------------|----------|
| Le Scribe | Planification | (orchestre) | 01-Planificateur | Non |
| Le Batisseur | Contenu + Sites | 06, 07 | (supervise par 02) | Non |
| Le Heraut | Rapports | (aucun) | 03-Rapport Quotidien | Oui |
| Le Veilleur | Surveillance | (aucun) | 04-Watchdog, 02-QC | Si alerte |

---

## Tables BDD partagees (points d'integration)

| Table | Ecrit par | Lu par | Role |
|-------|-----------|--------|------|
| `scrape_jobs` | Skills 01-06 | n8n 01, 04 | Suivi central des taches (status, errors, timestamps) |
| `localities` | Import GPX/seeders | Skills, n8n 01 | Source des localites a traiter (scrape_status) |
| `establishments` | Skill 01 | Skills 06-07, n8n 02-03 | Etablissements scrapes |
| `locality_content` | Skill 06 | Skill 07, n8n 02-03 | Contenu multilingue des localites |
| `quality_checks` | n8n 02 | n8n 03 | Resultats des controles qualite |
| `pro_sites` | Skill 07 | n8n 03, 04 | Sites generes et deployes |
| `countries` | Import initial | Skill 06, n8n 01 | Langues et priorites par pays |

---

## Securite de l'integration

- OpenClaw gateway ecoute **uniquement sur localhost** (127.0.0.1:18789), non expose sur l'internet
- Les reseaux Docker sont **isoles** : `openclaw-isolated` et le reseau n8n sont separes
- MariaDB `staging_user` a des privileges **limites** (SELECT/INSERT/UPDATE, pas de DROP/DELETE)
- Les credentials ne sont **jamais** dans le code : `.env` sur VPS2, `BRAIN/CREDENTIALS/` en local (gitignored)
- Les tokens OpenRouter et Telegram sont charges via variables d'environnement
- UFW, Fail2Ban et SSH durci sont actifs en permanence

---

## Architecture future (Phase 2+)

### Court terme
- **Le Veilleur** pourra redemarrer les skills crashes via SSH exec depuis n8n
- **Le Scribe** orchestrera les tailles de batch dynamiquement selon l'analyse de Kimi K2.5
- **Le Batisseur** (skill 07) generera plus de 15 000 sites web professionnels
- **Le Heraut** enverra des rapports hebdomadaires en plus du quotidien

### Moyen terme
- **Sonar Pro** (Perplexity) en deuxieme passe de verification sur les donnees scrapees
- **Google Places API** pour validation croisee des etablissements
- **Wildcard SSL** (acme.sh + API Infomaniak) pour servir les sites pros en HTTPS
- **Skills 02-05** : enrichissement via Facebook, Instagram, offices de tourisme, forums pelerins

### Long terme
- **Gateway WebSocket OpenClaw** utilisee pour la communication temps reel entre agents (actuellement localhost uniquement)
- **Skill 08** : synchronisation bidirectionnelle avec VPS1 (caballarius.eu)
- **Gemini 2.5 Flash** comme modele de fallback (API key Google AI Studio a configurer)
- Passage progressif d'un systeme batch (cron + nohup) vers un systeme evenementiel (WebSocket + triggers BDD)

---

## Notes techniques

- Les skills OpenClaw tournent en tant que processus `nohup node` sur le host VPS2, pas dans Docker
- Les workflows n8n utilisent des **Code nodes** avec `fetch()` pour appeler OpenRouter et Telegram (pas de credentials n8n natifs pour ces services)
- Les credentials MySQL dans les workflows ont `id="create-in-ui"` : il faut creer le credential manuellement dans l'interface n8n puis l'assigner
- Le WebSocket OpenClaw est une gateway, pas une API REST : utiliser `openclaw agent --local` pour interagir en CLI
- MariaDB utilise l'authentification par socket : `sudo mariadb` sans mot de passe depuis le host
- Les JSON envoyes via SSH heredoc perdent leurs guillemets : toujours encoder en base64
