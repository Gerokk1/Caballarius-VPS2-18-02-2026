# Skill 01 : Scrape Sonar Pro

Scraper tous les établissements d'une localité via Perplexity Sonar Pro (OpenRouter).
Remplace Google Places API — une seule requête par localité, pas de clé Google nécessaire.

## Modèle
`perplexity/sonar-pro` via OpenRouter (clé déjà configurée)

## Fonctionnement
1. Sélectionne les localités avec `scrape_status='pending'` (batch configurable)
2. Pour chaque localité, envoie une requête Sonar Pro demandant TOUS les établissements
3. Parse la réponse JSON structurée
4. Insère dans `establishments` + `establishment_sources`
5. Met à jour `localities.scrape_status` et log dans `scrape_jobs`

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
- 2 secondes entre chaque requête Sonar Pro
- 3 retries max avec backoff exponentiel (2s, 4s, 8s)

## Coût
- Sonar Pro via OpenRouter : ~$3/1000 requêtes
- 2356 localités = ~$7 pour le scraping complet

## Pré-requis
- `npm install mysql2` (dans le dossier du skill)
- Migration SQL `sql/04-add-sonar-source.sql` exécutée
