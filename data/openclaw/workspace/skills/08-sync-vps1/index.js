const MAX_RETRIES = 3;
const RETRY_DELAYS = [1000, 3000, 10000];

async function loadSyncData(db, estabId) { /* TODO: Load enriched data only (NOT sources) */ }
function formatForAPI(data) { /* TODO: Format JSON for VPS1 API */ }

async function pushWithRetry(url, payload, token) {
  /* TODO: POST with retry + backoff
   * Headers: Authorization Bearer, Content-Type application/json
   * Retry on 5xx, fail fast on 4xx */
}

async function syncVPS1(establishmentId, db, vps1ApiUrl) {
  // TODO:
  // 1. Verify scrape_status IN ('enriched','site_generated')
  // 2. loadSyncData -> formatForAPI
  // 3. pushWithRetry (process.env.VPS1_API_TOKEN)
  // 4. UPDATE establishments SET scrape_status='synced'
  // 5. INSERT scrape_jobs (api_sync)
}
module.exports = { syncVPS1 };
