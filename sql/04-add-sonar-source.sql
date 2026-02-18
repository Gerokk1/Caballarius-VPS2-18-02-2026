-- ============================================================
-- Migration : ajout source_type 'sonar_pro' pour Skill 01
-- A exécuter AVANT de lancer le skill 01-scrape-sonar
-- ============================================================

USE caballarius_staging;

-- Ajouter 'sonar_pro' dans l'ENUM source_type de establishment_sources
ALTER TABLE establishment_sources
  MODIFY COLUMN source_type ENUM('google_places','facebook','instagram','office_tourisme','forum','manual','sonar_pro') NOT NULL;

-- Ajouter 'sonar_pro' dans l'ENUM job_type de scrape_jobs
ALTER TABLE scrape_jobs
  MODIFY COLUMN job_type ENUM('google_places','facebook','instagram','tourisme','forum','enrichment','site_generation','api_sync','sonar_pro') NOT NULL;

-- Vérification
DESCRIBE establishment_sources;
DESCRIBE scrape_jobs;
