const FORUMS = [
  { name:'gronze', url:'https://www.gronze.com', lang:'es' },
  { name:'caminoways', url:'https://www.caminoways.com', lang:'en' },
  { name:'caminoforum', url:'https://www.caminodesantiago.me', lang:'en' },
  { name:'reddit', url:'https://www.reddit.com/r/CaminoDeSantiago', lang:'en' },
  { name:'mundicamino', url:'https://www.mundicamino.com', lang:'es' }
];
const RATE_LIMIT_MS = 3000;

async function searchForum(source, name, locality) { /* TODO: Google "site:{source.url} {name} {locality}" + rate limit */ }
async function extractReviews(pageUrl, source) { /* TODO: Parse reviews, ratings, dates. Filter last 2 years only */ }

async function scrapeForums(establishmentId, db) {
  // TODO:
  // 1. Get establishment + locality
  // 2. For each FORUMS: searchForum -> extractReviews (respect RATE_LIMIT_MS)
  // 3. INSERT establishment_sources for each found source
  // 4. INSERT scrape_jobs
}
module.exports = { scrapeForums };
