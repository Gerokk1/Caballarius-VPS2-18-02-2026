# Skills Custom OpenClaw — Caballarius

## Localisation
/data/openclaw/workspace/skills/ (8 dossiers, 16 fichiers)

## Statut : SQUELETTES (TODO a implementer)

---

## 01-scrape-sonar
**Fonction** : node index.js (CLI)
**But** : Scraper TOUS les etablissements d'une localite via Perplexity Sonar Pro
**API** : perplexity/sonar-pro via OpenRouter (cle deja configuree)
**Categories** : 32 categories Caballarius (mapping fuzzy FR/ES/EN)
**Entrees** : localityId (ou batch de pending)
**Sorties** : establishments, establishment_sources (source_type=sonar_pro), scrape_jobs
**Methode** : 1 requete Sonar Pro par localite, reponse JSON structuree
**Rate limit** : 2s entre requetes, 3 retries backoff exponentiel
**Cout** : ~$3/1000 requetes, ~$7 pour les 2356 localites
**Status** : localities.scrape_status -> 'in_progress' -> 'done'
**Migration** : sql/04-add-sonar-source.sql (ENUM sonar_pro)
**Usage** : `node index.js --batch 20`, `--dry-run`, `--locality-id 42`, `--limit 100`

---

## 02-scrape-facebook
**Fonction** : scrapeFacebook(establishmentId, db)
**But** : Enrichir avec photos/avis Facebook
**Entrees** : establishmentId (deja scrape Google)
**Sorties** : establishment_photos (source=facebook), establishment_sources
**Methode** : Graph API ou browser scraping, Google "site:facebook.com {name} {locality}"

---

## 03-scrape-instagram
**Fonction** : scrapeInstagram(localityId, db)
**But** : Photos geolocalisees + hashtags camino
**Hashtags** : #caminofrances, #caminodesantiago, #[ville], #[route]
**Entrees** : localityId
**Sorties** : establishment_photos (source=instagram), establishment_sources
**Selection** : 10 meilleures photos par etablissement (likes, qualite)
**Methode** : Browser tool obligatoire, URLs only (pas download)

---

## 04-scrape-tourisme
**Fonction** : scrapeTourisme(localityId, db)
**But** : Infos culturelles depuis offices tourisme + Wikipedia
**Sources** : turismo.{ville}.es, ot-{ville}.fr, Wikipedia, portails regionaux
**Entrees** : localityId
**Sorties** : establishment_content, establishment_sources

---

## 05-scrape-forums
**Fonction** : scrapeForums(establishmentId, db)
**But** : Avis pelerins depuis forums specialises
**Sources** : Gronze.com, CaminoWays, caminodesantiago.me, Reddit r/CaminoDeSantiago, mundicamino.com
**Entrees** : establishmentId
**Sorties** : establishment_sources (source_type=forum)
**Donnees** : notes, avis, recommandations, alertes
**Rate limit** : 1 requete / 3 secondes, respecter robots.txt
**Filtre** : avis des 2 dernieres annees uniquement

---

## 06-enrichir-contenu
**Fonction** : enrichirContenu(establishmentId, db, apiKey)
**But** : Generation IA du contenu multilingue dynamique + 3 profils
**LLM** : Kimi K2.5 via OpenRouter (moonshotai/kimi-k2.5, response_format=json_object)
**Logique langues** :
- Lire countries.languages (JSON) pour le pays de l'etablissement
- Ajouter fr + en (toujours), deduplication automatique
- Exemples : ES = es+fr+en (3), CH = de+fr+it+rm+en (5), BE = fr+nl+de+en (4), IE = en+ga+fr (3)
**Genere par langue** :
- description (200-400 mots)
- description_short (max 300 car)
- highlights (3-5 points forts JSON)
- seo_title (max 70 car) + seo_description (max 160 car)
- profile_chevalier / profile_moine / profile_pelerin
**Prix** : estimes par profil (price, label, includes) — depuis reponse FR uniquement
**Entrees** : establishmentId + toutes les donnees scrapees en contexte
**Sorties** : establishment_content (lang=VARCHAR(5), ON DUPLICATE UPDATE), establishment_prices
**Status** : establishments.scrape_status -> 'enriched'

---

## 07-generer-site
**Fonction** : genererSite(establishmentId, db)
**But** : Generer un site web statique et le deployer
**Template** : caballarius-v1
- Fond : nuit etoilee (#0a1628), sections (#1a2a4a), accent or (#D4AF37)
- Polices : Cinzel (titres), EB Garamond (corps)
- Mobile-first responsive
**Sections** : hero, description, highlights, 3 profils prix, services, carte Leaflet, avis, contact
**SEO** : title, meta description, OG tags, Schema.org LocalBusiness (structured data)
**Deploy** : /data/sites/{subdomain}/public/index.html -> {subdomain}.cblrs.net (Nginx wildcard)
**Entrees** : establishmentId (enrichi)
**Sorties** : pro_sites (subdomain, html_path, deployed_at, is_live=true)
**Status** : establishments.scrape_status -> 'site_generated'

---

## 08-sync-vps1
**Fonction** : syncVPS1(establishmentId, db, vps1ApiUrl)
**But** : Push donnees enrichies vers API VPS1 (caballarius.eu)
**Methode** : POST HTTPS + token API (process.env.VPS1_API_TOKEN)
**Retries** : Max 3, backoff exponentiel (1s, 3s, 10s)
**Securite** : NE JAMAIS envoyer les sources brutes, uniquement contenu enrichi
**Condition** : scrape_status IN ('enriched','site_generated')
**Entrees** : establishmentId
**Sorties** : scrape_jobs (api_sync)
**Status** : establishments.scrape_status -> 'synced'
