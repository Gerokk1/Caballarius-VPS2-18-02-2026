---
name: 06-enrichir-contenu
description: Enrichir localites avec contenu multilingue via Kimi K2.5
tools:
  - exec
trigger: cron
schedule: "0 4 * * *"
agent: batisseur
db_user: batisseur_user
tables_read:
  - localities
  - routes
  - route_localities
  - countries
  - stages
tables_write:
  - locality_content
  - scrape_jobs
env:
  - DB_HOST
  - DB_USER=BATISSEUR_DB_USER
  - DB_PASS=BATISSEUR_DB_PASS
  - DB_NAME
  - OPENROUTER_API_KEY
---

# Skill : Enrichir Contenu via Kimi K2.5

## Logique langues dynamiques
Pour chaque etablissement :
1. Recuperer le pays â†’ lire countries.languages (JSON)
2. Generer le contenu dans : langues locales + fr + en (toujours)
3. Deduplication : si fr ou en est deja dans langues locales, pas de doublon

### Exemples :
- Espagne (["es"]) â†’ es + fr + en = 3 contenus
- Suisse (["de","fr","it","rm"]) â†’ de + fr + it + rm + en = 5 contenus (fr deja inclus)
- Belgique (["fr","nl","de"]) â†’ fr + nl + de + en = 4 contenus (fr deja inclus)
- Portugal (["pt"]) â†’ pt + fr + en = 3 contenus
- Irlande (["en","ga"]) â†’ en + ga + fr = 3 contenus (en deja inclus)

## Contenu genere par langue
Pour chaque langue (establishment_content, 1 row par langue) :
- description (200-400 mots)
- description_short (max 300 car)
- highlights (3-5 points forts, JSON array)
- seo_title (max 70 car)
- seo_description (max 160 car)
- profile_chevalier, profile_moine, profile_pelerin (textes adaptes)

## Prix (une seule fois, depuis la reponse FR)
establishment_prices : 3 rows (chevalier, moine, pelerin)
- price_estimate, price_label, price_includes

## Pipeline
1. gatherContext (establishment + locality + region + country + routes + stages + sources + photos)
2. Lire countries.languages â†’ construire liste langues unique (local + fr + en)
3. Pour chaque langue : buildPrompt â†’ callKimi â†’ INSERT establishment_content (ON DUPLICATE UPDATE)
4. INSERT establishment_prices pour 3 profils (depuis reponse FR)
5. UPDATE establishments SET scrape_status='enriched'
6. INSERT scrape_jobs (enrichment)

## LLM
- Modele : moonshotai/kimi-k2.5 via OpenRouter
- Format reponse : response_format=json_object
- Tables : establishment_content (lang=VARCHAR(5)), establishment_prices, establishments, scrape_jobs
