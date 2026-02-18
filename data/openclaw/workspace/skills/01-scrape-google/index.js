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
