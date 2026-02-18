# Skill : Sync vers VPS1
Push donnees enrichies vers API VPS1 (caballarius.eu). POST /api/etablissements.
HTTPS only. Token API. Retry max 3 (backoff exponentiel). Ne jamais envoyer sources brutes.
Only sync scrape_status IN ('enriched','site_generated').
Tables : establishments (->synced), scrape_jobs.
