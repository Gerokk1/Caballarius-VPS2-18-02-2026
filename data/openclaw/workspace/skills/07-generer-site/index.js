const SITES_DIR = '/data/sites';

async function loadAllData(db, estabId) { /* TODO: Load establishment+content+photos+prices+locality+routes */ }
function generateSlug(name) { /* TODO: "Bar El Toro" -> "bar-el-toro", check uniqueness */ }

function renderHTML(data) {
  /* TODO: Generate complete HTML page with caballarius-v1 template
   * Colors: #0a1628 (bg), #1a2a4a (sections), #D4AF37 (gold accent)
   * Fonts: Cinzel (headings), EB Garamond (body)
   * Sections: hero, description, highlights, 3 profile cards, services, Leaflet map, reviews, contact
   * Meta: SEO title, description, OG tags, structured data (Schema.org LocalBusiness)
   * Mobile-first responsive */
}

async function deploy(subdomain, html) {
  /* TODO: mkdir -p /data/sites/{subdomain}/public/ && write index.html && chown www-data */
}

async function genererSite(establishmentId, db) {
  // TODO:
  // 1. loadAllData (must be scrape_status='enriched')
  // 2. generateSlug -> check pro_sites.subdomain uniqueness
  // 3. renderHTML
  // 4. deploy to /data/sites/
  // 5. INSERT/UPDATE pro_sites (subdomain, html_path, deployed_at, is_live=true)
  // 6. UPDATE establishments SET scrape_status='site_generated'
  // 7. INSERT scrape_jobs (site_generation)
  // 8. return { subdomain, url: `https://${subdomain}.cblrs.net` }
}
module.exports = { genererSite };
