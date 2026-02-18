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
