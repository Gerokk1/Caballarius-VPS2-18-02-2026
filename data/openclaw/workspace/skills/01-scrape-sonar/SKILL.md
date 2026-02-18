# Skill 01 : Scrape Perplexity Sonar

Scraper tous les établissements d'une localité via Perplexity Sonar (OpenRouter).
Fait de la VRAIE recherche web — données actuelles, pas de mémoire.
Remplace Google Places API — une seule requête par localité, pas de clé Google nécessaire.

## Modèle
`perplexity/sonar` via OpenRouter

## Coût
- $1/M tokens input + $1/M tokens output + $5/1K requêtes
- ~$0.001 par localité
- 2356 localités = ~$2-3

## Fonctionnement
1. Sélectionne les localités avec `scrape_status='pending'` (batch configurable)
2. Pour chaque localité, envoie une requête Sonar demandant TOUS les établissements
3. Parse la réponse JSON structurée
4. Insère dans `establishments` + `establishment_sources`
5. Met à jour `localities.scrape_status` et log dans `scrape_jobs`

## Protection anti-doublons
- UNIQUE KEY `uq_name_locality` (name, locality_id) sur `establishments`
- `ON DUPLICATE KEY UPDATE` dans l'INSERT — met à jour au lieu de dupliquer
- Pas de fallback dangereux (slug2, timestamp, etc.)

## Catégories cherchées (32)
albergue, hotel, gite, pension, camping, restaurant, bar, cafe, boulangerie, epicerie,
supermarche, pharmacie, medecin, hopital, podologue, fontaine, laverie, banque, dab, poste,
office_tourisme, location_velo, transport_bagages, taxi, eglise, cathedrale, monastere,
musee, monument, point_de_vue, artisan, coup_de_pouce

## Usage
```bash
# Variables d'environnement requises
export DB_PASS="..."
export OPENROUTER_API_KEY="sk-or-..."

# Traiter 20 localités pending
node index.js --batch 20

# Dry run (pas d'écriture BDD)
node index.js --batch 5 --dry-run

# Une seule localité
node index.js --locality-id 42

# Limiter le nombre total
node index.js --limit 100
```

## Rate limiting
- 2 secondes entre chaque requête Sonar
- 3 retries max avec backoff exponentiel (2s, 4s, 8s)

## Pré-requis
- `npm install mysql2` (dans le dossier du skill)
- Migration SQL `sql/04-add-sonar-source.sql` exécutée
- Migration SQL `sql/05-unique-establishment-name.sql` exécutée
