#!/usr/bin/env node
/**
 * SKILL 01-scrape-sonar — Brave Search + Kimi K2.5
 *
 * Architecture :
 *   1. Brave Search API (gratuit, 2000 req/mois) → résultats web bruts
 *   2. Kimi K2.5 via OpenRouter (gratuit) → extraction JSON structuré
 *
 * 2 recherches Brave + 1 appel Kimi par localité = 3 appels, $0.
 * 2000 req Brave/mois = ~666 localités/mois (3 mois pour 2356).
 *
 * Usage:
 *   node index.js --batch 20
 *   node index.js --locality-id 42
 *   node index.js --limit 100 --dry-run
 */

const mysql = require('mysql2/promise');

// ─── Configuration ──────────────────────────────────────────────────────────

const DB_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'cblrs_user',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'caballarius_staging',
  charset: 'utf8mb4',
};

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const MODEL = 'moonshotai/kimi-k2.5';

const BRAVE_API_KEY = process.env.BRAVE_API_KEY || '';
const BRAVE_SEARCH_URL = 'https://api.search.brave.com/res/v1/web/search';

const BRAVE_RATE_MS = 1100;  // Brave free = 1 req/sec
const KIMI_RATE_MS = 1000;
const MAX_RETRIES = 3;
const DEFAULT_BATCH = 20;

// 32 catégories Caballarius (doit matcher l'ENUM establishments.category)
const VALID_CATEGORIES = new Set([
  'albergue','hotel','gite','pension','camping',
  'restaurant','bar','cafe','boulangerie','epicerie','supermarche',
  'pharmacie','medecin','hopital','podologue',
  'fontaine','laverie','banque','dab','poste',
  'office_tourisme','location_velo','transport_bagages','taxi',
  'eglise','cathedrale','monastere','musee','monument','point_de_vue',
  'artisan','coup_de_pouce',
]);

// Mapping mots courants → catégorie ENUM
const CATEGORY_ALIASES = {
  'accommodation': 'albergue', 'hébergement': 'albergue', 'lodging': 'albergue',
  'auberge': 'albergue', 'hostel': 'albergue', 'refugio': 'albergue', 'refuge': 'albergue', 'albergue': 'albergue',
  'hotel': 'hotel', 'hôtel': 'hotel', 'hostal': 'hotel',
  'gîte': 'gite', 'gite': 'gite', "chambre d'hôte": 'gite', "chambre d'hotes": 'gite', "chambres d'hotes": 'gite', "chambres d'hôtes": 'gite', 'casa rural': 'gite',
  'pension': 'pension', 'pensión': 'pension', 'b&b': 'pension', 'bed and breakfast': 'pension',
  'camping': 'camping',
  'restaurant': 'restaurant', 'restaurante': 'restaurant',
  'bar': 'bar', 'pub': 'bar', 'taberna': 'bar',
  'café': 'cafe', 'cafe': 'cafe', 'cafetería': 'cafe', 'cafeteria': 'cafe',
  'boulangerie': 'boulangerie', 'panadería': 'boulangerie', 'panaderia': 'boulangerie', 'bakery': 'boulangerie',
  'épicerie': 'epicerie', 'epicerie': 'epicerie', 'tienda': 'epicerie', 'grocery': 'epicerie', 'minimarket': 'epicerie',
  'supermarché': 'supermarche', 'supermarche': 'supermarche', 'supermercado': 'supermarche', 'supermarket': 'supermarche',
  'pharmacie': 'pharmacie', 'farmacia': 'pharmacie', 'pharmacy': 'pharmacie',
  'médecin': 'medecin', 'medecin': 'medecin', 'doctor': 'medecin', 'médico': 'medecin',
  'hôpital': 'hopital', 'hopital': 'hopital', 'hospital': 'hopital', 'centro de salud': 'hopital',
  'podologue': 'podologue', 'podólogo': 'podologue',
  'fontaine': 'fontaine', 'fuente': 'fontaine', 'fountain': 'fontaine',
  'laverie': 'laverie', 'lavandería': 'laverie', 'laundry': 'laverie', 'lavadero': 'laverie',
  'banque': 'banque', 'banco': 'banque', 'bank': 'banque',
  'distributeur': 'dab', 'dab': 'dab', 'atm': 'dab', 'cajero': 'dab',
  'poste': 'poste', 'correos': 'poste', 'post office': 'poste',
  'office de tourisme': 'office_tourisme', 'oficina de turismo': 'office_tourisme', 'tourist office': 'office_tourisme',
  'location vélo': 'location_velo', 'location velo': 'location_velo', 'bike rental': 'location_velo', 'alquiler bicicletas': 'location_velo',
  'transport bagages': 'transport_bagages', 'luggage transfer': 'transport_bagages', 'transporte equipajes': 'transport_bagages',
  'taxi': 'taxi',
  'église': 'eglise', 'eglise': 'eglise', 'iglesia': 'eglise', 'church': 'eglise',
  'cathédrale': 'cathedrale', 'cathedrale': 'cathedrale', 'catedral': 'cathedrale', 'cathedral': 'cathedrale',
  'monastère': 'monastere', 'monastere': 'monastere', 'monasterio': 'monastere', 'monastery': 'monastere', 'convento': 'monastere',
  'musée': 'musee', 'musee': 'musee', 'museo': 'musee', 'museum': 'musee',
  'monument': 'monument', 'monumento': 'monument',
  'point de vue': 'point_de_vue', 'mirador': 'point_de_vue', 'viewpoint': 'point_de_vue',
  'artisan': 'artisan', 'artesano': 'artisan',
  'coup de pouce': 'coup_de_pouce',
};

// ─── Helpers ────────────────────────────────────────────────────────────────

function slugify(str) {
  return str
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 340);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function mapCategory(raw) {
  if (!raw) return null;
  const normalized = raw.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim();

  // Direct match dans VALID_CATEGORIES
  if (VALID_CATEGORIES.has(normalized)) return normalized;

  // Match via aliases (substring, both sides normalized)
  for (const [alias, cat] of Object.entries(CATEGORY_ALIASES)) {
    const normAlias = alias.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    if (normalized.includes(normAlias) || normAlias.includes(normalized)) return cat;
  }

  return null;
}

function extractJSON(text) {
  let cleaned = text.replace(/```json\s*/gi, '').replace(/```\s*/g, '');

  const start = cleaned.indexOf('{');
  if (start === -1) return null;

  let end = cleaned.lastIndexOf('}');
  if (end === -1 || end <= start) {
    cleaned = cleaned.substring(start);
    const lastComplete = cleaned.lastIndexOf('}');
    if (lastComplete > 0) {
      cleaned = cleaned.substring(0, lastComplete + 1) + ']}';
    } else {
      return null;
    }
  } else {
    cleaned = cleaned.substring(start, end + 1);
  }

  cleaned = cleaned.replace(/,\s*([}\]])/g, '$1');

  try {
    return JSON.parse(cleaned);
  } catch (e) {
    const lastBrace = cleaned.lastIndexOf('}', cleaned.length - 2);
    if (lastBrace > 0) {
      const truncated = cleaned.substring(0, lastBrace + 1) + ']}';
      try {
        return JSON.parse(truncated);
      } catch (e2) { /* fallthrough */ }
    }
    return null;
  }
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { batch: DEFAULT_BATCH, dryRun: false, localityId: null, limit: null };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--batch': opts.batch = parseInt(args[++i]) || DEFAULT_BATCH; break;
      case '--dry-run': opts.dryRun = true; break;
      case '--locality-id': opts.localityId = parseInt(args[++i]); break;
      case '--limit': opts.limit = parseInt(args[++i]); break;
    }
  }
  return opts;
}

// ─── Brave Search API ───────────────────────────────────────────────────────

async function searchBrave(query, retryCount = 0) {
  const url = `${BRAVE_SEARCH_URL}?q=${encodeURIComponent(query)}&count=10`;
  const response = await fetch(url, {
    headers: {
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'X-Subscription-Token': BRAVE_API_KEY,
    },
  });

  if (!response.ok) {
    const errBody = await response.text();
    if (retryCount < MAX_RETRIES && (response.status === 429 || response.status >= 500)) {
      const delay = BRAVE_RATE_MS * Math.pow(2, retryCount);
      console.log(`  [BRAVE RETRY ${retryCount + 1}/${MAX_RETRIES}] ${response.status} — ${delay}ms`);
      await sleep(delay);
      return searchBrave(query, retryCount + 1);
    }
    throw new Error(`Brave ${response.status}: ${errBody.substring(0, 200)}`);
  }

  const data = await response.json();
  const results = (data.web?.results || []).slice(0, 10);

  return results.map(r => ({
    title: r.title || '',
    url: r.url || '',
    description: r.description || '',
  }));
}

// ─── Kimi K2.5 via OpenRouter ───────────────────────────────────────────────

function buildKimiPrompt(localityName, routeName, searchResults) {
  const resultsText = searchResults.map((r, i) =>
    `${i + 1}. ${r.title}\n   ${r.url}\n   ${r.description}`
  ).join('\n\n');

  return `Voici des résultats de recherche web pour les établissements à "${localityName}" sur le ${routeName} (Camino de Santiago).

RÉSULTATS DE RECHERCHE :
${resultsText}

À partir de ces résultats, extrais TOUS les établissements mentionnés.
Pour chaque établissement, donne :
- name : nom exact de l'établissement
- category : exactement un de [albergue, hotel, gite, pension, camping, restaurant, bar, cafe, boulangerie, epicerie, supermarche, pharmacie, medecin, hopital, podologue, fontaine, laverie, banque, dab, poste, office_tourisme, location_velo, transport_bagages, taxi, eglise, cathedrale, monastere, musee, monument, point_de_vue]
- address : adresse (ou null)
- phone : téléphone (ou null)
- email : email (ou null)
- website : URL (ou null)
- opening_hours : horaires (ou null)
- google_rating : note /5 (ou null)
- google_reviews_count : nombre d'avis (ou 0)
- price_level : 1 à 4 (ou null)
- services : tableau de strings (ou [])

Réponds UNIQUEMENT avec du JSON valide :
{"establishments": [...]}
Si aucun établissement trouvé : {"establishments": []}`;
}

async function callKimi(prompt, retryCount = 0) {
  const response = await fetch(OPENROUTER_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://cblrs.net',
      'X-Title': 'Caballarius-Skill01',
    },
    body: JSON.stringify({
      model: MODEL,
      messages: [
        {
          role: 'system',
          content: 'Tu es un extracteur de données. Tu analyses des résultats de recherche web et tu extrais les établissements mentionnés en JSON structuré. UNIQUEMENT du JSON, sans markdown, sans commentaire.'
        },
        { role: 'user', content: prompt }
      ],
      temperature: 0.1,
      max_tokens: 16384,
    }),
  });

  if (!response.ok) {
    const errBody = await response.text();
    if (retryCount < MAX_RETRIES && (response.status === 429 || response.status >= 500)) {
      const delay = KIMI_RATE_MS * Math.pow(2, retryCount);
      console.log(`  [KIMI RETRY ${retryCount + 1}/${MAX_RETRIES}] ${response.status} — ${delay}ms`);
      await sleep(delay);
      return callKimi(prompt, retryCount + 1);
    }
    throw new Error(`OpenRouter ${response.status}: ${errBody.substring(0, 200)}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || '';
  return { content };
}

// ─── Database ───────────────────────────────────────────────────────────────

async function getNextBatch(db, batchSize, localityId) {
  if (localityId) {
    const [rows] = await db.query(`
      SELECT l.id, l.name, l.lat, l.lng,
             GROUP_CONCAT(DISTINCT r.name SEPARATOR ' / ') AS route_names
      FROM localities l
      JOIN route_localities rl ON rl.locality_id = l.id
      JOIN routes r ON r.id = rl.route_id
      WHERE l.id = ?
      GROUP BY l.id
    `, [localityId]);
    return rows;
  }

  const [rows] = await db.query(`
    SELECT l.id, l.name, l.lat, l.lng,
           GROUP_CONCAT(DISTINCT r.name SEPARATOR ' / ') AS route_names
    FROM localities l
    JOIN route_localities rl ON rl.locality_id = l.id
    JOIN routes r ON r.id = rl.route_id
    WHERE l.scrape_status = 'pending'
    GROUP BY l.id
    ORDER BY l.id
    LIMIT ?
  `, [batchSize]);
  return rows;
}

async function countPending(db) {
  const [[row]] = await db.query(`SELECT COUNT(*) AS cnt FROM localities WHERE scrape_status = 'pending'`);
  return row.cnt;
}

async function setLocalityStatus(db, localityId, status) {
  const extra = status === 'done' ? ', scraped_at = NOW()' : '';
  await db.query(`UPDATE localities SET scrape_status = ?${extra} WHERE id = ?`, [status, localityId]);
}

async function insertEstablishment(db, localityId, lat, lng, est) {
  const category = mapCategory(est.category);
  if (!category) return null;

  const name = (est.name || '').trim();
  if (!name) return null;

  const slug = slugify(`${name}-${localityId}`);
  const address = (est.address || '').trim() || name;

  const phone = est.phone || null;
  const email = est.email || null;
  const website = est.website || null;
  const rating = (typeof est.google_rating === 'number') ? est.google_rating : null;
  const reviewsCount = parseInt(est.google_reviews_count) || 0;
  const priceLevel = ([1,2,3,4].includes(est.price_level)) ? est.price_level : null;
  const hours = est.opening_hours ? JSON.stringify(est.opening_hours) : null;

  try {
    const [result] = await db.query(`
      INSERT INTO establishments
        (locality_id, name, slug, category, address, lat, lng,
         phone, email, website, google_rating, google_reviews_count,
         price_level, opening_hours, scrape_status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'scraped')
      ON DUPLICATE KEY UPDATE
        slug = VALUES(slug),
        category = VALUES(category),
        address = COALESCE(VALUES(address), address),
        phone = COALESCE(VALUES(phone), phone),
        email = COALESCE(VALUES(email), email),
        website = COALESCE(VALUES(website), website),
        google_rating = COALESCE(VALUES(google_rating), google_rating),
        google_reviews_count = GREATEST(VALUES(google_reviews_count), google_reviews_count),
        price_level = COALESCE(VALUES(price_level), price_level),
        opening_hours = COALESCE(VALUES(opening_hours), opening_hours),
        updated_at = NOW(),
        id = LAST_INSERT_ID(id)
    `, [localityId, name, slug, category, address, lat, lng,
        phone, email, website, rating, reviewsCount, priceLevel, hours]);

    return result.insertId || null;
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      console.log(`    [SKIP] Doublon: ${name}`);
      return null;
    }
    console.log(`    [ERR] Insert ${name}: ${err.message}`);
    return null;
  }
}

async function insertSource(db, establishmentId, rawJson) {
  await db.query(`
    INSERT INTO establishment_sources (establishment_id, source_type, data_json)
    VALUES (?, 'sonar_pro', ?)
  `, [establishmentId, JSON.stringify(rawJson)]);
}

async function logScrapeJob(db, localityId, status, count, costUsd, errorLog) {
  await db.query(`
    INSERT INTO scrape_jobs
      (job_type, target_type, target_id, status, started_at, completed_at, results_count, cost_usd, error_log)
    VALUES ('sonar_pro', 'locality', ?, ?, NOW(), NOW(), ?, ?, ?)
  `, [localityId, status, count, costUsd, errorLog]);
}

// ─── Main ───────────────────────────────────────────────────────────────────

async function processLocality(db, locality, dryRun) {
  const { id, name, lat, lng, route_names } = locality;
  const routeName = route_names || 'Camino de Santiago';

  console.log(`\n[${id}] ${name} (${lat}, ${lng}) -- ${routeName}`);

  // 1. Marquer in_progress
  if (!dryRun) await setLocalityStatus(db, id, 'in_progress');

  // 2. Brave Search #1 : hebergement + restauration
  const query1 = `hebergement albergue hotel restaurant "${name}" Camino de Santiago`;
  console.log(`  BRAVE #1: ${query1}`);
  let results1 = [];
  try {
    results1 = await searchBrave(query1);
    console.log(`  -> ${results1.length} resultats web`);
  } catch (err) {
    console.log(`  [ERREUR BRAVE #1] ${err.message}`);
  }

  await sleep(BRAVE_RATE_MS);

  // 3. Brave Search #2 : services
  const query2 = `pharmacie banque office tourisme eglise "${name}" services`;
  console.log(`  BRAVE #2: ${query2}`);
  let results2 = [];
  try {
    results2 = await searchBrave(query2);
    console.log(`  -> ${results2.length} resultats web`);
  } catch (err) {
    console.log(`  [ERREUR BRAVE #2] ${err.message}`);
  }

  // 4. Combiner les resultats
  const allResults = [...results1, ...results2];
  if (allResults.length === 0) {
    console.log(`  [AUCUN RESULTAT] Brave n'a rien trouve`);
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, 'No Brave results');
    }
    return { inserted: 0, skipped: 0, error: 'no_brave_results' };
  }

  console.log(`  ${allResults.length} resultats web combines -> Kimi K2.5...`);

  await sleep(KIMI_RATE_MS);

  // 5. Kimi K2.5 extrait les etablissements
  const kimiPrompt = buildKimiPrompt(name, routeName, allResults);
  let kimiResult;
  try {
    kimiResult = await callKimi(kimiPrompt);
  } catch (err) {
    console.log(`  [ERREUR KIMI] ${err.message}`);
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, err.message);
    }
    return { inserted: 0, skipped: 0, error: err.message };
  }

  // 6. Parser la reponse JSON
  const parsed = extractJSON(kimiResult.content);
  if (!parsed || !Array.isArray(parsed.establishments)) {
    console.log(`  [ERREUR PARSE] Reponse non-JSON (${kimiResult.content.length} chars):`);
    console.log(`  ${kimiResult.content.substring(0, 300)}`);
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, 'JSON parse failed');
    }
    return { inserted: 0, skipped: 0, error: 'parse_failed' };
  }

  const establishments = parsed.establishments;
  console.log(`  Kimi -> ${establishments.length} etablissements extraits`);

  if (dryRun) {
    let mapped = 0;
    for (const est of establishments) {
      const cat = mapCategory(est.category);
      const label = cat ? `+ ${cat}` : `x "${est.category}"`;
      console.log(`    ${label} -- ${est.name}`);
      if (cat) mapped++;
    }
    console.log(`  [DRY RUN] ${mapped}/${establishments.length} categorises, $0`);
    return { inserted: mapped, skipped: establishments.length - mapped, error: null };
  }

  // 7. Inserer en BDD
  let inserted = 0, skipped = 0;
  for (const est of establishments) {
    const estId = await insertEstablishment(db, id, lat, lng, est);
    if (estId) {
      await insertSource(db, estId, est);
      inserted++;
      console.log(`    + ${est.name} [${mapCategory(est.category)}]`);
    } else {
      skipped++;
    }
  }

  // 8. Mettre a jour le statut
  await setLocalityStatus(db, id, 'done');
  await logScrapeJob(db, id, 'done', inserted, 0, null);

  console.log(`  -> ${inserted} inseres, ${skipped} ignores, $0`);
  return { inserted, skipped, error: null };
}

async function main() {
  const opts = parseArgs();

  // Validations
  if (!DB_CONFIG.password) {
    console.error('ERREUR: DB_PASS non defini. export DB_PASS="..."');
    process.exit(1);
  }
  if (!OPENROUTER_API_KEY) {
    console.error('ERREUR: OPENROUTER_API_KEY non defini. export OPENROUTER_API_KEY="sk-or-..."');
    process.exit(1);
  }
  if (!BRAVE_API_KEY) {
    console.error('ERREUR: BRAVE_API_KEY non defini. export BRAVE_API_KEY="BSA..."');
    console.error('Cree une cle gratuite : https://api.search.brave.com/app/keys');
    process.exit(1);
  }

  console.log('='.repeat(60));
  console.log('SKILL 01 -- Brave Search + Kimi K2.5');
  console.log(`Brave: 2 recherches/localite | Kimi: ${MODEL}`);
  console.log(`Batch: ${opts.batch} | Dry run: ${opts.dryRun} | Locality: ${opts.localityId || 'auto'} | Limit: ${opts.limit || 'none'}`);
  console.log('Cout: $0 (Brave free + Kimi free)');
  console.log('='.repeat(60));

  const db = await mysql.createConnection(DB_CONFIG);

  try {
    const pending = await countPending(db);
    console.log(`Localites pending: ${pending}`);

    let totalInserted = 0, totalSkipped = 0, totalErrors = 0;
    let braveQueries = 0;
    let processed = 0;

    while (true) {
      const batchSize = opts.limit
        ? Math.min(opts.batch, opts.limit - processed)
        : opts.batch;

      if (batchSize <= 0) break;

      const batch = await getNextBatch(db, batchSize, opts.localityId);
      if (batch.length === 0) {
        console.log('\nAucune localite pending restante.');
        break;
      }

      for (const locality of batch) {
        const result = await processLocality(db, locality, opts.dryRun);
        totalInserted += result.inserted;
        totalSkipped += result.skipped;
        if (result.error) totalErrors++;
        braveQueries += 2;
        processed++;

        if (opts.limit && processed >= opts.limit) break;

        await sleep(BRAVE_RATE_MS);
      }

      if (opts.localityId) break;
      if (opts.limit && processed >= opts.limit) break;
    }

    console.log('\n' + '='.repeat(60));
    console.log('RESULTAT FINAL');
    console.log(`  Localites traitees: ${processed}`);
    console.log(`  Etablissements inseres: ${totalInserted}`);
    console.log(`  Etablissements ignores: ${totalSkipped}`);
    console.log(`  Erreurs: ${totalErrors}`);
    console.log(`  Requetes Brave utilisees: ${braveQueries}/2000`);
    console.log(`  Cout total: $0`);
    console.log('='.repeat(60));

  } finally {
    await db.end();
  }
}

main().catch(err => {
  console.error('FATAL:', err);
  process.exit(1);
});
