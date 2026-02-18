-- ============================================================
-- CABALLARIUS STAGING v2 — 14 tables + données pays
-- VPS2 cblrs.net — 2026-02-18
-- DROP existing + CREATE fresh
-- ============================================================

USE caballarius_staging;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS quality_checks, scrape_jobs, pro_sites, establishment_sources, establishment_prices, establishment_content, establishment_photos, establishments, route_localities, stages, localities, routes, regions, countries;
SET FOREIGN_KEY_CHECKS = 1;

-- TABLE 1 : countries
CREATE TABLE countries (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code_iso CHAR(2) NOT NULL UNIQUE,
  name_fr VARCHAR(100) NOT NULL,
  name_es VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  priority INT NOT NULL DEFAULT 99 COMMENT '1=Espagne, 2=France, 3=Portugal, 4=Italie',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO countries (code_iso, name_fr, name_es, name_en, priority) VALUES
('ES', 'Espagne', 'España', 'Spain', 1),
('FR', 'France', 'Francia', 'France', 2),
('PT', 'Portugal', 'Portugal', 'Portugal', 3),
('IT', 'Italie', 'Italia', 'Italy', 4),
('DE', 'Allemagne', 'Alemania', 'Germany', 5),
('CH', 'Suisse', 'Suiza', 'Switzerland', 6),
('BE', 'Belgique', 'Bélgica', 'Belgium', 7),
('PL', 'Pologne', 'Polonia', 'Poland', 8),
('AT', 'Autriche', 'Austria', 'Austria', 9),
('GB', 'Angleterre', 'Inglaterra', 'England', 10);

-- TABLE 2 : regions
CREATE TABLE regions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  country_id INT UNSIGNED NOT NULL,
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(200) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 3 : routes
CREATE TABLE routes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  country_id INT UNSIGNED NOT NULL,
  name VARCHAR(300) NOT NULL,
  slug VARCHAR(300) NOT NULL UNIQUE,
  total_km DECIMAL(8,1) NULL,
  total_stages INT NULL,
  difficulty ENUM('easy','moderate','hard','expert') NOT NULL DEFAULT 'moderate',
  gpx_file VARCHAR(500) NULL,
  status ENUM('active','construction','planned') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 4 : localities (avant stages pour FK)
CREATE TABLE localities (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  region_id INT UNSIGNED NULL,
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(250) NOT NULL,
  lat DECIMAL(10,7) NOT NULL,
  lng DECIMAL(10,7) NOT NULL,
  population INT UNSIGNED NULL,
  altitude INT NULL,
  type ENUM('city','town','village','hamlet','lieu-dit') NOT NULL DEFAULT 'village',
  postal_code VARCHAR(20) NULL,
  scraped_at TIMESTAMP NULL,
  scrape_status ENUM('pending','in_progress','done','error') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE SET NULL,
  INDEX idx_coords (lat, lng),
  INDEX idx_scrape (scrape_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 5 : stages
CREATE TABLE stages (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id INT UNSIGNED NOT NULL,
  stage_number INT NOT NULL,
  name VARCHAR(300) NOT NULL,
  slug VARCHAR(300) NOT NULL,
  locality_start_id INT UNSIGNED NULL,
  locality_end_id INT UNSIGNED NULL,
  km DECIMAL(6,1) NOT NULL,
  d_plus INT NULL,
  d_minus INT NULL,
  estimated_hours DECIMAL(4,1) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (locality_start_id) REFERENCES localities(id) ON DELETE SET NULL,
  FOREIGN KEY (locality_end_id) REFERENCES localities(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 6 : route_localities (pivot)
CREATE TABLE route_localities (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id INT UNSIGNED NOT NULL,
  locality_id INT UNSIGNED NOT NULL,
  km_from_start DECIMAL(7,1) NOT NULL DEFAULT 0,
  order_on_route INT NOT NULL DEFAULT 0,
  UNIQUE KEY uq_route_locality (route_id, locality_id),
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (locality_id) REFERENCES localities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 7 : establishments
CREATE TABLE establishments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  locality_id INT UNSIGNED NOT NULL,
  google_place_id VARCHAR(300) NULL UNIQUE,
  name VARCHAR(300) NOT NULL,
  slug VARCHAR(350) NOT NULL UNIQUE,
  category ENUM('albergue','hotel','gite','pension','camping','restaurant','bar','cafe','boulangerie','epicerie','supermarche','pharmacie','medecin','hopital','podologue','fontaine','laverie','banque','dab','poste','office_tourisme','location_velo','transport_bagages','taxi','eglise','cathedrale','monastere','musee','monument','point_de_vue','artisan','coup_de_pouce') NOT NULL,
  subcategory VARCHAR(100) NULL,
  address VARCHAR(500) NOT NULL,
  lat DECIMAL(10,7) NOT NULL,
  lng DECIMAL(10,7) NOT NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(200) NULL,
  website VARCHAR(500) NULL,
  google_rating DECIMAL(2,1) NULL,
  google_reviews_count INT NOT NULL DEFAULT 0,
  price_level TINYINT UNSIGNED NULL COMMENT '1-4',
  opening_hours JSON NULL,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  is_claimed BOOLEAN NOT NULL DEFAULT FALSE,
  scrape_status ENUM('scraped','enriched','site_generated','synced') NOT NULL DEFAULT 'scraped',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (locality_id) REFERENCES localities(id) ON DELETE CASCADE,
  INDEX idx_coords (lat, lng),
  INDEX idx_category (category),
  INDEX idx_status (scrape_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 8 : establishment_photos
CREATE TABLE establishment_photos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  establishment_id INT UNSIGNED NOT NULL,
  source ENUM('google','facebook','instagram','tourisme','manual') NOT NULL DEFAULT 'google',
  url TEXT NOT NULL,
  local_path VARCHAR(500) NULL,
  alt_text VARCHAR(300) NULL,
  is_hero BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INT NOT NULL DEFAULT 0,
  width INT UNSIGNED NULL,
  height INT UNSIGNED NULL,
  downloaded_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE,
  INDEX idx_estab (establishment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 9 : establishment_content
CREATE TABLE establishment_content (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  establishment_id INT UNSIGNED NOT NULL,
  lang ENUM('fr','es','en') NOT NULL,
  description TEXT NOT NULL,
  description_short VARCHAR(300) NOT NULL,
  highlights JSON NULL COMMENT 'liste de points forts',
  seo_title VARCHAR(70) NOT NULL,
  seo_description VARCHAR(160) NOT NULL,
  profile_chevalier TEXT NULL,
  profile_moine TEXT NULL,
  profile_pelerin TEXT NULL,
  generated_by VARCHAR(50) NOT NULL DEFAULT 'kimi-k2.5',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_estab_lang (establishment_id, lang),
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 10 : establishment_prices
CREATE TABLE establishment_prices (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  establishment_id INT UNSIGNED NOT NULL,
  profile ENUM('chevalier','moine','pelerin') NOT NULL,
  price DECIMAL(8,2) NULL,
  price_label VARCHAR(100) NULL,
  includes TEXT NULL,
  source ENUM('google','scraped','estimated') NOT NULL DEFAULT 'estimated',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_estab_profile (establishment_id, profile),
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 11 : establishment_sources
CREATE TABLE establishment_sources (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  establishment_id INT UNSIGNED NOT NULL,
  source_type ENUM('google_places','facebook','instagram','office_tourisme','forum','manual') NOT NULL,
  source_url TEXT NULL,
  data_json JSON NULL COMMENT 'donnees brutes de la source',
  scraped_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 12 : pro_sites
CREATE TABLE pro_sites (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  establishment_id INT UNSIGNED NOT NULL UNIQUE,
  subdomain VARCHAR(200) NOT NULL UNIQUE,
  template_used VARCHAR(50) NOT NULL DEFAULT 'caballarius-v1',
  html_path VARCHAR(500) NULL,
  deployed_at TIMESTAMP NULL,
  is_live BOOLEAN NOT NULL DEFAULT FALSE,
  is_claimed BOOLEAN NOT NULL DEFAULT FALSE,
  claimed_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 13 : scrape_jobs
CREATE TABLE scrape_jobs (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  job_type ENUM('google_places','facebook','instagram','tourisme','forum','enrichment','site_generation','api_sync') NOT NULL,
  target_type ENUM('locality','establishment','route') NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  status ENUM('pending','running','done','error') NOT NULL DEFAULT 'pending',
  started_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  results_count INT NOT NULL DEFAULT 0,
  error_log TEXT NULL,
  cost_usd DECIMAL(8,4) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_job_type (job_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 14 : quality_checks (NOUVEAU — controle qualite n8n)
CREATE TABLE quality_checks (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  check_type ENUM('missing_data','suspicious_category','duplicate','wrong_location','spam','low_quality_photo','incoherent_price','wrong_language') NOT NULL,
  establishment_id INT UNSIGNED NOT NULL,
  severity ENUM('info','warning','critical') NOT NULL DEFAULT 'warning',
  description TEXT NOT NULL COMMENT 'description du probleme detecte par n8n+Kimi',
  auto_resolved BOOLEAN NOT NULL DEFAULT FALSE,
  resolved_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (establishment_id) REFERENCES establishments(id) ON DELETE CASCADE,
  INDEX idx_type (check_type),
  INDEX idx_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verification
SHOW TABLES;
SELECT COUNT(*) AS table_count FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'caballarius_staging';
SELECT * FROM countries ORDER BY priority;
