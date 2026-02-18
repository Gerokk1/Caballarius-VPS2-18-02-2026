# OpenClaw Setup — VPS2 Bunker Mode

## Statut : OPERATIONNEL

## Image Docker
- Image : alpine/openclaw:latest
- Version : OpenClaw 2026.2.17
- Port gateway : 18789 (PAS 3000)
- User dans container : node (uid 1000)
- Node.js : v22.22.0

## Architecture isolation
```
VPS2
  |
  +-- Docker network: openclaw-isolated (bridge, separe)
  |     |
  |     +-- Container: openclaw-bunker
  |           Port: 127.0.0.1:18789 (localhost UNIQUEMENT)
  |           User: node (1000)
  |           Bind: lan (0.0.0.0 dans container, 127.0.0.1 sur host)
  |           Auth: token requis (cblrs-openclaw-bunker-2026)
  |           Volumes: /data/openclaw/config -> /home/node/.openclaw
  |                    /data/openclaw/workspace -> /home/node/workspace
  |
  +-- Docker network: default (n8n, etc.)
        |
        +-- Container: n8n (SEPARE, pas de lien avec openclaw)
```

## Fichiers sur le serveur
- Docker Compose : /data/openclaw/docker-compose.yml
- Config : /data/openclaw/config/openclaw.json
- Workspace : /data/openclaw/workspace/
- Logs gateway : /tmp/openclaw/openclaw-YYYY-MM-DD.log (dans container)

## Utilisateur Linux
- User : openclaw (uid 1001, sans sudo, sans privileges)
- Home : /home/openclaw
- Workspace : /data/openclaw

## Cerveaux LLM
- Principal : Kimi K2.5 via OpenRouter (openrouter/moonshotai/kimi-k2.5)
- Fallback : Gemini 2.5 Flash via Google AI Studio
- API keys : PLACEHOLDERS — a remplacer par les vraies cles

## Config JSON valide (cles reconnues)
```json
{
  "models": { "providers": { "openrouter": {...}, "google": {...} } },
  "gateway": { "bind": "lan", "auth": { "token": "..." } },
  "agents": { "defaults": { "model": { "primary": "..." }, "workspace": "...", ... } }
}
```
ATTENTION : Les cles suivantes ne sont PAS reconnues par OpenClaw :
- security (a la racine)
- skills.allowedSources, skills.blockedSources, skills.autoInstall
- agents.defaults.model.secondary
- models.providers.google.api (si "google-genai")

## Regles de securite (audit 2026-02-18 — 25/25 OK)
- Port 18789 PAS dans UFW (pas expose a internet)
- PAS de reverse proxy Nginx vers openclaw
- Auth token requis pour acceder au gateway (401 sans token)
- Reseau Docker isole (openclaw-isolated, zero lien avec n8n)
- PAS d'acces aux credentials MariaDB/Nginx
- MariaDB inaccessible depuis container (ecoute 127.0.0.1 seulement)
- cap_drop: ALL (toutes capabilities Linux retirees)
- security_opt: no-new-privileges:true
- Privileged: false
- Docker socket PAS monte
- Volumes limites a config + workspace (aucun acces /data/sites, /data/n8n, /etc/nginx)
- Skills ClawHub : zero installe, dossier inexistant
- Fichiers config : chmod 600 (dont .bak)
- Anti-prompt injection : HEARTBEAT.md injecte dans system prompt (identite Caballarius, interdit injection)
- tools.exec : mode allowlist — agent doit demander approbation pour toute commande

## Fichiers workspace (/data/openclaw/workspace/)
- HEARTBEAT.md : regles anti-prompt injection (injecte automatiquement dans chaque session)
- AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, BOOTSTRAP.md : fichiers par defaut OpenClaw

## Commandes utiles
```bash
# Status
sudo docker ps --filter name=openclaw-bunker
# Logs
sudo docker logs openclaw-bunker --tail 50
# Restart
cd /data/openclaw && sudo docker compose restart
# Full restart (down + up)
cd /data/openclaw && sudo docker compose down && sudo docker compose up -d
# Test local
curl -s -H 'Authorization: Bearer cblrs-openclaw-bunker-2026' http://127.0.0.1:18789/__openclaw__/canvas/
```

## Bugs rencontres
- BUG-005 : JSON corrompue par heredoc SSH (fix: base64)
- BUG-006 : Cles config non reconnues (fix: retirer security, skills.*, model.secondary, google.api)
- BUG-007 : Gateway loopback dans container (fix: gateway.bind=lan + auth.token)
