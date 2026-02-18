# Skill 01 : Scrape Kimi K2.5

Scraper tous les établissements d'une localité via Kimi K2.5 (OpenRouter, GRATUIT).
Remplace Google Places API — une seule requête par localité, pas de clé Google nécessaire.
Kimi connaît beaucoup d'établissements de mémoire (données d'entraînement).
On complètera avec du web scraping direct (Google Maps, Booking) pour les données manquantes.

## Modèle
`moonshotai/kimi-k2.5` via OpenRouter (GRATUIT, clé déjà configurée)

## Fonctionnement
1. Sélectionne les localités avec `scrape_status='pending'` (batch configurable)
2. Pour chaque localité, envoie une requête Kimi K2.5 demandant TOUS les établissements
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
- 2 secondes entre chaque requête Kimi K2.5
- 3 retries max avec backoff exponentiel (2s, 4s, 8s)

## Coût
- Kimi K2.5 via OpenRouter : GRATUIT
- 2356 localités = $0

## Pré-requis
- `npm install mysql2` (dans le dossier du skill)
- Migration SQL `sql/04-add-sonar-source.sql` exécutée
