/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: caballarius_staging
-- ------------------------------------------------------
-- Server version	10.11.14-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code_iso` char(2) NOT NULL,
  `name_fr` varchar(100) NOT NULL,
  `name_es` varchar(100) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `languages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '["en"]' COMMENT 'Codes ISO 639-1 des langues du pays' CHECK (json_valid(`languages`)),
  `priority` int(11) NOT NULL DEFAULT 99 COMMENT '1=Espagne, 2=France, 3=Portugal, 4=Italie',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_iso` (`code_iso`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES
(1,'ES','Espagne','EspaÃ±a','Spain','[\"es\"]',1,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(2,'FR','France','Francia','France','[\"fr\"]',2,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(3,'PT','Portugal','Portugal','Portugal','[\"pt\"]',3,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(4,'IT','Italie','Italia','Italy','[\"it\"]',4,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(5,'DE','Allemagne','Alemania','Germany','[\"de\"]',5,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(6,'CH','Suisse','Suiza','Switzerland','[\"de\",\"fr\",\"it\",\"rm\"]',6,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(7,'BE','Belgique','BÃ©lgica','Belgium','[\"fr\",\"nl\",\"de\"]',7,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(8,'PL','Pologne','Polonia','Poland','[\"pl\"]',8,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(9,'AT','Autriche','Austria','Austria','[\"de\"]',9,1,'2026-02-18 17:18:07','2026-02-18 17:42:23'),
(10,'GB','Angleterre','Inglaterra','England','[\"en\"]',10,1,'2026-02-18 17:18:07','2026-02-18 17:18:07'),
(11,'NL','Pays-Bas','Paises Bajos','Netherlands','[\"nl\"]',11,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(12,'IE','Irlande','Irlanda','Ireland','[\"en\",\"ga\"]',16,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(13,'HR','Croatie','Croacia','Croatia','[\"hr\"]',17,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(14,'CZ','Republique Tcheque','Republica Checa','Czech Republic','[\"cs\"]',18,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(15,'HU','Hongrie','Hungria','Hungary','[\"hu\"]',19,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(16,'SI','Slovenie','Eslovenia','Slovenia','[\"sl\"]',20,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(17,'SK','Slovaquie','Eslovaquia','Slovakia','[\"sk\"]',21,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(18,'DK','Danemark','Dinamarca','Denmark','[\"da\"]',15,1,'2026-02-18 17:38:29','2026-02-18 17:42:23'),
(19,'SE','Suede','Suecia','Sweden','[\"sv\"]',12,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(20,'NO','Norvege','Noruega','Norway','[\"no\",\"nb\",\"nn\"]',13,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(21,'FI','Finlande','Finlandia','Finland','[\"fi\",\"sv\"]',14,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(22,'RO','Roumanie','Rumania','Romania','[\"ro\"]',22,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(23,'BG','Bulgarie','Bulgaria','Bulgaria','[\"bg\"]',23,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(24,'GR','Grece','Grecia','Greece','[\"el\"]',24,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(25,'RS','Serbie','Serbia','Serbia','[\"sr\"]',25,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(26,'BA','Bosnie-Herzegovine','Bosnia-Herzegovina','Bosnia Herzegovina','[\"bs\",\"hr\",\"sr\"]',26,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(27,'ME','Montenegro','Montenegro','Montenegro','[\"cnr\"]',27,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(28,'MK','Macedoine du Nord','Macedonia del Norte','North Macedonia','[\"mk\"]',28,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(29,'AL','Albanie','Albania','Albania','[\"sq\"]',29,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(30,'LT','Lituanie','Lituania','Lithuania','[\"lt\"]',30,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(31,'LV','Lettonie','Letonia','Latvia','[\"lv\"]',31,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(32,'EE','Estonie','Estonia','Estonia','[\"et\"]',32,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(33,'LU','Luxembourg','Luxemburgo','Luxembourg','[\"fr\",\"de\",\"lb\"]',33,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(34,'MT','Malte','Malta','Malta','[\"mt\",\"en\"]',34,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(35,'CY','Chypre','Chipre','Cyprus','[\"el\",\"tr\"]',35,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(36,'IS','Islande','Islandia','Iceland','[\"is\"]',36,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(37,'TR','Turquie','Turquia','Turkey','[\"tr\"]',37,1,'2026-02-18 17:42:23','2026-02-18 17:42:23'),
(38,'UA','Ukraine','Ucrania','Ukraine','[\"uk\"]',38,1,'2026-02-18 17:42:23','2026-02-18 17:42:23');
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establishment_content`
--

DROP TABLE IF EXISTS `establishment_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `establishment_content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `establishment_id` int(10) unsigned NOT NULL,
  `lang` varchar(5) NOT NULL COMMENT 'Code ISO 639-1',
  `description` text NOT NULL,
  `description_short` varchar(300) NOT NULL,
  `highlights` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'liste de points forts' CHECK (json_valid(`highlights`)),
  `seo_title` varchar(70) NOT NULL,
  `seo_description` varchar(160) NOT NULL,
  `profile_chevalier` text DEFAULT NULL,
  `profile_moine` text DEFAULT NULL,
  `profile_pelerin` text DEFAULT NULL,
  `generated_by` varchar(50) NOT NULL DEFAULT 'kimi-k2.5',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_estab_lang` (`establishment_id`,`lang`),
  CONSTRAINT `establishment_content_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establishment_content`
--

LOCK TABLES `establishment_content` WRITE;
/*!40000 ALTER TABLE `establishment_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `establishment_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establishment_photos`
--

DROP TABLE IF EXISTS `establishment_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `establishment_photos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `establishment_id` int(10) unsigned NOT NULL,
  `source` enum('google','facebook','instagram','tourisme','manual') NOT NULL DEFAULT 'google',
  `url` text NOT NULL,
  `local_path` varchar(500) DEFAULT NULL,
  `alt_text` varchar(300) DEFAULT NULL,
  `is_hero` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` int(11) NOT NULL DEFAULT 0,
  `width` int(10) unsigned DEFAULT NULL,
  `height` int(10) unsigned DEFAULT NULL,
  `downloaded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_estab` (`establishment_id`),
  CONSTRAINT `establishment_photos_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establishment_photos`
--

LOCK TABLES `establishment_photos` WRITE;
/*!40000 ALTER TABLE `establishment_photos` DISABLE KEYS */;
/*!40000 ALTER TABLE `establishment_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establishment_prices`
--

DROP TABLE IF EXISTS `establishment_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `establishment_prices` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `establishment_id` int(10) unsigned NOT NULL,
  `profile` enum('chevalier','moine','pelerin') NOT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `price_label` varchar(100) DEFAULT NULL,
  `includes` text DEFAULT NULL,
  `source` enum('google','scraped','estimated') NOT NULL DEFAULT 'estimated',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_estab_profile` (`establishment_id`,`profile`),
  CONSTRAINT `establishment_prices_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establishment_prices`
--

LOCK TABLES `establishment_prices` WRITE;
/*!40000 ALTER TABLE `establishment_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `establishment_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establishment_sources`
--

DROP TABLE IF EXISTS `establishment_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `establishment_sources` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `establishment_id` int(10) unsigned NOT NULL,
  `source_type` enum('google_places','facebook','instagram','office_tourisme','forum','manual') NOT NULL,
  `source_url` text DEFAULT NULL,
  `data_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'donnees brutes de la source' CHECK (json_valid(`data_json`)),
  `scraped_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `establishment_id` (`establishment_id`),
  CONSTRAINT `establishment_sources_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establishment_sources`
--

LOCK TABLES `establishment_sources` WRITE;
/*!40000 ALTER TABLE `establishment_sources` DISABLE KEYS */;
/*!40000 ALTER TABLE `establishment_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establishments`
--

DROP TABLE IF EXISTS `establishments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `establishments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `locality_id` int(10) unsigned NOT NULL,
  `google_place_id` varchar(300) DEFAULT NULL,
  `name` varchar(300) NOT NULL,
  `slug` varchar(350) NOT NULL,
  `category` enum('albergue','hotel','gite','pension','camping','restaurant','bar','cafe','boulangerie','epicerie','supermarche','pharmacie','medecin','hopital','podologue','fontaine','laverie','banque','dab','poste','office_tourisme','location_velo','transport_bagages','taxi','eglise','cathedrale','monastere','musee','monument','point_de_vue','artisan','coup_de_pouce') NOT NULL,
  `subcategory` varchar(100) DEFAULT NULL,
  `address` varchar(500) NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `website` varchar(500) DEFAULT NULL,
  `google_rating` decimal(2,1) DEFAULT NULL,
  `google_reviews_count` int(11) NOT NULL DEFAULT 0,
  `price_level` tinyint(3) unsigned DEFAULT NULL COMMENT '1-4',
  `opening_hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`opening_hours`)),
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_claimed` tinyint(1) NOT NULL DEFAULT 0,
  `scrape_status` enum('scraped','enriched','site_generated','synced') NOT NULL DEFAULT 'scraped',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `google_place_id` (`google_place_id`),
  KEY `locality_id` (`locality_id`),
  KEY `idx_coords` (`lat`,`lng`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`scrape_status`),
  CONSTRAINT `establishments_ibfk_1` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establishments`
--

LOCK TABLES `establishments` WRITE;
/*!40000 ALTER TABLE `establishments` DISABLE KEYS */;
/*!40000 ALTER TABLE `establishments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `localities`
--

DROP TABLE IF EXISTS `localities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `localities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `region_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `slug` varchar(250) NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `population` int(10) unsigned DEFAULT NULL,
  `altitude` int(11) DEFAULT NULL,
  `type` enum('city','town','village','hamlet','lieu-dit') NOT NULL DEFAULT 'village',
  `postal_code` varchar(20) DEFAULT NULL,
  `scraped_at` timestamp NULL DEFAULT NULL,
  `scrape_status` enum('pending','in_progress','done','error') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `region_id` (`region_id`),
  KEY `idx_coords` (`lat`,`lng`),
  KEY `idx_scrape` (`scrape_status`),
  CONSTRAINT `localities_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `localities`
--

LOCK TABLES `localities` WRITE;
/*!40000 ALTER TABLE `localities` DISABLE KEYS */;
/*!40000 ALTER TABLE `localities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pro_sites`
--

DROP TABLE IF EXISTS `pro_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pro_sites` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `establishment_id` int(10) unsigned NOT NULL,
  `subdomain` varchar(200) NOT NULL,
  `template_used` varchar(50) NOT NULL DEFAULT 'caballarius-v1',
  `html_path` varchar(500) DEFAULT NULL,
  `deployed_at` timestamp NULL DEFAULT NULL,
  `is_live` tinyint(1) NOT NULL DEFAULT 0,
  `is_claimed` tinyint(1) NOT NULL DEFAULT 0,
  `claimed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `establishment_id` (`establishment_id`),
  UNIQUE KEY `subdomain` (`subdomain`),
  CONSTRAINT `pro_sites_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pro_sites`
--

LOCK TABLES `pro_sites` WRITE;
/*!40000 ALTER TABLE `pro_sites` DISABLE KEYS */;
/*!40000 ALTER TABLE `pro_sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quality_checks`
--

DROP TABLE IF EXISTS `quality_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quality_checks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `check_type` enum('missing_data','suspicious_category','duplicate','wrong_location','spam','low_quality_photo','incoherent_price','wrong_language') NOT NULL,
  `establishment_id` int(10) unsigned NOT NULL,
  `severity` enum('info','warning','critical') NOT NULL DEFAULT 'warning',
  `description` text NOT NULL COMMENT 'description du probleme detecte par n8n+Kimi',
  `auto_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `establishment_id` (`establishment_id`),
  KEY `idx_type` (`check_type`),
  KEY `idx_severity` (`severity`),
  CONSTRAINT `quality_checks_ibfk_1` FOREIGN KEY (`establishment_id`) REFERENCES `establishments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quality_checks`
--

LOCK TABLES `quality_checks` WRITE;
/*!40000 ALTER TABLE `quality_checks` DISABLE KEYS */;
/*!40000 ALTER TABLE `quality_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` int(10) unsigned NOT NULL,
  `name` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `regions_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regions`
--

LOCK TABLES `regions` WRITE;
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route_localities`
--

DROP TABLE IF EXISTS `route_localities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `route_localities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int(10) unsigned NOT NULL,
  `locality_id` int(10) unsigned NOT NULL,
  `km_from_start` decimal(7,1) NOT NULL DEFAULT 0.0,
  `order_on_route` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_locality` (`route_id`,`locality_id`),
  KEY `locality_id` (`locality_id`),
  CONSTRAINT `route_localities_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `route_localities_ibfk_2` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_localities`
--

LOCK TABLES `route_localities` WRITE;
/*!40000 ALTER TABLE `route_localities` DISABLE KEYS */;
/*!40000 ALTER TABLE `route_localities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `routes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` int(10) unsigned NOT NULL,
  `name` varchar(300) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `total_km` decimal(8,1) DEFAULT NULL,
  `total_stages` int(11) DEFAULT NULL,
  `difficulty` enum('easy','moderate','hard','expert') NOT NULL DEFAULT 'moderate',
  `gpx_file` varchar(500) DEFAULT NULL,
  `status` enum('active','construction','planned') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=306 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES
(1,1,'Camino Frances por Navarra','es01a',137.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(2,1,'Camino Frances por Aragon','es01b',274.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(3,1,'Camino Frances','es01c',970.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(4,1,'Camino Portugues desde Tui','es02a',137.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(5,1,'Camino del Norte','es03a',1038.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(6,1,'Camino Mozarabe - Via de la Plata','es04a',1148.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(7,1,'Via de la Plata de Zamora a Astorga','es04b',190.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES04b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(8,1,'Camino Primitivo','es05a',291.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(9,1,'Camino Ingles','es06a',147.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(10,1,'Camino de Fisterra y Muxia','es07a',143.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(11,1,'Camino de Levante','es08a',843.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(12,1,'Camino del Sureste','es09a',889.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(13,1,'Camino Mozarabe de Almeria','es10a',205.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(14,1,'Camino Mozarabe de Cordoba','es10b',308.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(15,1,'Camino Mozarabe de Granada','es10c',108.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(16,1,'Camino Mozarabe de Jaen','es10d',47.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10d.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(17,1,'Camino Mozarabe de Malaga','es10e',240.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10e.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(18,1,'Camino Olvidado','es11a',703.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(19,1,'Camino de Madrid','es12a',451.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(20,1,'Camino de la Lana','es13a',770.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(21,1,'Camino Santiago del Ebro','es14a',459.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES14a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(22,1,'Ruta del Argar','es15a',411.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES15a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(23,1,'Camino de Invierno','es17a',217.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES17a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(24,1,'Camino Portugues de la Costa - A Guarda-Baiona-Vigo-Redondela','es18a',79.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES18a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(25,1,'Camino Argar del Sureste de Almeria','es19a',230.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES19a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(26,1,'Camino del Interior Vasco Riojano','es20a',209.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES20a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(27,1,'Camino Castellano Aragones en Soria','es21a',255.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES21a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(28,1,'Camino de Santiago de Barcelona a San Juan de la Pena','es22a',408.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES22a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(29,1,'Camino de Santiago de Castellon - Bajo Aragon','es23a',305.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES23a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(30,1,'Cami Gironi de Sant Jaume','es24a',278.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(31,1,'Cami de Sant Jaume del Llobregat','es24b',59.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(32,1,'Cami Catala de Sant Jaume','es24c',528.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(33,1,'Camino de Sagunto','es25a',439.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES25a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(34,1,'Camino de El Salvador','es28a',150.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES28a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(35,1,'Ruta Vadiniense','es29a',212.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES29a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(36,1,'Camino del Besaya - Calzada romana','es30a',252.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES30a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(37,1,'Camino Via de Bayona','es32a',301.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES32a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(38,1,'Camino de Baztan','es33a',115.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES33a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(39,1,'Camino Manchego de Ciudad Real a Toledo','es34a',167.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES34a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(40,1,'Camino Sur de Huelva','es35a',191.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES35a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(41,1,'Via Augusta desde Cadiz','es36a',181.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES36a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(42,1,'Camino de la Lana Valencia-Requena','es37a',224.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES37a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(43,1,'Camino del Alba','es38a',166.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES38a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(44,1,'Camino del Sureste desde Benidorm','es39a',102.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES39a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(45,1,'Camino Variante Espiritual','es40b',68.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES40b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(46,1,'Camino del Sureste - Ramal Sur','es42a',108.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES42a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(47,1,'Camino de la Santa Cruz','es43a',77.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES43a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(48,1,'Camino del Sureste - Cartagena-Murcia','es44a',240.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES44a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(49,1,'Camino Lebaniego','es45a',71.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES45a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(50,1,'Camino de Santiago de Gran Canaria','es46a',94.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES46a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(51,1,'Camino de las Asturias','es48a',577.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES48a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(52,1,'Camino Mendocino a Santiago','es49a',97.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES49a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(53,2,'Voie Turonensis tranche Chartres','fr01a',321.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(54,2,'Voie Turonensis tranche Orleans','fr01b',274.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(55,2,'Voie Turonensis Paris','fr01c',786.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(56,2,'Via Lemovicensis Nord par Bourges','fr02a',270.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(57,2,'Via Lemovicensis Sud par Nevers','fr02b',349.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(58,2,'Via Lemovicensis Vezelay','fr02c',624.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(59,2,'Via Podiensis Le Puy en Velay','fr03a',763.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(60,2,'Via Tolosana Arles','fr04a',789.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(61,2,'Voie des Piemonts','fr05a',671.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(62,2,'Chemin Mont Saint Michel','fr06a',413.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(63,2,'Chemin Saint Michel - Royan','fr07a',329.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(64,2,'Via Gallia Belgica - Maubeuge-Saint Quentin','fr08a',101.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(65,2,'Chemin Tournai - Paris','fr09a',309.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(66,2,'Chemin Dieppe - Mont Saint Michel','fr10a',83.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(67,2,'Chemin Reims - Paris','fr11a',211.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(68,2,'Chemin Voie Littorale - Royan - Irun','fr12a',412.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(69,2,'Le Chemin Cotie - Lesseron - Bayonne','fr13a',91.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(70,2,'Chemin Rocroi - Vezelay','fr14a',536.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR14a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(71,2,'Chemin Campaniensis','fr15a',397.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR15a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(72,2,'Chemin Gy - Vezelay','fr16a',210.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR16a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(73,2,'Chemin Vezelay - Le Puy','fr17a',439.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR17a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(74,2,'Chemin Trier - Le Puy','fr18a',848.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR18a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(75,2,'Chemin Horbach - Metz','fr19a',217.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR19a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(76,2,'Chemin Bad Bergzabern - Beaune','fr20a',538.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR20a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(77,2,'La Voie Senonensis de Paris - Vezelay','fr21a',252.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR21a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(78,2,'Chemin Firmi - Toulouse','fr22a',202.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR22a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(79,2,'Via Domitia - Sestriere-Arles','fr23a',426.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR23a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(80,2,'Le Chemin de Regordane - Le Puy - Arles','fr24a',240.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR24a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(81,2,'Chemin Meurchin - Thievres','fr25a',74.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR25a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(82,2,'Voie de Garonne - Toulouse-St Gaudens','fr26a',129.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR26a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(83,2,'Chemin Maubourguet - Lourdes','fr27a',63.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR27a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(84,2,'Via Aurelia - Ventimiglia-Arles','fr28a',385.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR28a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(85,2,'Via Gebennensis - Geneve-LePuy','fr29a',396.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR29a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(86,2,'La Voie des Plantagenets','fr30a',559.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR30a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(87,2,'Voie De la Pointe - Saint Mathieu a Clisson','fr31a',533.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR31a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(88,2,'La Voie Locquirec ou Mogueriec','fr32a',501.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR32a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(89,2,'La Voie de l\'Abbaye de Beauport','fr33a',403.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR33a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(90,2,'La Vie des Capitales','fr34a',350.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR34a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(91,2,'Chemin Bergerac - Montreal du Gers','fr35a',182.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR35a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(92,2,'La Voie Pays Mogueriec - Morlaix','fr36a',35.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR36a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(93,2,'Chemin Rouen - Chartres','fr37a',154.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR37a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(94,2,'Chemin Sancoins a Clermont-Ferrand','fr38a',198.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR38a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(95,2,'Via Arverna - Clermont-Ferrand-Cahors','fr39a',535.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR39a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(96,2,'Voie de Rocamadour en Limousin et Haut Quercy','fr40a',548.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR40a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(97,2,'Voie de Rocamadour - Cahors','fr41a',69.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR41a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(98,2,'Voie Figeac - Rocamadour','fr42a',56.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR42a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(99,2,'Voie Bergerac - Rocamadour','fr43a',166.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR43a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(100,2,'Voie Col d\'Ourdiss - Lortet-Port d\'Ourdiss','fr44a',59.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR44a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(101,2,'Voie Arudy - Col du Somport','fr45a',59.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR45a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(102,2,'Chemin de Fontcaude Saint Gervais sur Mare - Capestang','fr46a',55.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR46a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(103,2,'Chemin Vallee du Cele - Bach Cahors','fr47a',54.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR47a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(104,2,'Chemin Beduer - Bouzies','fr48a',54.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR48a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(105,2,'Le Grand Chemin Montois - Mont Saint Michel Tours','fr49a',342.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR49a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(106,2,'Ouistreham Caen - Le Mans','fr50a',353.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR50a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(107,2,'Voie Basel - Hericourt','fr51a',86.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR51a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(108,2,'Chemin Orcival Rocamadour','fr52a',348.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR52a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(109,2,'Chemin Geneve LePuy','fr53a',342.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR53a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(110,2,'Chemin Guillonay LePuy','fr54a',289.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR54a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(111,2,'Chemin Cluny LePuy','fr55a',296.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR55a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(112,2,'Chemin Lyon La Roche de Glun','fr56a',141.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR56a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(113,2,'Chemin Guillonay-Arles','fr57a',413.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR57a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(114,2,'Chemin Libercourt-Folleville','fr58a',232.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR58a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(115,2,'Chemin Beauvais-Baillon','fr59a',52.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR59a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(116,2,'Chemin Amiens-Rouen','fr60a',162.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR60a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(117,2,'Chemin Amiens-Chartres','fr61a',261.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR61a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(118,3,'Caminho Central Regiao Centro e Norte','pt01a',499.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(119,3,'Caminho Portugues Interior a Santiago','pt02a',243.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(120,3,'Caminho da Costa','pt03a',136.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(121,3,'Caminho Portugues Porto - Braga - Ponte de Lima','pt05a',100.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(122,3,'Camino Torres','pt06a',392.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(123,3,'Caminho Portugues de la Via de la Plata','pt07a',232.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(124,3,'Caminho Central Alentejo e Ribatejo','pt08a',508.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(125,3,'Caminho Nascente','pt09a',663.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(126,3,'Caminho Central Via Atlantico','pt10a',135.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(127,4,'Via Francigena Roma - Sarzana','it01a',527.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(128,4,'Via della Costa - Sarzana-Ventimiglia','it02a',310.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(129,4,'Via Francigena Nord - Sarzana-Montgenevre','it03a',615.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(130,4,'Via Francigena Sud - Brindisi-Roma','it04a',685.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(131,4,'Cammino di Santu Jacu centrale Cagliari - Porto Torres','it05a',532.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(132,4,'Cammino di Santu Jacu Braccio sudovest - Capoterra-CarloForte','it05b',247.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(133,4,'Cammino di Santu Jacu Braccio lateral nordest - Olbia-Orosei','it05c',373.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(134,4,'Cammino di Santu Jacu Braccio lateral nordovest - Oristano-Bolotana','it05d',149.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05d.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(135,4,'Via Micaelica - Roma-Monte Sant\'Angelo','it07a',404.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(136,4,'Via Postumia - Aquileia-Genova','it09a',958.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(137,4,'Romea Strata - Via Allemagna','it13a',192.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(138,4,'Romea Strata - Via Romea Annia','it13b',265.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(139,4,'Romea Strata - Via Romea Aquileiense','it13c',105.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(140,4,'Romea Strata - Via Romea Longobarda','it13d',398.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13d.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(141,4,'Romea Strata - Via Romea Vicetia','it13f',106.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13f.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(142,4,'Via Romea Germanica - Brennero-Padova','it16a',322.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT16a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(143,4,'Il Cammino di San Giacomo in Sicilia','it32a',486.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT32a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(144,4,'Cammino di San Jacopo','it33a',173.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT33a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(145,5,'Via Baltica - Swinemunde-Osnabruck','de01a',817.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(146,5,'Via Scandinavica - Fehmarn-Creuzburg','de02a',624.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(147,5,'Via Jutlandica a Padborg-Lubeck','de03a',156.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(148,5,'Via Jutlandica b Padborg-Harsefeld','de04a',217.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(149,5,'Jakobsweg Osnabruck - Aachen','de05a',603.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(150,5,'Jakobsweg Nijmegen - Koln','de06a',204.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(151,5,'Jakobsweg Stettin - Berlin','de07a',213.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(152,5,'Jakobsweg Frankfurt an der Oder - Berlin','de08a',112.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(153,5,'Jakobsweg Bad Wilsnack - Berlin','de09a',139.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(154,5,'Jakobsweg Rostock-Bad Wilsnack','de10a',182.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(155,5,'Jakobsweg Frankfurt an der Oder - Berlin-Tangermunde','de11a',143.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(156,5,'Jakobsweg Bad Wilsnack - Freyburg','de12a',433.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(157,5,'Jakobsweg Halberstadt - Dortmund','de13a',313.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(158,5,'Jakobsweg Frankfurt an der Oder - Leipzig','de14a',234.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE14a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(159,5,'Jakobsweg Berlin - Leipzig','de15a',208.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE15a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(160,5,'Via Regia - Gorlitz-Fulda','de16a',527.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE16a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(161,5,'Sachsischer Jakobsweg Bautzen - Hof','de17a',285.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE17a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(162,5,'Jakobsweg Leipzig - Zwickau','de18a',105.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE18a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(163,5,'Jakobsweg Paderborn - Koln','de19a',234.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE19a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(164,5,'Jakobsweg Eisenach - Koln','de20a',340.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE20a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(165,5,'Via Imperii - Hof-Nurnberg','de21a',183.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE21a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(166,5,'Jakobsweg Erfurt - Nurnberg','de22a',223.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE22a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(167,5,'Jakobsweg Bamberg - Uffenheim','de23a',99.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE23a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(168,5,'Jakobsweg Fulda Mainz','de24a',165.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE24a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(169,5,'Jakobsweg Fulda - Wurzburg','de25a',155.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE25a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(170,5,'Jakobsweg Koln - Metz','de26a',393.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE26a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(171,5,'Jakobsweg Andernach - Trier','de27a',120.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE27a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(172,5,'Jakobsweg Mainz - Trier','de28a',159.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE28a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(173,5,'Frankisch Schwabischer Jakobsweg Wurzburg - Ulm','de29a',270.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE29a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(174,5,'Oberpfalzer Jakobsweg - Tillyschanz-Nurnberg','de30a',177.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE30a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(175,5,'Jakobsweg Nurnberg - Rothenburg','de31a',86.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE31a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(176,5,'Jakobsweg Rothenburg - Metz','de32a',549.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE32a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(177,5,'Jakobsweg Nurnberg - Eichstatt','de33a',55.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE33a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(178,5,'Jakobsweg Nurnberg - Konstanz','de34a',381.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE34a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(179,5,'Ostbayrischer Jakobsweg Vseruby - Donauworth','de35a',271.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE35a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(180,5,'Jakobsweg Nordlingen - Kempten','de36a',339.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE36a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(181,5,'Jakobsweg Rothenburg - Rottenburg','de37a',196.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE37a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(182,5,'Kinzigtaler Jakobsweg - Horb am Neckar-Strasbourg','de38a',146.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE38a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(183,5,'Jakobsweg Mainz - Speyer','de39a',100.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE39a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(184,5,'Jakobsweg Weinstadt - Neckartenzlingen','de40a',112.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE40a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(185,5,'Jakobsweg Rottenburg - Blumberg','de41a',148.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE41a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(186,5,'Jakobsweg Hufingen - Basel','de42a',191.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE42a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(187,5,'Jakobsweg St Oswald bei Haslach - Peissenberg','de43a',496.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE43a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(188,5,'Munchener Jakobsweg - Munchen-Bregenz','de44a',570.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE44a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(189,5,'Jakobsweg Salzburg - Bad Aibling','de45a',135.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE45a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(190,5,'Badischer Jakobsweg Ettlingen - Breisach','de46a',140.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE46a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(191,5,'Jakobsweg Wolfach-Thann','de47a',183.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE47a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(192,5,'Zittauer Jakobsweg','de48a',47.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE48a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(193,7,'Via Brabantica','be01a',435.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(194,7,'Via Limburgica','be02a',259.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(195,7,'Via Monastica','be03a',283.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(196,7,'Via Mosana-2','be03b',93.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE03b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(197,7,'Via Scaldea','be04a',277.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(198,7,'Via Thierache','be05a',134.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(199,7,'Via Brugensis','be06a',198.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(200,7,'Via Mosana','be07a',960.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(201,7,'Via Tenera','be08a',391.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(202,7,'Via Yprensis Nieuwpoort-Wervik','be09a',71.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(203,7,'Via Lovaniensis Mechelen-Helecine','be10a',65.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(204,7,'Arras Epernon','be11a',281.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(205,7,'Arras Saint Quentin-Reims','be12a',228.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(206,7,'Via Gallia Belgica','be13a',240.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(207,11,'Jacobsweg Amstelredam Den Oever - Postel','nl01a',410.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(208,11,'Jacobsweg Amsvorde - Uithuizen Kapellen','nl02a',498.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(209,11,'Jacobsweg Audenzeel Oldenzaal - Doesburg','nl03a',95.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(210,11,'Jacobsweg DieHage Haarlem - Brugge Gent','nl04a',286.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(211,11,'Jacobsweg Nieumeghen Hasselt - Eijsden','nl05a',686.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(212,11,'Jacobsweg Thuredrecht - Schipluiden Kapellen','nl06a',153.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(213,11,'Jacobsweg Afsluitdijk DenOever - Sint Jacobiparochie','nl07a',64.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(214,6,'Via Jacobi Rorschach - Einsiedeln','ch01a',110.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(215,6,'Via Jacobi Einsiedeln - Geneve','ch01b',428.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(216,6,'Via Jacobi Konstanz - Einsiedeln','ch01c',88.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01c.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(217,6,'Via Jacobi Luzern - Fribourg','ch01d',132.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01d.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(218,12,'Boyne Valley Camino','ie01a',22.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(219,12,'Bray Coastal Camino','ie02a',31.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(220,12,'Croagh Patrick Heritage Trail','ie03a',60.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(221,12,'Saint Declan\'s Way','ie04a',115.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(222,9,'Jakobsweg Bohmerwald St.Oswald bei Haslach - Passau','at01a',92.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(223,9,'Jakobsweg Muhlviertel Kautzen - Pyburg','at02a',163.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(224,9,'Jakobsweg Weinviertel Drasenhofen - Krems','at03a',154.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(225,9,'Jakobsweg Wolfsthal - Lofer','at04a',611.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(226,9,'Jakobsweg Pamhagen - Maria Ellend','at05a',76.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(227,9,'Jakobsweg Innviertel Passau - Salzburg','at06a',145.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(228,9,'Jakobsweg Tirol Lofer - Innsbruck','at07a',300.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(229,9,'Jakobsweg Weststeiermark Graz - Lavamund','at08a',152.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(230,9,'Jakobsweg Karnten Dravograd - Nikolsdorf','at09a',300.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(231,9,'Jakobsweg Nikolsdorf - Innsbruck','at10a',245.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(232,9,'Jakobsweg Vorarlberg Pettneu - Rankweil','at11a',115.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(233,9,'Jakobsweg Vorarlberg Missen - Bregenz - Widnau','at11b',117.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT11b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(234,8,'Dolnoslaska Droga sw. Jakuba','pl01a',159.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(235,8,'Droga Polska (Camino Polaco)','pl02a',671.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(236,8,'Wielkopolska Droga sw. Jakuba','pl03a',292.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(237,8,'Droga sw. Jakuba Via Regia','pl04a',1005.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(238,8,'Pomorska Droga sw. Jakuba (Via Baltica)','pl05a',696.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(239,8,'Via Imperii','pl06a',23.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(240,8,'Lubelska Droga sw. Jakuba','pl07a',145.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(241,8,'Malopolska Droga sw. Jakuba','pl08a',324.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(242,8,'Tarnobrzeska droga sw. Jakuba','pl09a',20.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(243,8,'Swietokrzyska Droga sw. Jakuba','pl10a',333.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(244,8,'Beskidzka droga sw. Jakuba','pl11a',289.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(245,8,'Jasnogorska droga sw. Jakuba','pl12a',57.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(246,8,'Czestochowska droga sw. Jakuba','pl13a',103.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(247,8,'Slasko Morawska droga sw. Jakuba','pl14a',95.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL14a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(248,8,'Raciborska droga sw. Jakuba','pl15a',107.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL15a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(249,8,'Nyska droga sw. Jakuba','pl16a',97.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL16a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(250,8,'Sudecka droga sw. Jakuba','pl17a',221.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL17a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(251,8,'Slezanska droga sw. Jakuba','pl18a',51.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL18a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(252,8,'Scinawska droga sw. Jakuba','pl19a',51.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL19a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(253,8,'Lubuska droga sw. Jakuba','pl20a',361.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL20a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(254,8,'Warszawska droga sw. Jakuba','pl21a',382.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL21a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(255,8,'Mazowiecka droga sw. Jakuba','pl22a',167.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL22a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(256,8,'Dobrzynsko-Kujawska droga sw. Jakuba','pl23a',108.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL23a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(257,8,'Bydgoska droga sw. Jakuba','pl24a',86.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL24a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(258,8,'Nadwarcianska droga sw. Jakuba','pl25a',108.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL25a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(259,8,'Lowicka droga sw. Jakuba','pl26a',225.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL26a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(260,8,'Kaliska droga sw. Jakuba','pl27a',154.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL27a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(261,8,'Pelplinska droga sw. Jakuba','pl28a',114.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL28a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(262,8,'Czluchowska droga sw. Jakuba','pl29a',209.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL29a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(263,8,'Nadsanska droga sw. Jakuba','pl30a',102.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL30a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(264,8,'Podlaska droga sw. Jakuba','pl31a',473.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL31a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(265,14,'Zitavska trasa','cz01a',151.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(266,14,'Vserubska trasa','cz02a',206.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(267,14,'Zelezna trasa','cz03a',258.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(268,14,'Vychodoceska trasa','cz04a',265.6,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(269,14,'Jihoceska trasa','cz05a',214.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(270,14,'Moravskoslezska trasa','cz06a',276.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(271,15,'Camino Hungaro','hu01a',273.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(272,15,'Camino Benedictus','hu02a',211.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(273,15,'Via Peregrinus','hu03a',114.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(274,16,'Dolenjska Veja','si01a',171.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(275,16,'Primorska Veja','si01b',145.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI01b.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(276,16,'Gorenjska Veja','si02a',182.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(277,16,'Prekmurska in Stajerska Veja','si03a',288.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(278,16,'Preddvorska Veja','si04a',59.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(279,13,'Camino Podravina','hr01a',154.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(280,13,'Camino Medimurje','hr02a',51.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(281,13,'Hrvatsko Zagorje','hr03a',56.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(282,13,'Camino Samobor','hr04a',60.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(283,13,'Camino Krizevci','hr05a',61.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(284,13,'Camino Banovina','hr06a',74.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(285,13,'Camino Gorski-Kotar','hr07a',346.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(286,13,'Camino Imota','hr08a',72.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(287,13,'Camino Srednja-Dalmacija','hr09a',120.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(288,13,'Camino Sibenik','hr10a',108.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR10a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(289,13,'Camino Zadar','hr11a',143.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR11a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(290,13,'Camino Lika','hr12a',434.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR12a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(291,13,'Camino South-Istria','hr13a',192.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR13a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(292,13,'Camino North-Istria','hr14a',37.1,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR14a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(293,13,'Camino Korcula','hr15a',156.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR15a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(294,13,'Camino Krk','hr16a',161.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR16a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(295,13,'Camino Brac','hr17a',157.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR17a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(296,17,'Svatojakubska cesta na Slovensku','sk01a',760.8,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/SK01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(297,18,'Den Danske Pilgrimsrute Sydfyn','dk01a',146.0,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK01a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(298,18,'Den Danske Pilgrimsrute Sydsjaelland','dk02a',154.7,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK02a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(299,18,'Den Danske Pilgrimsrute Midtjylland','dk03a',153.2,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK03a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(300,18,'Den Danske Pilgrimsrute Ostsjaelland','dk04a',52.3,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK04a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(301,18,'Den Danske Pilgrimsrute Vestsjaelland','dk05a',112.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK05a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(302,18,'Den Danske Pilgrimsrute Nordsjaelland','dk06a',115.5,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK06a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(303,18,'Den Danske Pilgrimsrute Sonderjylland','dk07a',141.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK07a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(304,18,'Den Danske Pilgrimsrute Ost og Vestfyn','dk08a',166.9,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK08a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29'),
(305,18,'Den Danske Pilgrimsrute Nordjylland Ost','dk09a',136.4,NULL,'moderate','https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK09a.rar','active','2026-02-18 17:38:29','2026-02-18 17:38:29');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scrape_jobs`
--

DROP TABLE IF EXISTS `scrape_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scrape_jobs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job_type` enum('google_places','facebook','instagram','tourisme','forum','enrichment','site_generation','api_sync') NOT NULL,
  `target_type` enum('locality','establishment','route') NOT NULL,
  `target_id` int(10) unsigned NOT NULL,
  `status` enum('pending','running','done','error') NOT NULL DEFAULT 'pending',
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `results_count` int(11) NOT NULL DEFAULT 0,
  `error_log` text DEFAULT NULL,
  `cost_usd` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_job_type` (`job_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scrape_jobs`
--

LOCK TABLES `scrape_jobs` WRITE;
/*!40000 ALTER TABLE `scrape_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `scrape_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stages`
--

DROP TABLE IF EXISTS `stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int(10) unsigned NOT NULL,
  `stage_number` int(11) NOT NULL,
  `name` varchar(300) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `locality_start_id` int(10) unsigned DEFAULT NULL,
  `locality_end_id` int(10) unsigned DEFAULT NULL,
  `km` decimal(6,1) NOT NULL,
  `d_plus` int(11) DEFAULT NULL,
  `d_minus` int(11) DEFAULT NULL,
  `estimated_hours` decimal(4,1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `route_id` (`route_id`),
  KEY `locality_start_id` (`locality_start_id`),
  KEY `locality_end_id` (`locality_end_id`),
  CONSTRAINT `stages_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stages_ibfk_2` FOREIGN KEY (`locality_start_id`) REFERENCES `localities` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stages_ibfk_3` FOREIGN KEY (`locality_end_id`) REFERENCES `localities` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stages`
--

LOCK TABLES `stages` WRITE;
/*!40000 ALTER TABLE `stages` DISABLE KEYS */;
/*!40000 ALTER TABLE `stages` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-18 17:45:28
