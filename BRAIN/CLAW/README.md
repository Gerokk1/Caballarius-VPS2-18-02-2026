# CLAW — OpenClaw sur VPS2

## Statut : OPERATIONNEL (2026-02-18)

## Role
Agent IA autonome pour automatiser le scraping et la generation des 15 000 sites pros Caballarius.

## Mode Bunker
OpenClaw a des vulnerabilites critiques connues (512 vulns, 341 skills malveillants, CVE-2026-25253).
Installation en ISOLATION TOTALE :
- Docker container isole sur reseau separe (openclaw-isolated)
- Gateway 127.0.0.1 UNIQUEMENT — JAMAIS expose a internet
- Auth token requis (401 sans token)
- ZERO skills depuis ClawHub — custom skills uniquement
- Utilisateur Linux dedie sans sudo
- Pas d'acces aux credentials de production (MariaDB, Nginx, etc.)

## Version
- OpenClaw 2026.2.17
- Image : alpine/openclaw:latest
- Container : openclaw-bunker

## Cerveaux LLM (gratuits, cloud)
- Principal : Kimi K2.5 via OpenRouter (openrouter/moonshotai/kimi-k2.5) — gratuit
- Fallback : Google Gemini 2.5 Flash — gratuit, 1500 req/jour
- API keys : A CONFIGURER (placeholders actuellement)

## Fichiers
- setup.md : details techniques complets (architecture, config, commandes)
- BRAIN/CREDENTIALS/ : tokens et API keys
- BRAIN/BUGS/ : BUG-005/006/007 lies a l'installation

## References securite
- Kaspersky audit : https://www.kaspersky.com/blog/openclaw-vulnerabilities-exposed/55263/
- ClawHub malveillants : https://thehackernews.com/2026/02/researchers-find-341-malicious-clawhub.html
- CVE-2026-25253 (CVSS 8.8) : compromise totale du gateway
- Barrack.ai guide securite : https://blog.barrack.ai/openclaw-security-vulnerabilities-2026/
