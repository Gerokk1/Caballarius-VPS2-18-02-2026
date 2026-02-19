#!/usr/bin/env node
/**
 * SKILL 01-scrape-sonar — Kimi K2.5 via OpenRouter (GRATUIT)
 *
 * Phase 1 : Kimi K2.5 (gratuit) scrape toutes les localites de memoire.
 * Phase 2 (semaine prochaine) : Sonar Pro verifie et complete.
 * 2 passes par localite : hebergement+resto puis services.
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

// AI Provider: google (Gemini 2.5 Flash, gratuit) ou openrouter (Kimi K2.5)
const AI_PROVIDER = (process.env.AI_PROVIDER || 'google').toLowerCase();
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY || '';
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const OPENROUTER_MODEL = 'moonshotai/kimi-k2.5';
const GOOGLE_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${GOOGLE_API_KEY}`;

const RATE_LIMIT_MS = 1500;
const MAX_RETRIES = 3;
const DEFAULT_BATCH = 20;

// 32 categories Caballarius (doit matcher l'ENUM establishments.category)
const VALID_CATEGORIES = new Set([
  'albergue','hotel','gite','pension','camping',
  'restaurant','bar','cafe','boulangerie','epicerie','supermarche',
  'pharmacie','medecin','hopital','podologue',
  'fontaine','laverie','banque','dab','poste',
  'office_tourisme','location_velo','transport_bagages','taxi',
  'eglise','cathedrale','monastere','musee','monument','point_de_vue',
  'artisan','coup_de_pouce',
]);

// Mapping mots courants → categorie ENUM
const CATEGORY_ALIASES = {
  'accommodation': 'albergue', 'hebergement': 'albergue', 'lodging': 'albergue',
  'auberge': 'albergue', 'hostel': 'albergue', 'refugio': 'albergue', 'refuge': 'albergue', 'albergue': 'albergue',
  'hotel': 'hotel', 'hostal': 'hotel',
  'gite': 'gite', "chambre d'hote": 'gite', "chambre d'hotes": 'gite', "chambres d'hotes": 'gite', 'casa rural': 'gite',
  'pension': 'pension', 'b&b': 'pension', 'bed and breakfast': 'pension',
  'camping': 'camping',
  'restaurant': 'restaurant', 'restaurante': 'restaurant',
  'bar': 'bar', 'pub': 'bar', 'taberna': 'bar',
  'cafe': 'cafe', 'cafeteria': 'cafe',
  'boulangerie': 'boulangerie', 'panaderia': 'boulangerie', 'bakery': 'boulangerie',
  'epicerie': 'epicerie', 'tienda': 'epicerie', 'grocery': 'epicerie', 'minimarket': 'epicerie',
  'supermarche': 'supermarche', 'supermercado': 'supermarche', 'supermarket': 'supermarche',
  'pharmacie': 'pharmacie', 'farmacia': 'pharmacie', 'pharmacy': 'pharmacie',
  'medecin': 'medecin', 'doctor': 'medecin', 'medico': 'medecin',
  'hopital': 'hopital', 'hospital': 'hopital', 'centro de salud': 'hopital',
  'podologue': 'podologue', 'podologo': 'podologue',
  'fontaine': 'fontaine', 'fuente': 'fontaine', 'fountain': 'fontaine',
  'laverie': 'laverie', 'lavanderia': 'laverie', 'laundry': 'laverie', 'lavadero': 'laverie',
  'banque': 'banque', 'banco': 'banque', 'bank': 'banque',
  'distributeur': 'dab', 'dab': 'dab', 'atm': 'dab', 'cajero': 'dab',
  'poste': 'poste', 'correos': 'poste', 'post office': 'poste',
  'office de tourisme': 'office_tourisme', 'oficina de turismo': 'office_tourisme', 'tourist office': 'office_tourisme',
  'location velo': 'location_velo', 'bike rental': 'location_velo', 'alquiler bicicletas': 'location_velo',
  'transport bagages': 'transport_bagages', 'luggage transfer': 'transport_bagages', 'transporte equipajes': 'transport_bagages',
  'taxi': 'taxi',
  'eglise': 'eglise', 'iglesia': 'eglise', 'church': 'eglise',
  'cathedrale': 'cathedrale', 'catedral': 'cathedrale', 'cathedral': 'cathedrale',
  'monastere': 'monastere', 'monasterio': 'monastere', 'monastery': 'monastere', 'convento': 'monastere',
  'musee': 'musee', 'museo': 'musee', 'museum': 'musee',
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

  if (VALID_CATEGORIES.has(normalized)) return normalized;

  for (const [alias, cat] of Object.entries(CATEGORY_ALIASES)) {
    if (normalized.includes(alias) || alias.includes(normalized)) return cat;
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

// ─── Perplexity Sonar API ───────────────────────────────────────────────────

const JSON_FIELDS = `Pour CHAQUE etablissement, donne :
- name : nom exact
- category : exactement un de la liste ci-dessus
- address : adresse complete
- phone : telephone (ou null)
- email : email (ou null)
- website : URL (ou null)
- opening_hours : horaires (ou null)
- google_rating : note /5 (ou null)
- google_reviews_count : nombre d'avis (ou 0)
- price_level : 1 (bon marche) a 4 (luxe) (ou null)
- services : tableau de strings (ou [])

Reponds UNIQUEMENT avec du JSON valide :
{"establishments": [...]}
Si tu ne trouves rien : {"establishments": []}`;

function buildPromptPass1(localityName, routeName) {
  return `Liste TOUS les hebergements et restaurants pour pelerins a "${localityName}" sur le "${routeName}" (Camino de Santiago).

Cherche specifiquement :
- Hebergements : albergue, hotel, gite, pension, camping (auberges de pelerins, refuges, hostels, chambres d'hotes, casa rural)
- Restaurants et alimentation : restaurant, bar, cafe, boulangerie, epicerie, supermarche

Sois exhaustif -- liste TOUS les etablissements existants, meme les petits.

${JSON_FIELDS}`;
}

function buildPromptPass2(localityName, routeName) {
  return `Quels sont les services, commerces et lieux d'interet a "${localityName}" (${routeName}, Camino de Santiago) ?

Je cherche les noms et adresses exacts de :
- Pharmacies et centres medicaux (pharmacie, medecin, hopital, centro de salud)
- Supermarches et epiceries (supermarche, tienda, minimarket)
- Banques et distributeurs automatiques (banco, cajero, ATM)
- Bureau de poste (correos)
- Laveries automatiques (lavanderia, laverie)
- Office de tourisme
- Taxi et transport de bagages
- Eglises, cathedrales et monasteres
- Musees, monuments et points de vue remarquables

Liste chaque etablissement avec son nom reel et son adresse exacte.

${JSON_FIELDS}`;
}

async function callLLM(prompt, retryCount = 0) {
  if (AI_PROVIDER === 'google') {
    return callGoogle(prompt, retryCount);
  }
  return callOpenRouter(prompt, retryCount);
}

async function callGoogle(prompt, retryCount = 0) {
  const response = await fetch(GOOGLE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemInstruction: {
        parts: [{ text: 'Tu es un assistant specialise dans les chemins de Compostelle. Tu retournes UNIQUEMENT du JSON valide, sans markdown, sans commentaire, sans texte additionnel.' }]
      },
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        responseMimeType: 'application/json',
        temperature: 0.1,
        maxOutputTokens: 8000,
      },
    }),
  });

  if (!response.ok) {
    const errBody = await response.text();
    if (retryCount < MAX_RETRIES && (response.status === 429 || response.status >= 500)) {
      const delay = RATE_LIMIT_MS * Math.pow(2, retryCount);
      console.log(`  [RETRY ${retryCount + 1}/${MAX_RETRIES}] ${response.status} -- ${delay}ms`);
      await sleep(delay);
      return callGoogle(prompt, retryCount + 1);
    }
    throw new Error(`Google AI ${response.status}: ${errBody.substring(0, 200)}`);
  }

  const data = await response.json();
  const content = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
  const usage = {
    prompt_tokens: data.usageMetadata?.promptTokenCount || 0,
    completion_tokens: data.usageMetadata?.candidatesTokenCount || 0,
  };

  return { content, usage };
}

async function callOpenRouter(prompt, retryCount = 0) {
  const response = await fetch(OPENROUTER_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'HTTP-Referer': 'https://cblrs.net',
      'X-Title': 'Caballarius'
    },
    body: JSON.stringify({
      model: OPENROUTER_MODEL,
      messages: [
        {
          role: 'system',
          content: 'Tu es un assistant specialise dans les chemins de Compostelle. Tu retournes UNIQUEMENT du JSON valide, sans markdown, sans commentaire, sans texte additionnel.'
        },
        { role: 'user', content: prompt }
      ],
      response_format: { type: 'json_object' },
      temperature: 0.1,
      max_tokens: 8000,
    }),
  });

  if (!response.ok) {
    const errBody = await response.text();
    if (retryCount < MAX_RETRIES && (response.status === 429 || response.status >= 500)) {
      const delay = RATE_LIMIT_MS * Math.pow(2, retryCount);
      console.log(`  [RETRY ${retryCount + 1}/${MAX_RETRIES}] ${response.status} -- ${delay}ms`);
      await sleep(delay);
      return callOpenRouter(prompt, retryCount + 1);
    }
    throw new Error(`OpenRouter ${response.status}: ${errBody.substring(0, 200)}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || '';
  const usage = data.usage || {};

  return { content, usage };
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

async function runPass(passLabel, prompt) {
  let result;
  try {
    result = await callLLM(prompt);
  } catch (err) {
    console.log(`  [ERREUR ${passLabel}] ${err.message}`);
    return { establishments: [], tokensIn: 0, tokensOut: 0, error: err.message };
  }

  const parsed = extractJSON(result.content);
  if (!parsed || !Array.isArray(parsed.establishments)) {
    console.log(`  [PARSE ERR ${passLabel}] (${result.content.length} chars):`);
    console.log(`  ${result.content.substring(0, 300)}`);
    return { establishments: [], tokensIn: 0, tokensOut: 0, error: 'parse_failed' };
  }

  const tokensIn = result.usage.prompt_tokens || 0;
  const tokensOut = result.usage.completion_tokens || 0;
  console.log(`  ${passLabel} -> ${parsed.establishments.length} etablissements (${tokensIn}+${tokensOut} tokens)`);
  return { establishments: parsed.establishments, tokensIn, tokensOut, error: null };
}

async function processLocality(db, locality, dryRun) {
  const { id, name, lat, lng, route_names } = locality;
  const routeName = route_names || 'Camino de Santiago';

  console.log(`\n[${id}] ${name} (${lat}, ${lng}) -- ${routeName}`);

  if (!dryRun) await setLocalityStatus(db, id, 'in_progress');

  // PASSE 1 -- Hebergement + restauration
  const pass1 = await runPass('PASS1-hebergement', buildPromptPass1(name, routeName));
  await sleep(RATE_LIMIT_MS);

  // PASSE 2 -- Services + patrimoine
  const pass2 = await runPass('PASS2-services', buildPromptPass2(name, routeName));

  if (pass1.error && pass2.error) {
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, `${pass1.error}; ${pass2.error}`);
    }
    return { inserted: 0, skipped: 0, error: `${pass1.error}; ${pass2.error}` };
  }

  // Fusionner
  const allEstablishments = [...pass1.establishments, ...pass2.establishments];
  const totalTokensIn = pass1.tokensIn + pass2.tokensIn;
  const totalTokensOut = pass1.tokensOut + pass2.tokensOut;
  const costUsd = 0; // Kimi K2.5 gratuit sur OpenRouter

  console.log(`  TOTAL: ${allEstablishments.length} etablissements, ~$${costUsd.toFixed(4)}`);

  if (dryRun) {
    let mapped = 0;
    const seen = new Set();
    for (const est of allEstablishments) {
      const cat = mapCategory(est.category);
      const nameKey = (est.name || '').trim().toLowerCase();
      const isDupe = seen.has(nameKey);
      seen.add(nameKey);
      const label = cat
        ? (isDupe ? `~ ${cat} (doublon)` : `+ ${cat}`)
        : `x "${est.category}"`;
      console.log(`    ${label} -- ${est.name}`);
      if (cat && !isDupe) mapped++;
    }
    console.log(`  [DRY RUN] ${mapped} uniques / ${allEstablishments.length} bruts, ~$${costUsd.toFixed(4)}`);
    return { inserted: mapped, skipped: allEstablishments.length - mapped, error: null };
  }

  // Inserer en BDD (ON DUPLICATE KEY UPDATE gere les doublons inter-pass)
  let inserted = 0, skipped = 0;
  for (const est of allEstablishments) {
    const estId = await insertEstablishment(db, id, lat, lng, est);
    if (estId) {
      await insertSource(db, estId, est);
      inserted++;
      console.log(`    + ${est.name} [${mapCategory(est.category)}]`);
    } else {
      skipped++;
    }
  }

  await setLocalityStatus(db, id, 'done');
  await logScrapeJob(db, id, 'done', inserted, costUsd, null);

  console.log(`  -> ${inserted} inseres, ${skipped} ignores, ~$${costUsd.toFixed(4)}`);
  return { inserted, skipped, error: null };
}

async function main() {
  const opts = parseArgs();

  if (!DB_CONFIG.password) {
    console.error('ERREUR: DB_PASS manquant');
    process.exit(1);
  }
  if (AI_PROVIDER === 'google' && !GOOGLE_API_KEY) {
    console.error('ERREUR: GOOGLE_API_KEY manquant');
    process.exit(1);
  }
  if (AI_PROVIDER === 'openrouter' && !OPENROUTER_API_KEY) {
    console.error('ERREUR: OPENROUTER_API_KEY manquant');
    process.exit(1);
  }

  const modelLabel = AI_PROVIDER === 'google' ? 'Gemini 2.5 Flash (Google)' : `${OPENROUTER_MODEL} (OpenRouter)`;
  console.log('='.repeat(60));
  console.log('SKILL 01 -- Scrape establishments (2 passes)');
  console.log(`Provider: ${AI_PROVIDER} | Modele: ${modelLabel} | 2 requetes/localite`);
  console.log(`Batch: ${opts.batch} | Dry run: ${opts.dryRun} | Locality: ${opts.localityId || 'auto'} | Limit: ${opts.limit || 'none'}`);
  console.log('='.repeat(60));

  const db = await mysql.createConnection(DB_CONFIG);

  try {
    const pending = await countPending(db);
    console.log(`Localites pending: ${pending}`);

    let totalInserted = 0, totalSkipped = 0, totalErrors = 0;
    let totalCost = 0;
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
        processed++;

        if (opts.limit && processed >= opts.limit) break;

        await sleep(RATE_LIMIT_MS);
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
    console.log('='.repeat(60));

  } finally {
    await db.end();
  }
}

main().catch(err => {
  console.error('FATAL:', err);
  process.exit(1);
});
