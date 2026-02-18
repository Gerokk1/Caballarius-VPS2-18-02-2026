#!/bin/bash
set -e
SD="/data/openclaw/workspace/skills"

cat > "$SD/05-scrape-forums/SKILL.md" << 'EOF'
# Skill : Scrape Forums Pelerins
Sources : Gronze.com, CaminoWays, caminodesantiago.me, Reddit, mundicamino.
Avis reels, recommandations, alertes. Respecter robots.txt + rate limit 1req/3s.
Tables : establishment_sources (source_type=forum), scrape_jobs.
EOF

cat > "$SD/05-scrape-forums/index.js" << 'EOF'
const FORUMS = [
  { name:'gronze', url:'https://www.gronze.com', lang:'es' },
  { name:'caminoways', url:'https://www.caminoways.com', lang:'en' },
  { name:'caminoforum', url:'https://www.caminodesantiago.me', lang:'en' },
  { name:'reddit', url:'https://www.reddit.com/r/CaminoDeSantiago', lang:'en' },
  { name:'mundicamino', url:'https://www.mundicamino.com', lang:'es' }
];
const RATE_LIMIT_MS = 3000;

async function searchForum(source, name, locality) { /* TODO: Google "site:{source.url} {name} {locality}" + rate limit */ }
async function extractReviews(pageUrl, source) { /* TODO: Parse reviews, ratings, dates. Filter last 2 years only */ }

async function scrapeForums(establishmentId, db) {
  // TODO:
  // 1. Get establishment + locality
  // 2. For each FORUMS: searchForum -> extractReviews (respect RATE_LIMIT_MS)
  // 3. INSERT establishment_sources for each found source
  // 4. INSERT scrape_jobs
}
module.exports = { scrapeForums };
EOF

cat > "$SD/06-enrichir-contenu/SKILL.md" << 'EOF'
# Skill : Enrichir Contenu via Kimi K2.5
Genere contenu multilingue (FR/ES/EN) + 3 profils (Chevalier/Moine/Pelerin).
Pour chaque langue : description, description_short, highlights, SEO, profils.
Estime prix par profil. Utilise tout le contexte scrape comme input.
Tables : establishment_content, establishment_prices, establishments (->enriched), scrape_jobs.
EOF

cat > "$SD/06-enrichir-contenu/index.js" << 'EOF'
const LANGS = ['fr','es','en'];
const PROFILES = ['chevalier','moine','pelerin'];
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const MODEL = 'moonshotai/kimi-k2.5';

async function gatherContext(db, estabId) {
  /* TODO: Load ALL context: establishment, locality, region, country, routes, stages, sources, photos */
}

// PROMPT TEMPLATE:
// "Tu es un redacteur specialise tourisme pelerinage Chemins de Saint-Jacques.
//  Genere en {lang} pour: {name} ({category}) a {locality}, {region}, {country}.
//  Route: {route} Etape {n}. Note: {rating}/5 ({reviews} avis).
//  Donnees: {scraped_summary}
//  Reponds JSON: { description, description_short, highlights[], seo_title, seo_description,
//    profile_chevalier, profile_moine, profile_pelerin,
//    price_chevalier:{price,label,includes}, price_moine:{...}, price_pelerin:{...} }"

async function callKimi(prompt, apiKey) {
  /* TODO: POST OPENROUTER_URL, model=MODEL, response_format=json_object, parse response */
}

async function enrichirContenu(establishmentId, db, apiKey) {
  // TODO:
  // 1. gatherContext
  // 2. For each LANGS: buildPrompt -> callKimi -> INSERT establishment_content (ON DUPLICATE UPDATE)
  // 3. INSERT establishment_prices for each PROFILES (from FR response)
  // 4. UPDATE establishments SET scrape_status='enriched'
  // 5. INSERT scrape_jobs (enrichment)
}
module.exports = { enrichirContenu };
EOF

cat > "$SD/07-generer-site/SKILL.md" << 'EOF'
# Skill : Generer Site Pro
Template Caballarius v1 : fond nuit etoilee (#0a1628), or (#D4AF37), Cinzel+EB Garamond.
Sections: hero, description, highlights, 3 profils prix, services, carte Leaflet, avis, contact.
Deploy /data/sites/{subdomain}/public/index.html -> {subdomain}.cblrs.net (Nginx wildcard).
Tables : pro_sites, establishments (->site_generated), scrape_jobs.
EOF

cat > "$SD/07-generer-site/index.js" << 'EOF'
const SITES_DIR = '/data/sites';

async function loadAllData(db, estabId) { /* TODO: Load establishment+content+photos+prices+locality+routes */ }
function generateSlug(name) { /* TODO: "Bar El Toro" -> "bar-el-toro", check uniqueness */ }

function renderHTML(data) {
  /* TODO: Generate complete HTML page with caballarius-v1 template
   * Colors: #0a1628 (bg), #1a2a4a (sections), #D4AF37 (gold accent)
   * Fonts: Cinzel (headings), EB Garamond (body)
   * Sections: hero, description, highlights, 3 profile cards, services, Leaflet map, reviews, contact
   * Meta: SEO title, description, OG tags, structured data (Schema.org LocalBusiness)
   * Mobile-first responsive */
}

async function deploy(subdomain, html) {
  /* TODO: mkdir -p /data/sites/{subdomain}/public/ && write index.html && chown www-data */
}

async function genererSite(establishmentId, db) {
  // TODO:
  // 1. loadAllData (must be scrape_status='enriched')
  // 2. generateSlug -> check pro_sites.subdomain uniqueness
  // 3. renderHTML
  // 4. deploy to /data/sites/
  // 5. INSERT/UPDATE pro_sites (subdomain, html_path, deployed_at, is_live=true)
  // 6. UPDATE establishments SET scrape_status='site_generated'
  // 7. INSERT scrape_jobs (site_generation)
  // 8. return { subdomain, url: `https://${subdomain}.cblrs.net` }
}
module.exports = { genererSite };
EOF

cat > "$SD/08-sync-vps1/SKILL.md" << 'EOF'
# Skill : Sync vers VPS1
Push donnees enrichies vers API VPS1 (caballarius.eu). POST /api/etablissements.
HTTPS only. Token API. Retry max 3 (backoff exponentiel). Ne jamais envoyer sources brutes.
Only sync scrape_status IN ('enriched','site_generated').
Tables : establishments (->synced), scrape_jobs.
EOF

cat > "$SD/08-sync-vps1/index.js" << 'EOF'
const MAX_RETRIES = 3;
const RETRY_DELAYS = [1000, 3000, 10000];

async function loadSyncData(db, estabId) { /* TODO: Load enriched data only (NOT sources) */ }
function formatForAPI(data) { /* TODO: Format JSON for VPS1 API */ }

async function pushWithRetry(url, payload, token) {
  /* TODO: POST with retry + backoff
   * Headers: Authorization Bearer, Content-Type application/json
   * Retry on 5xx, fail fast on 4xx */
}

async function syncVPS1(establishmentId, db, vps1ApiUrl) {
  // TODO:
  // 1. Verify scrape_status IN ('enriched','site_generated')
  // 2. loadSyncData -> formatForAPI
  // 3. pushWithRetry (process.env.VPS1_API_TOKEN)
  // 4. UPDATE establishments SET scrape_status='synced'
  // 5. INSERT scrape_jobs (api_sync)
}
module.exports = { syncVPS1 };
EOF

echo "BATCH 2 DONE (skills 05-08)"
find "$SD" -type f | sort
echo "TOTAL FILES:"
find "$SD" -type f | wc -l
