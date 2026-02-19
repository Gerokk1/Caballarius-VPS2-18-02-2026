# Skill 01 : Scrape Establishments (2 phases)

## Phase 1 — Kimi K2.5 (ACTUELLE, gratuite)
Scrape les etablissements via Kimi K2.5 (OpenRouter, gratuit).
Le modele genere les listes d'etablissements de memoire (pas de recherche web).
2 passes par localite pour couvrir hebergement+resto ET services+patrimoine.

## Phase 2 — Sonar Pro (semaine prochaine)
Verification et completion via Perplexity Sonar Pro (recherche web reelle).
Basculer API_URL et MODEL dans le code, garder la meme structure.

## API Phase 1
- Endpoint : https://openrouter.ai/api/v1/chat/completions
- Modele : moonshotai/kimi-k2.5
- Cle : OPENROUTER_API_KEY
- Cout : GRATUIT

## Architecture
1. PASS1 : hebergements + restaurants (1 requete LLM)
2. PASS2 : services + patrimoine (1 requete LLM)
3. Fusion + dedup via UNIQUE KEY (name, locality_id)
4. Insert en BDD avec ON DUPLICATE KEY UPDATE

## Protection anti-doublons
- UNIQUE KEY `uq_name_locality` (name, locality_id) sur `establishments`
- ON DUPLICATE KEY UPDATE enrichit au lieu de dupliquer
- Dedup inter-pass en dry-run

## Usage
```bash
export DB_PASS="..."
export OPENROUTER_API_KEY="sk-or-..."

node index.js --batch 20
node index.js --batch 5 --dry-run
node index.js --locality-id 42
node index.js --limit 100
```

## Rate limiting
- 1.5 secondes entre chaque requete
- 3 retries max avec backoff exponentiel

## Pre-requis
- `npm install mysql2` (fait dans workspace root)
- Migration SQL `sql/04-add-sonar-source.sql` executee
- Migration SQL `sql/05-unique-establishment-name.sql` executee
