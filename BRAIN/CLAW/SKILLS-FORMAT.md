# Format Skills OpenClaw — Caballarius

**Date : 2026-02-19**

---

## Structure d'un skill

Chaque skill est un dossier dans `/data/openclaw/workspace/skills/` :

```
skills/
  01-scrape-sonar/
    SKILL.md          # Documentation + frontmatter YAML (OBLIGATOIRE)
    index.js          # Point d'entree Node.js
    package.json      # Dependances (optionnel si deps dans workspace root)
  06-enrichir-contenu/
    SKILL.md
    index.js
```

## SKILL.md — Format requis

Le fichier SKILL.md sert deux fonctions :
1. **Frontmatter YAML** : metadata machine-lisible pour l'auto-decouverte par OpenClaw
2. **Corps markdown** : documentation pour les humains et pour l'agent LLM

### Frontmatter YAML

```yaml
---
name: 01-scrape-sonar
description: >
  Scrape establishments pour localites du Camino via Kimi K2.5 (2 passes par localite).
  Phase 1 = Kimi K2.5 gratuit. Phase 2 = Sonar Pro verification.
tools:
  - exec
trigger: cron
schedule: "0 3 * * *"
agent: scribe
db_user: scribe_user
tables_read:
  - localities
  - routes
  - route_localities
  - countries
tables_write:
  - establishments
  - establishment_sources
  - scrape_jobs
env:
  - DB_PASS
  - OPENROUTER_API_KEY
  - DB_HOST
---
```

### Champs frontmatter

| Champ | Requis | Description |
|-------|--------|-------------|
| `name` | OUI | Identifiant unique du skill (= nom du dossier) |
| `description` | OUI | Description courte pour l'agent et les logs |
| `tools` | OUI | Tools OpenClaw requis (`exec`, `web`, `filesystem`) |
| `trigger` | NON | Mode de declenchement (`cron`, `manual`, `webhook`) |
| `schedule` | NON | Expression cron si trigger=cron |
| `agent` | OUI | Agent responsable (`scribe`, `batisseur`, `heraut`, `veilleur`) |
| `db_user` | OUI | User MariaDB utilise (moindre privilege) |
| `tables_read` | OUI | Tables lues par le skill |
| `tables_write` | OUI | Tables ecrites par le skill |
| `env` | OUI | Variables d'environnement requises |

### Corps markdown

Apres le frontmatter, le markdown libre documente :
- Architecture du skill (pipeline, passes, dedup)
- Usage CLI (`node index.js --batch 20`)
- Rate limiting et retries
- Pre-requis (npm packages, migrations SQL)
- Phase actuelle et evolution prevue

---

## Enregistrement aupres du gateway

### Au demarrage
1. OpenClaw scanne `workspace/skills/*/SKILL.md`
2. Parse le frontmatter YAML de chaque fichier
3. Les skills eligibles (tools disponibles + config valide) sont injectes dans le system prompt de l'agent
4. L'agent peut alors decider d'executer un skill quand il recoit un message pertinent

### Commandes CLI
```bash
# Lister les skills decouverts
docker exec openclaw-bunker openclaw skills list

# Details d'un skill
docker exec openclaw-bunker openclaw skills info 01-scrape-sonar

# Lister les skills eligibles (tools + config OK)
docker exec openclaw-bunker openclaw skills list --eligible --verbose
```

---

## Declenchement des skills

### 1. Via cron OpenClaw (automatique)

Fichier : `/data/openclaw/config/cron/jobs.json`

```json
{
  "jobId": "scrape-sonar",
  "name": "Skill 01 — Scrape Sonar",
  "enabled": true,
  "schedule": {
    "kind": "cron",
    "cron": "0 3 * * *",
    "tz": "Europe/Paris"
  },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Execute skill 01-scrape-sonar: cd /home/node/workspace/skills/01-scrape-sonar && DB_HOST=host.docker.internal DB_USER=scribe_user DB_PASS=xxx OPENROUTER_API_KEY=xxx node index.js --batch 20",
    "model": "openrouter/moonshotai/kimi-k2.5",
    "thinking": "low",
    "timeoutSeconds": 7200
  },
  "wakeMode": "now",
  "deleteAfterRun": false
}
```

Champs cron job :
| Champ | Description |
|-------|-------------|
| `jobId` | Identifiant unique (pour `cron run`, `cron remove`) |
| `schedule.kind` | `cron` (expression), `every` (intervalle ms), `at` (date fixe) |
| `sessionTarget` | `isolated` (session fresh) ou `main` (session principale) |
| `payload.kind` | `agentTurn` (session isolee) ou `systemEvent` (main) |
| `timeoutSeconds` | Duree max en secondes (7200 = 2h pour les gros batchs) |

### 2. Via REST API /hooks/agent (depuis n8n ou externe)

```bash
curl -X POST http://127.0.0.1:18789/hooks/agent \
  -H "Authorization: Bearer $HOOKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Execute skill 01-scrape-sonar with --batch 20",
    "name": "n8n-veilleur",
    "wakeMode": "now"
  }'
```

Reponse : `202 Accepted` (asynchrone)

### 3. Via CLI (depuis le host ou via SSH depuis n8n)

```bash
# Declencher un cron job manuellement
docker exec openclaw-bunker openclaw cron run scrape-sonar

# Envoyer un message direct a l'agent
docker exec openclaw-bunker openclaw agent --local \
  --message "Run skill 01 with batch 5" \
  --timeout 300
```

### 4. Via n8n SSH node

n8n utilise le SSH node pour executer des commandes sur le host :
```
Host: host.docker.internal
User: ubuntu
Command: docker exec openclaw-bunker openclaw cron run scrape-sonar
```

---

## Gestion des dependances

### Workspace-level (partage)
```bash
# Depuis le host
cd /data/openclaw/workspace && npm install mysql2

# Depuis le container
docker exec openclaw-bunker sh -c "cd /home/node/workspace && npm install mysql2"
```

### Skill-level (isole)
```bash
# Si un skill a son propre package.json
cd /data/openclaw/workspace/skills/07-generer-site && npm install
```

### Pre-requis pour les skills actuels
- `mysql2` : requis par 01, 06, et tous les skills qui accedent a la BDD
- `node-fetch` : pas necessaire (Node.js 20 a `fetch` natif)

---

## Convention de nommage Caballarius

```
XX-verb-noun/
  SKILL.md
  index.js
```

- `XX` : numero d'ordre (00-99)
- `verb-noun` : action principale en anglais
- Exemples : `01-scrape-sonar`, `06-enrichir-contenu`, `07-generer-site`

---

## Securite (voir SECURITY.md)

- Chaque skill declare son `agent` et son `db_user` dans le frontmatter
- Le skill recoit SEULEMENT les env vars declares dans `env`
- Le skill ne peut acceder qu'aux tables declarees dans `tables_read` / `tables_write`
- Enforcement via GRANT SQL (pas applicatif — le skill ne peut pas contourner)
