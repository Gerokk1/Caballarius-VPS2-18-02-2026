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
