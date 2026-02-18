# N8N Workflows — Superviseur Caballarius

## Localisation
/data/n8n/workflows/ (4 fichiers JSON)

## Vue d'ensemble
N8N orchestre le pipeline de scraping en tant que superviseur. Les 4 workflows declenchent OpenClaw, controlent la qualite, generent des rapports, et surveillent l'infrastructure.

---

## 01-planificateur.json
**Nom** : Caballarius - Planificateur missions
**Declencheur** : Cron toutes les 4h (6h, 10h, 14h, 18h, 22h, 2h)
**Pipeline** :
1. Query Pending Localities — SELECT 20 localites pending (triees par priorite pays)
2. Send to OpenClaw — POST http://127.0.0.1:18789/api/agent (skill 01-scrape-google)
3. Log Job — INSERT scrape_jobs (google_places, locality, pending)

**SQL** : `SELECT l.id, l.name, l.lat, l.lng, c.name_fr AS country, c.priority FROM localities l JOIN regions r ON l.region_id = r.id JOIN countries c ON r.country_id = c.id WHERE l.scrape_status = 'pending' ORDER BY c.priority ASC, l.id ASC LIMIT 20`

---

## 02-controle-qualite.json
**Nom** : Caballarius - Controle qualite
**Declencheur** : Cron toutes les 2h
**Pipeline** :
1. Query Recent Establishments — etablissements crees dans les 2 dernieres heures (avec calcul distance haversine)
2. Check Duplicates — doublons nom+adresse dans les 24h
3. Filter Suspects — Code JS qui detecte :
   - distance_km > 1 (wrong_location, critical)
   - nom vide ou "Unknown" (missing_data, warning)
   - prix incoherent pour la categorie (incoherent_price, warning/info)
4. Ask Kimi K2.5 — Analyse IA des suspects via OpenRouter (moonshotai/kimi-k2.5)
5. Insert Quality Checks — INSERT quality_checks (check_type, establishment_id, severity, description)

---

## 03-rapport-quotidien.json
**Nom** : Caballarius - Rapport quotidien
**Declencheur** : Cron a 20h00
**Pipeline** :
1. Stats Today — 12 metriques (new_today, total, scraped, enriched, sites_generated, synced, localities done/pending, errors, QC, critical open, sites live)
2. Top Localities — Top 5 localites par nombre d'etablissements
3. Generate Report (Kimi) — Kimi K2.5 redige un rapport concis en francais avec emojis
4. Send Telegram — Envoi du rapport au chat Telegram configure

---

## 04-watchdog.json
**Nom** : Caballarius - Watchdog
**Declencheur** : Cron toutes les 30 minutes
**Checks paralleles** :
1. Check OpenClaw — `docker ps --filter name=openclaw-bunker` (UP/DOWN)
2. Check Stuck Jobs — Jobs en status 'running' depuis > 1h
3. Check Disk — Usage disque /data (alerte > 80%, critique > 95%)
4. Check OpenRouter — GET https://openrouter.ai/api/v1/models (timeout 5s)

**Actions** :
- Process Alerts — Code JS qui agrege les alertes (CRITICAL/WARNING)
- Fix Stuck Jobs — UPDATE automatique des jobs bloques -> status='error'
- Alert Telegram — Notification si alertes detectees

---

## Credentials requises (a configurer dans n8n)
- MySQL : connexion a caballarius_staging (staging_user / Stg!Cblrs2026_QC#Secure)
- OpenRouter API key : pour Kimi K2.5 (workflows 02, 03)
- Telegram Bot token + Chat ID : pour rapports et alertes (workflows 03, 04)
- OpenClaw auth token : cblrs-openclaw-bunker-2026 (workflow 01)

## Notes
- Les workflows sont des squelettes JSON. Ils doivent etre importes dans n8n via l'interface.
- Le workflow 01 utilise l'API agent HTTP d'OpenClaw (pas le WebSocket).
- Le workflow 04 execute des commandes shell dans le container n8n (docker ps, df).
