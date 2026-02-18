#!/bin/bash
set -e
SD="/data/openclaw/workspace/skills/06-enrichir-contenu"

cat > "$SD/SKILL.md" << 'EOF'
# Skill : Enrichir Contenu via Kimi K2.5

## Logique langues dynamiques
Pour chaque etablissement :
1. Recuperer le pays → lire countries.languages (JSON)
2. Generer le contenu dans : langues locales + fr + en (toujours)
3. Deduplication : si fr ou en est deja dans langues locales, pas de doublon

### Exemples :
- Espagne (["es"]) → es + fr + en = 3 contenus
- Suisse (["de","fr","it","rm"]) → de + fr + it + rm + en = 5 contenus (fr deja inclus)
- Belgique (["fr","nl","de"]) → fr + nl + de + en = 4 contenus (fr deja inclus)
- Portugal (["pt"]) → pt + fr + en = 3 contenus
- Irlande (["en","ga"]) → en + ga + fr = 3 contenus (en deja inclus)

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
2. Lire countries.languages → construire liste langues unique (local + fr + en)
3. Pour chaque langue : buildPrompt → callKimi → INSERT establishment_content (ON DUPLICATE UPDATE)
4. INSERT establishment_prices pour 3 profils (depuis reponse FR)
5. UPDATE establishments SET scrape_status='enriched'
6. INSERT scrape_jobs (enrichment)

## LLM
- Modele : moonshotai/kimi-k2.5 via OpenRouter
- Format reponse : response_format=json_object
- Tables : establishment_content (lang=VARCHAR(5)), establishment_prices, establishments, scrape_jobs
EOF

cat > "$SD/index.js" << 'JSEOF'
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const MODEL = 'moonshotai/kimi-k2.5';
const ALWAYS_LANGS = ['fr', 'en']; // Toujours generer fr + en en plus des langues locales

async function gatherContext(db, estabId) {
  /* TODO: Load ALL context:
   * - establishment (name, category, lat, lng, google_rating, price_level, address, phone, website, hours)
   * - locality (name, lat, lng)
   * - region (name)
   * - country (name_fr, code_iso, languages)
   * - routes via route_localities + stages
   * - establishment_sources (all scraped data)
   * - establishment_photos (URLs)
   */
}

function buildLangList(countryLanguages) {
  // Merge country languages + ALWAYS_LANGS, deduplicate
  const langSet = new Set(countryLanguages);
  for (const l of ALWAYS_LANGS) langSet.add(l);
  return [...langSet];
}

function buildPrompt(lang, context) {
  /* TODO: Build prompt for Kimi K2.5
   * "Tu es un redacteur specialise tourisme pelerinage Chemins de Saint-Jacques.
   *  Genere en {lang} pour: {name} ({category}) a {locality}, {region}, {country}.
   *  Route: {route} Etape {n}. Note: {rating}/5 ({reviews} avis).
   *  Donnees: {scraped_summary}
   *  Reponds JSON: { description, description_short, highlights[], seo_title, seo_description,
   *    profile_chevalier, profile_moine, profile_pelerin,
   *    price_chevalier:{price,label,includes}, price_moine:{...}, price_pelerin:{...} }"
   * Note: prix seulement demandes pour la version FR
   */
}

async function callKimi(prompt, apiKey) {
  /* TODO: POST OPENROUTER_URL
   * model = MODEL
   * response_format = { type: 'json_object' }
   * Parse response.choices[0].message.content as JSON
   */
}

async function upsertContent(db, estabId, lang, content) {
  /* TODO: INSERT INTO establishment_content
   * (establishment_id, lang, description, description_short, highlights,
   *  seo_title, seo_description, profile_chevalier, profile_moine, profile_pelerin)
   * ON DUPLICATE KEY UPDATE ...
   */
}

async function insertPrices(db, estabId, prices) {
  /* TODO: INSERT establishment_prices for chevalier, moine, pelerin
   * From the FR response only (most reliable for pricing)
   */
}

async function enrichirContenu(establishmentId, db, apiKey) {
  // 1. Gather all context
  const context = await gatherContext(db, establishmentId);
  if (!context) throw new Error(`Establishment ${establishmentId} not found`);

  // 2. Get country languages → build unique lang list
  const countryLangs = JSON.parse(context.country_languages || '["en"]');
  const langs = buildLangList(countryLangs);
  console.log(`Enriching ${context.name} in ${langs.length} languages: ${langs.join(', ')}`);

  // 3. Generate content for each language
  let frResponse = null;
  for (const lang of langs) {
    const prompt = buildPrompt(lang, context);
    const result = await callKimi(prompt, apiKey);
    await upsertContent(db, establishmentId, lang, result);
    if (lang === 'fr') frResponse = result;
  }

  // 4. Insert prices from FR response
  if (frResponse) {
    await insertPrices(db, establishmentId, frResponse);
  }

  // 5. Update status
  // TODO: UPDATE establishments SET scrape_status='enriched' WHERE id=?

  // 6. Log job
  // TODO: INSERT scrape_jobs (enrichment, establishment, done, langs.length)

  return { enriched: true, languages: langs, count: langs.length };
}

module.exports = { enrichirContenu, buildLangList };
JSEOF

echo "SKILL 06 UPDATED"
cat "$SD/SKILL.md" | head -5
echo "---"
cat "$SD/index.js" | head -5
