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
