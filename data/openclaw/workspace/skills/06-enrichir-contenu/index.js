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

  // 2. Get country languages â†’ build unique lang list
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
