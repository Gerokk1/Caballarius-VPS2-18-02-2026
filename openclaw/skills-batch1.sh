#!/bin/bash
set -e
SD="/data/openclaw/workspace/skills"
rm -rf "$SD"
mkdir -p "$SD"/{01-scrape-google,02-scrape-facebook,03-scrape-instagram,04-scrape-tourisme,05-scrape-forums,06-enrichir-contenu,07-generer-site,08-sync-vps1}

cat > "$SD/01-scrape-google/SKILL.md" << 'EOF'
# Skill : Scrape Google Places
Scraper Google Places API pour une localite (rayon 1km).
Categories : lodging, restaurant, bar, cafe, pharmacy, hospital, supermarket, atm, tourist_attraction, bakery, bank, post_office, laundry, bicycle_store, taxi_stand, church, museum.
Deduplication via google_place_id. Max 10 photos/lieu.
Tables : establishments, establishment_photos, establishment_sources, scrape_jobs, localities.
EOF

cat > "$SD/01-scrape-google/index.js" << 'EOF'
const GOOGLE_CATEGORIES = ['lodging','restaurant','bar','cafe','pharmacy','hospital','supermarket','atm','tourist_attraction','bakery','bank','post_office','laundry','bicycle_store','taxi_stand','church','museum'];
const CATEGORY_MAP = {lodging:'hotel',restaurant:'restaurant',bar:'bar',cafe:'cafe',pharmacy:'pharmacie',hospital:'hopital',supermarket:'supermarche',atm:'dab',tourist_attraction:'monument',bakery:'boulangerie',bank:'banque',post_office:'poste',laundry:'laverie',bicycle_store:'location_velo',taxi_stand:'taxi',church:'eglise',museum:'musee'};
const SEARCH_RADIUS = 1000;

async function getLocality(db, id) { /* TODO: SELECT id,name,lat,lng FROM localities WHERE id=? */ }
async function nearbySearch(apiKey, lat, lng, cat) { /* TODO: Google Nearby Search + pagination next_page_token */ }
async function placeDetails(apiKey, placeId) { /* TODO: Google Place Details (name,address,phone,website,hours,photos,rating,reviews,price_level,geometry) */ }
function slugify(name) { /* TODO: "Bar El Toro" -> "bar-el-toro" */ }
function mapCategory(types) { /* TODO: Google types -> Caballarius category */ }
async function insertEstablishment(db, localityId, data) { /* TODO: INSERT INTO establishments ON DUPLICATE KEY UPDATE (google_place_id) */ }
async function insertPhotos(db, estabId, photos) { /* TODO: INSERT establishment_photos, max 10, first=is_hero */ }
async function insertSource(db, estabId, raw) { /* TODO: INSERT establishment_sources source_type=google_places */ }

async function scrapeGooglePlaces(localityId, db) {
  const apiKey = process.env.GOOGLE_PLACES_API_KEY;
  let total = 0, cost = 0;
  // TODO:
  // 1. getLocality -> UPDATE scrape_status='in_progress'
  // 2. for each GOOGLE_CATEGORIES: nearbySearch -> dedup -> placeDetails -> insert
  // 3. UPDATE scrape_status='done', scraped_at=NOW()
  // 4. INSERT scrape_jobs (google_places, locality, done, total, cost)
  return { inserted: total, cost };
}
module.exports = { scrapeGooglePlaces };
EOF

cat > "$SD/02-scrape-facebook/SKILL.md" << 'EOF'
# Skill : Scrape Facebook Pages
Cherche pages Facebook des etablissements scrapes. Photos, avis, horaires.
Methode : Graph API ou browser tool. Rate limits respectes.
Tables : establishment_photos (source=facebook), establishment_sources, scrape_jobs.
EOF

cat > "$SD/02-scrape-facebook/index.js" << 'EOF'
async function getEstablishment(db, id) { /* TODO: SELECT e.*, l.name locality_name FROM establishments e JOIN localities l ON e.locality_id=l.id WHERE e.id=? */ }
async function findFacebookPage(name, locality) { /* TODO: Google "site:facebook.com {name} {locality}" */ }
async function scrapePageData(url) { /* TODO: Browser tool or Graph API -> { photos, reviews, posts, hours } */ }

async function scrapeFacebook(establishmentId, db) {
  // TODO:
  // 1. getEstablishment
  // 2. findFacebookPage -> if not found return { found: false }
  // 3. scrapePageData
  // 4. INSERT establishment_photos (source=facebook)
  // 5. INSERT establishment_sources (source_type=facebook)
  // 6. INSERT scrape_jobs
  return { found: true };
}
module.exports = { scrapeFacebook };
EOF

cat > "$SD/03-scrape-instagram/SKILL.md" << 'EOF'
# Skill : Scrape Instagram Photos
Photos geolocalisees + hashtags (#caminodesantiago #caminofrances #[ville]).
Top 10 par qualite/likes. Browser tool obligatoire. URLs only (pas download).
Tables : establishment_photos (source=instagram), establishment_sources, scrape_jobs.
EOF

cat > "$SD/03-scrape-instagram/index.js" << 'EOF'
async function searchByLocation(lat, lng, radius) { /* TODO: Browser tool Instagram geoloc search */ }
async function searchByHashtag(tag) { /* TODO: #caminofrances #caminodesantiago #[ville] */ }
async function selectBestPhotos(posts, max) { /* TODO: Score by likes, comments, quality */ }
async function matchToEstablishment(db, localityId, post) { /* TODO: Match via GPS proximity or caption mention */ }

async function scrapeInstagram(localityId, db) {
  // TODO:
  // 1. Get locality coords + name
  // 2. searchByLocation + searchByHashtag
  // 3. Match to existing establishments
  // 4. selectBestPhotos (max 10 per establishment)
  // 5. INSERT establishment_photos + sources + scrape_jobs
}
module.exports = { scrapeInstagram };
EOF

cat > "$SD/04-scrape-tourisme/SKILL.md" << 'EOF'
# Skill : Scrape Offices du Tourisme
Sites offices tourisme, mairies, portails regionaux, Wikipedia.
Infos culturelles, patrimoine, evenements, histoire.
Tables : establishment_content, establishment_sources, scrape_jobs.
EOF

cat > "$SD/04-scrape-tourisme/index.js" << 'EOF'
async function findTourismSites(locality, region, country) { /* TODO: Google "office tourisme {ville}" + Wikipedia */ }
async function scrapeTourismPage(url) { /* TODO: Fetch+parse or browser tool -> description, patrimoine, histoire */ }
async function extractCulturalContext(pages) { /* TODO: Synthesize cultural context from multiple sources */ }

async function scrapeTourisme(localityId, db) {
  // TODO:
  // 1. Get locality + region + country
  // 2. findTourismSites -> scrapeTourismPage each
  // 3. extractCulturalContext
  // 4. INSERT establishment_sources + scrape_jobs
}
module.exports = { scrapeTourisme };
EOF

echo "BATCH 1 DONE (skills 01-04)"
