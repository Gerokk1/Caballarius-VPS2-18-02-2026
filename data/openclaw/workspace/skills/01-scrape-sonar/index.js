#!/usr/bin/env node
/**
 * SKILL 01-scrape-sonar — Scraping établissements via Kimi K2.5
 *
 * Utilise moonshotai/kimi-k2.5 via OpenRouter (GRATUIT) pour lister
 * les établissements de chaque localité du Camino de Santiago.
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

const RATE_LIMIT_MS = 2000;
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
  'gîte': 'gite', 'gite': 'gite', "chambre d'hôte": 'gite', "chambre d'hotes": 'gite', 'casa rural': 'gite',
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

  // Match via aliases (substring)
  for (const [alias, cat] of Object.entries(CATEGORY_ALIASES)) {
    if (normalized.includes(alias) || alias.includes(normalized)) return cat;
  }

  return null;
}

function extractJSON(text) {
  // Enlever les blocs markdown ```json ... ```
  let cleaned = text.replace(/```json\s*/gi, '').replace(/```\s*/g, '');

  // Chercher le premier { ... } valide
  const start = cleaned.indexOf('{');
  if (start === -1) return null;

  let end = cleaned.lastIndexOf('}');
  if (end === -1 || end <= start) {
    // JSON tronqué — tenter de fermer proprement
    cleaned = cleaned.substring(start);
    // Trouver le dernier objet complet dans le tableau
    const lastComplete = cleaned.lastIndexOf('}');
    if (lastComplete > 0) {
      cleaned = cleaned.substring(0, lastComplete + 1) + ']}';
    } else {
      return null;
    }
  } else {
    cleaned = cleaned.substring(start, end + 1);
  }

  // Fix trailing commas
  cleaned = cleaned.replace(/,\s*([}\]])/g, '$1');

  try {
    return JSON.parse(cleaned);
  } catch (e) {
    // Dernier recours : trouver le dernier }, fermer le tableau
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

// ─── OpenRouter / Kimi K2.5 ─────────────────────────────────────────────────

function buildPrompt(localityName, routeName) {
  return `Recherche TOUS les établissements utiles aux pèlerins à "${localityName}" sur le chemin "${routeName}" (Camino de Santiago).

Catégories à chercher :
- Hébergement : albergue, hotel, gite, pension, camping
- Restauration : restaurant, bar, cafe, boulangerie, epicerie, supermarche
- Santé : pharmacie, medecin, hopital, podologue
- Services : fontaine, laverie, banque, dab, poste, office_tourisme, location_velo, transport_bagages, taxi
- Patrimoine : eglise, cathedrale, monastere, musee, monument, point_de_vue

Pour CHAQUE établissement trouvé, donne :
- name : nom exact de l'établissement
- category : exactement un de [albergue, hotel, gite, pension, camping, restaurant, bar, cafe, boulangerie, epicerie, supermarche, pharmacie, medecin, hopital, podologue, fontaine, laverie, banque, dab, poste, office_tourisme, location_velo, transport_bagages, taxi, eglise, cathedrale, monastere, musee, monument, point_de_vue]
- address : adresse complète
- phone : numéro de téléphone (ou null)
- email : adresse email (ou null)
- website : URL du site web (ou null)
- opening_hours : description des horaires (ou null)
- google_rating : note Google sur 5 (nombre ou null)
- google_reviews_count : nombre d'avis Google (nombre ou 0)
- price_level : de 1 (bon marché) à 4 (luxe) (ou null)
- services : liste de services notables (tableau de strings, ou [])

Réponds UNIQUEMENT avec du JSON valide, sans aucun texte avant ou après :
{"establishments": [...]}

Si la localité n'existe pas ou si tu ne trouves rien, réponds : {"establishments": []}`;
}

async function callSonarPro(prompt, retryCount = 0) {
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
          content: 'Tu es un assistant spécialisé dans les chemins de Compostelle. Tu retournes UNIQUEMENT du JSON valide, sans markdown, sans commentaire, sans texte additionnel.'
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
      const delay = RATE_LIMIT_MS * Math.pow(2, retryCount);
      console.log(`  [RETRY ${retryCount + 1}/${MAX_RETRIES}] ${response.status} — attente ${delay}ms`);
      await sleep(delay);
      return callSonarPro(prompt, retryCount + 1);
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

    // insertId = new row ID or existing row ID (via LAST_INSERT_ID trick)
    return result.insertId || null;
  } catch (err) {
    // Vrai doublon (même nom + même localité) = SKIP, pas de fallback
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

  console.log(`\n[${id}] ${name} (${lat}, ${lng}) — ${routeName}`);

  // 1. Marquer in_progress
  if (!dryRun) await setLocalityStatus(db, id, 'in_progress');

  // 2. Appeler Kimi K2.5
  const prompt = buildPrompt(name, routeName);
  let result;
  try {
    result = await callSonarPro(prompt);
  } catch (err) {
    console.log(`  [ERREUR API] ${err.message}`);
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, err.message);
    }
    return { inserted: 0, skipped: 0, error: err.message };
  }

  // 3. Parser la réponse JSON
  const parsed = extractJSON(result.content);
  if (!parsed || !Array.isArray(parsed.establishments)) {
    console.log(`  [ERREUR PARSE] Réponse non-JSON (${result.content.length} chars):`);
    console.log(`  ${result.content.substring(0, 500)}`);
    if (!dryRun) {
      await setLocalityStatus(db, id, 'error');
      await logScrapeJob(db, id, 'error', 0, 0, 'JSON parse failed');
    }
    return { inserted: 0, skipped: 0, error: 'parse_failed' };
  }

  const establishments = parsed.establishments;
  console.log(`  Kimi K2.5 → ${establishments.length} établissements trouvés`);

  // 4. Coût estimé
  const tokensIn = result.usage.prompt_tokens || 0;
  const tokensOut = result.usage.completion_tokens || 0;
  const costUsd = 0; // Kimi K2.5 = GRATUIT sur OpenRouter

  if (dryRun) {
    let mapped = 0;
    for (const est of establishments) {
      const cat = mapCategory(est.category);
      const label = cat ? `✓ ${cat}` : `✗ "${est.category}"`;
      console.log(`    ${label} — ${est.name}`);
      if (cat) mapped++;
    }
    console.log(`  [DRY RUN] ${mapped}/${establishments.length} catégorisés, ~$${costUsd.toFixed(4)}`);
    return { inserted: mapped, skipped: establishments.length - mapped, error: null };
  }

  // 5. Insérer en BDD
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

  // 6. Mettre à jour le statut
  await setLocalityStatus(db, id, 'done');
  await logScrapeJob(db, id, 'done', inserted, costUsd, null);

  console.log(`  → ${inserted} insérés, ${skipped} ignorés, ~$${costUsd.toFixed(4)}`);
  return { inserted, skipped, error: null };
}

async function main() {
  const opts = parseArgs();

  // Validations
  if (!DB_CONFIG.password) {
    console.error('ERREUR: DB_PASS non défini. Utiliser: export DB_PASS="..."');
    process.exit(1);
  }
  if (!OPENROUTER_API_KEY) {
    console.error('ERREUR: OPENROUTER_API_KEY non défini. Utiliser: export OPENROUTER_API_KEY="sk-or-..."');
    process.exit(1);
  }

  console.log('='.repeat(60));
  console.log('SKILL 01 — Scrape Kimi K2.5');
  console.log(`Modèle: ${MODEL}`);
  console.log(`Batch: ${opts.batch} | Dry run: ${opts.dryRun} | Locality: ${opts.localityId || 'auto'} | Limit: ${opts.limit || 'none'}`);
  console.log('='.repeat(60));

  const db = await mysql.createConnection(DB_CONFIG);

  try {
    const pending = await countPending(db);
    console.log(`Localités pending: ${pending}`);

    let totalInserted = 0, totalSkipped = 0, totalErrors = 0;
    let processed = 0;

    while (true) {
      const batchSize = opts.limit
        ? Math.min(opts.batch, opts.limit - processed)
        : opts.batch;

      if (batchSize <= 0) break;

      const batch = await getNextBatch(db, batchSize, opts.localityId);
      if (batch.length === 0) {
        console.log('\nAucune localité pending restante.');
        break;
      }

      for (const locality of batch) {
        const result = await processLocality(db, locality, opts.dryRun);
        totalInserted += result.inserted;
        totalSkipped += result.skipped;
        if (result.error) totalErrors++;
        processed++;

        if (opts.limit && processed >= opts.limit) break;

        // Rate limit entre les requêtes
        await sleep(RATE_LIMIT_MS);
      }

      // Si locality-id spécifique, ne boucler qu'une fois
      if (opts.localityId) break;
      if (opts.limit && processed >= opts.limit) break;
    }

    console.log('\n' + '='.repeat(60));
    console.log('RÉSULTAT FINAL');
    console.log(`  Localités traitées: ${processed}`);
    console.log(`  Établissements insérés: ${totalInserted}`);
    console.log(`  Établissements ignorés: ${totalSkipped}`);
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
