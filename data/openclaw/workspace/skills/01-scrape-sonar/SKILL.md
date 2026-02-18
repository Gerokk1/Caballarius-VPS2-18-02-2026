# Skill 01 : Brave Search + Kimi K2.5

Architecture en 2 etapes pour scraper les etablissements, 100% gratuit.

## Architecture
1. **Brave Search API** (gratuit, 2000 req/mois) : 2 recherches par localite
   - Recherche 1 : hebergements + restaurants
   - Recherche 2 : services + patrimoine
2. **Kimi K2.5** (gratuit via OpenRouter) : extrait les etablissements en JSON structure

## Cout
- Brave Search : GRATUIT (2000 req/mois)
- Kimi K2.5 via OpenRouter : GRATUIT
- **Total : $0**

## Limites
- 2000 requetes Brave/mois = ~666 localites/mois (2 req/localite)
- 2356 localites = ~3.5 mois au rythme gratuit
- Upgrade Brave a $5/mois = illimite

## Protection anti-doublons
- UNIQUE KEY `uq_name_locality` (name, locality_id) sur `establishments`
- `ON DUPLICATE KEY UPDATE` dans l'INSERT
- Pas de fallback dangereux

## Usage
```bash
# Variables d'environnement requises
export DB_PASS="..."
export OPENROUTER_API_KEY="sk-or-..."
export BRAVE_API_KEY="BSA..."

# Traiter 20 localites pending
node index.js --batch 20

# Dry run
node index.js --batch 5 --dry-run

# Une seule localite
node index.js --locality-id 42

# Limiter le nombre total
node index.js --limit 100
```

## Rate limiting
- Brave : 1 req/sec (1100ms entre chaque)
- Kimi : 1 req/sec
- Total par localite : ~4 secondes

## Pre-requis
- `npm install mysql2`
- Migration SQL `sql/04-add-sonar-source.sql` executee
- Migration SQL `sql/05-unique-establishment-name.sql` executee
- Cle Brave gratuite : https://api.search.brave.com/app/keys
