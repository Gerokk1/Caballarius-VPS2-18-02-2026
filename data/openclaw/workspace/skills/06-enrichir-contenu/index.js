#!/usr/bin/env node
// Skill 06 — Enrichir localites via Kimi K2.5 (OpenRouter)
// Usage: DB_PASS=xxx OPENROUTER_API_KEY=xxx node index.js --batch 50
// Restart-safe: reprend la ou il s'est arrete (check locality_content)

const mysql = require('mysql2/promise');

// AI Provider: google (Gemini 2.5 Flash, gratuit) ou openrouter (Kimi K2.5)
const AI_PROVIDER = (process.env.AI_PROVIDER || 'google').toLowerCase();
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY || '';
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const OPENROUTER_MODEL = 'moonshotai/kimi-k2.5';
const GOOGLE_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GOOGLE_API_KEY}`;
const ALWAYS_LANGS = ['fr', 'en'];
const DELAY_MS = 1500; // 1.5s entre chaque appel API
const ERROR_DELAY_MS = 5000;

// CLI args
const args = process.argv.slice(2);
const batchIdx = args.indexOf('--batch');
const BATCH_SIZE = batchIdx !== -1 ? parseInt(args[batchIdx + 1]) : 50;

const DB_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'cblrs_user',
  password: process.env.DB_PASS,
  database: process.env.DB_NAME || 'caballarius_staging',
  charset: 'utf8mb4'
};

const API_KEY = AI_PROVIDER === 'google' ? GOOGLE_API_KEY : OPENROUTER_API_KEY;

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

function buildLangList(countryLanguages) {
  const langSet = new Set(countryLanguages);
  for (const l of ALWAYS_LANGS) langSet.add(l);
  return [...langSet];
}

const LANG_NAMES = {
  fr: 'français', en: 'English', es: 'español', de: 'Deutsch',
  it: 'italiano', pt: 'português', nl: 'Nederlands', pl: 'polski',
  ca: 'català', ga: 'Gaeilge', eu: 'euskara', gl: 'galego',
  hr: 'hrvatski', cs: 'čeština', hu: 'magyar', sl: 'slovenščina',
  sk: 'slovenčina', da: 'dansk', sv: 'svenska', no: 'norsk',
  fi: 'suomi', ro: 'română', bg: 'български', el: 'ελληνικά',
  sr: 'srpski', bs: 'bosanski', mk: 'македонски', sq: 'shqip',
  lt: 'lietuvių', lv: 'latviešu', et: 'eesti', lb: 'Lëtzebuergesch',
  mt: 'Malti', is: 'íslenska', tr: 'Türkçe', uk: 'українська',
  rm: 'rumantsch'
};

function buildPrompt(lang, loc) {
  const langName = LANG_NAMES[lang] || lang;
  return `Tu es un rédacteur expert spécialisé dans les chemins de pèlerinage (Chemins de Saint-Jacques-de-Compostelle, Via Francigena, etc.).

Génère du contenu en ${langName} (code: ${lang}) pour cette localité traversée par un chemin de pèlerinage :

NOM : ${loc.name}
PAYS : ${loc.country_name} (${loc.country_code})
COORDONNÉES : ${loc.lat}, ${loc.lng}
ALTITUDE : ${loc.altitude || 'inconnue'} m
TYPE : ${loc.type}
${loc.routes ? 'ROUTES : ' + loc.routes : ''}
${loc.stages ? 'ÉTAPES : ' + loc.stages : ''}

Réponds UNIQUEMENT en JSON valide (pas de markdown, pas de commentaires) :
{
  "description": "Description 150-250 mots pour pèlerins. Histoire, patrimoine, intérêt.",
  "description_short": "Résumé 1 phrase, max 200 caractères.",
  "highlights": ["Point fort 1", "Point fort 2", "Point fort 3"],
  "seo_title": "Titre SEO max 60 car",
  "seo_description": "Meta description max 150 car",
  "practical_info": "Infos pratiques courtes : accès, services, hébergement."
}`;
}

function repairJSON(raw) {
  // Try direct parse first
  try { return JSON.parse(raw); } catch {}

  // Strip markdown fences if present
  let s = raw.replace(/^```json?\s*/i, '').replace(/```\s*$/, '').trim();
  try { return JSON.parse(s); } catch {}

  // Truncated JSON: close open strings and braces
  // Count open braces/brackets
  let inStr = false, escaped = false;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (escaped) { escaped = false; continue; }
    if (c === '\\') { escaped = true; continue; }
    if (c === '"') inStr = !inStr;
  }
  // If inside a string, close it
  if (inStr) s += '"';
  // Close any open arrays/objects
  const opens = { '{': 0, '[': 0 };
  inStr = false; escaped = false;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (escaped) { escaped = false; continue; }
    if (c === '\\') { escaped = true; continue; }
    if (c === '"') { inStr = !inStr; continue; }
    if (inStr) continue;
    if (c === '{') opens['{']++;
    if (c === '}') opens['{']--;
    if (c === '[') opens['[']++;
    if (c === ']') opens['[']--;
  }
  // Remove trailing comma before closing
  s = s.replace(/,\s*$/, '');
  for (let i = 0; i < opens['[']; i++) s += ']';
  for (let i = 0; i < opens['{']; i++) s += '}';
  try { return JSON.parse(s); } catch {}

  throw new Error(`JSON repair failed (len=${raw.length})`);
}

async function callLLM(prompt, retries = 2) {
  if (AI_PROVIDER === 'google') {
    return callGoogle(prompt, retries);
  }
  return callOpenRouter(prompt, retries);
}

async function callGoogle(prompt, retries = 2) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const res = await fetch(GOOGLE_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            responseMimeType: 'application/json',
            temperature: 0.7,
            maxOutputTokens: 4000,
          },
        })
      });

      if (res.status === 429) {
        const wait = Math.pow(2, attempt + 1) * 5000;
        log(`Rate limited, waiting ${wait / 1000}s (attempt ${attempt + 1}/${retries + 1})`);
        await sleep(wait);
        continue;
      }

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`Google AI ${res.status}: ${err.substring(0, 200)}`);
      }

      const data = await res.json();
      const content = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
      return repairJSON(content);
    } catch (err) {
      if (attempt === retries) throw err;
      log(`Retry ${attempt + 1}: ${err.message}`);
      await sleep(3000);
    }
  }
}

async function callOpenRouter(prompt, retries = 2) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const res = await fetch(OPENROUTER_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
          'HTTP-Referer': 'https://cblrs.net',
          'X-Title': 'Caballarius'
        },
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: [{ role: 'user', content: prompt }],
          response_format: { type: 'json_object' },
          temperature: 0.7,
          max_tokens: 4000
        })
      });

      if (res.status === 429) {
        const wait = Math.pow(2, attempt + 1) * 5000;
        log(`Rate limited, waiting ${wait / 1000}s (attempt ${attempt + 1}/${retries + 1})`);
        await sleep(wait);
        continue;
      }

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`OpenRouter ${res.status}: ${err.substring(0, 200)}`);
      }

      const data = await res.json();
      const content = data.choices[0].message.content;
      return repairJSON(content);
    } catch (err) {
      if (attempt === retries) throw err;
      log(`Retry ${attempt + 1}: ${err.message}`);
      await sleep(3000);
    }
  }
}

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function main() {
  if (!DB_CONFIG.password) { console.error('ERROR: Set DB_PASS'); process.exit(1); }
  if (AI_PROVIDER === 'google' && !GOOGLE_API_KEY) { console.error('ERROR: Set GOOGLE_API_KEY'); process.exit(1); }
  if (AI_PROVIDER === 'openrouter' && !OPENROUTER_API_KEY) { console.error('ERROR: Set OPENROUTER_API_KEY'); process.exit(1); }

  const modelLabel = AI_PROVIDER === 'google' ? 'Gemini 2.5 Flash (Google)' : `${OPENROUTER_MODEL} (OpenRouter)`;
  log(`=== ENRICHMENT START === provider=${AI_PROVIDER} model=${modelLabel} batch=${BATCH_SIZE} delay=${DELAY_MS}ms`);

  const db = await mysql.createConnection(DB_CONFIG);

  // Create table if not exists
  await db.execute(`
    CREATE TABLE IF NOT EXISTS locality_content (
      id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      locality_id INT UNSIGNED NOT NULL,
      lang VARCHAR(5) NOT NULL,
      description TEXT,
      description_short VARCHAR(500),
      highlights JSON,
      seo_title VARCHAR(100),
      seo_description VARCHAR(200),
      practical_info TEXT,
      generated_by VARCHAR(50) NOT NULL DEFAULT 'kimi-k2.5',
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY uq_locality_lang (locality_id, lang),
      FOREIGN KEY (locality_id) REFERENCES localities(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);
  log('Table locality_content ready');

  // Count total remaining
  const [[{ total }]] = await db.execute(`
    SELECT COUNT(DISTINCT l.id) as total
    FROM localities l
    JOIN route_localities rl ON l.id = rl.locality_id
    WHERE l.id NOT IN (SELECT DISTINCT locality_id FROM locality_content)
  `);
  log(`${total} localities to enrich`);

  if (total === 0) {
    log('Nothing to do — all localities already enriched');
    await db.end();
    return;
  }

  let processed = 0, errors = 0, apiCalls = 0;
  let batchNum = 0;

  while (true) {
    const [batch] = await db.execute(`
      SELECT l.id, l.name, l.lat, l.lng, l.type, l.altitude,
             c.code_iso AS country_code, c.name_fr AS country_name, c.languages AS country_languages
      FROM localities l
      JOIN route_localities rl ON l.id = rl.locality_id
      JOIN routes r ON rl.route_id = r.id
      JOIN countries c ON r.country_id = c.id
      WHERE l.id NOT IN (SELECT DISTINCT locality_id FROM locality_content)
      GROUP BY l.id
      ORDER BY c.priority ASC, l.id ASC
      LIMIT ?
    `, [BATCH_SIZE]);

    if (batch.length === 0) break;
    batchNum++;
    log(`--- Batch ${batchNum} (${batch.length} localities) ---`);

    for (const loc of batch) {
      try {
        // Routes through this locality
        const [routes] = await db.execute(`
          SELECT DISTINCT r.name FROM routes r
          JOIN route_localities rl ON r.id = rl.route_id
          WHERE rl.locality_id = ?
        `, [loc.id]);
        loc.routes = routes.map(r => r.name).join(', ');

        // Stages involving this locality
        const [stages] = await db.execute(`
          SELECT ls.name AS sn, le.name AS en, s.km
          FROM stages s
          JOIN localities ls ON s.locality_start_id = ls.id
          JOIN localities le ON s.locality_end_id = le.id
          WHERE s.locality_start_id = ? OR s.locality_end_id = ?
          LIMIT 5
        `, [loc.id, loc.id]);
        loc.stages = stages.map(s => `${s.sn} > ${s.en} (${s.km}km)`).join(' | ');

        // Build language list from country
        let countryLangs;
        try {
          countryLangs = typeof loc.country_languages === 'string'
            ? JSON.parse(loc.country_languages)
            : (Array.isArray(loc.country_languages) ? loc.country_languages : ['en']);
        } catch { countryLangs = ['en']; }
        const langs = buildLangList(countryLangs);

        // Generate content per language
        for (const lang of langs) {
          const prompt = buildPrompt(lang, loc);
          const result = await callLLM(prompt);
          apiCalls++;

          await db.execute(`
            INSERT INTO locality_content
              (locality_id, lang, description, description_short, highlights,
               seo_title, seo_description, practical_info, generated_by)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
              description=VALUES(description), description_short=VALUES(description_short),
              highlights=VALUES(highlights), seo_title=VALUES(seo_title),
              seo_description=VALUES(seo_description), practical_info=VALUES(practical_info),
              generated_by=VALUES(generated_by), updated_at=CURRENT_TIMESTAMP
          `, [
            loc.id, lang,
            result.description || '',
            result.description_short || '',
            JSON.stringify(result.highlights || []),
            (result.seo_title || '').substring(0, 100),
            (result.seo_description || '').substring(0, 200),
            result.practical_info || '',
            AI_PROVIDER === 'google' ? 'gemini-2.5-flash' : OPENROUTER_MODEL
          ]);

          await sleep(DELAY_MS);
        }

        processed++;

        // Log scrape job
        await db.execute(`
          INSERT INTO scrape_jobs
            (job_type, target_type, target_id, status, started_at, completed_at, results_count)
          VALUES ('enrichment', 'locality', ?, 'done', NOW(), NOW(), ?)
        `, [loc.id, langs.length]);

        if (processed % 10 === 0 || processed === 1) {
          const pct = ((processed / total) * 100).toFixed(1);
          log(`Progress: ${processed}/${total} (${pct}%) | ${errors} errors | ${apiCalls} API calls`);
        }
      } catch (err) {
        errors++;
        log(`ERROR loc #${loc.id} "${loc.name}": ${err.message}`);
        await db.execute(`
          INSERT INTO scrape_jobs
            (job_type, target_type, target_id, status, error_log)
          VALUES ('enrichment', 'locality', ?, 'error', ?)
        `, [loc.id, err.message]).catch(() => {});
        await sleep(ERROR_DELAY_MS);
      }
    }
  }

  log(`=== DONE === ${processed} enriched | ${errors} errors | ${apiCalls} API calls`);
  await db.end();
}

main().catch(err => {
  console.error(`FATAL: ${err.message}`);
  process.exit(1);
});
