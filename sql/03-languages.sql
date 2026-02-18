-- ============================================================
-- MODIFICATION : Langues dynamiques + pays europeens complets
-- Date : 2026-02-18
-- ============================================================
SET NAMES utf8mb4;

-- ============================================================
-- 1. TABLE establishment_content : ENUM -> VARCHAR(5)
-- ============================================================
ALTER TABLE establishment_content
  DROP INDEX uq_estab_lang,
  MODIFY COLUMN lang VARCHAR(5) NOT NULL COMMENT 'Code ISO 639-1',
  ADD UNIQUE KEY uq_estab_lang (establishment_id, lang);

SELECT 'STEP 1 OK: lang is now VARCHAR(5)' AS status;

-- ============================================================
-- 2. TABLE countries : ajouter pays manquants (INSERT IGNORE)
-- ============================================================
-- Existent deja : ES,FR,PT,IT,DE,CH,BE,PL,AT,GB,NL,IE,HR,CZ,HU,SI,SK,DK
-- INSERT IGNORE saute les doublons sur code_iso (UNIQUE)
INSERT IGNORE INTO countries (code_iso, name_fr, name_es, name_en, priority) VALUES
('SE', 'Suede', 'Suecia', 'Sweden', 12),
('NO', 'Norvege', 'Noruega', 'Norway', 13),
('FI', 'Finlande', 'Finlandia', 'Finland', 14),
('DK', 'Danemark', 'Dinamarca', 'Denmark', 15),
('IE', 'Irlande', 'Irlanda', 'Ireland', 16),
('HR', 'Croatie', 'Croacia', 'Croatia', 17),
('CZ', 'Republique Tcheque', 'Republica Checa', 'Czech Republic', 18),
('HU', 'Hongrie', 'Hungria', 'Hungary', 19),
('SI', 'Slovenie', 'Eslovenia', 'Slovenia', 20),
('SK', 'Slovaquie', 'Eslovaquia', 'Slovakia', 21),
('RO', 'Roumanie', 'Rumania', 'Romania', 22),
('BG', 'Bulgarie', 'Bulgaria', 'Bulgaria', 23),
('GR', 'Grece', 'Grecia', 'Greece', 24),
('RS', 'Serbie', 'Serbia', 'Serbia', 25),
('BA', 'Bosnie-Herzegovine', 'Bosnia-Herzegovina', 'Bosnia Herzegovina', 26),
('ME', 'Montenegro', 'Montenegro', 'Montenegro', 27),
('MK', 'Macedoine du Nord', 'Macedonia del Norte', 'North Macedonia', 28),
('AL', 'Albanie', 'Albania', 'Albania', 29),
('LT', 'Lituanie', 'Lituania', 'Lithuania', 30),
('LV', 'Lettonie', 'Letonia', 'Latvia', 31),
('EE', 'Estonie', 'Estonia', 'Estonia', 32),
('LU', 'Luxembourg', 'Luxemburgo', 'Luxembourg', 33),
('MT', 'Malte', 'Malta', 'Malta', 34),
('CY', 'Chypre', 'Chipre', 'Cyprus', 35),
('IS', 'Islande', 'Islandia', 'Iceland', 36),
('TR', 'Turquie', 'Turquia', 'Turkey', 37),
('UA', 'Ukraine', 'Ucrania', 'Ukraine', 38);

SELECT CONCAT('STEP 2 OK: ', COUNT(*), ' countries total') AS status FROM countries;

-- ============================================================
-- 2b. Mettre a jour les priorites pour TOUS les pays
-- ============================================================
UPDATE countries SET priority = 1 WHERE code_iso = 'ES';
UPDATE countries SET priority = 2 WHERE code_iso = 'FR';
UPDATE countries SET priority = 3 WHERE code_iso = 'PT';
UPDATE countries SET priority = 4 WHERE code_iso = 'IT';
UPDATE countries SET priority = 5 WHERE code_iso = 'DE';
UPDATE countries SET priority = 6 WHERE code_iso = 'CH';
UPDATE countries SET priority = 7 WHERE code_iso = 'BE';
UPDATE countries SET priority = 8 WHERE code_iso = 'PL';
UPDATE countries SET priority = 9 WHERE code_iso = 'AT';
UPDATE countries SET priority = 10 WHERE code_iso = 'GB';
UPDATE countries SET priority = 11 WHERE code_iso = 'NL';
UPDATE countries SET priority = 12 WHERE code_iso = 'SE';
UPDATE countries SET priority = 13 WHERE code_iso = 'NO';
UPDATE countries SET priority = 14 WHERE code_iso = 'FI';
UPDATE countries SET priority = 15 WHERE code_iso = 'DK';
UPDATE countries SET priority = 16 WHERE code_iso = 'IE';
UPDATE countries SET priority = 17 WHERE code_iso = 'HR';
UPDATE countries SET priority = 18 WHERE code_iso = 'CZ';
UPDATE countries SET priority = 19 WHERE code_iso = 'HU';
UPDATE countries SET priority = 20 WHERE code_iso = 'SI';
UPDATE countries SET priority = 21 WHERE code_iso = 'SK';
UPDATE countries SET priority = 22 WHERE code_iso = 'RO';
UPDATE countries SET priority = 23 WHERE code_iso = 'BG';
UPDATE countries SET priority = 24 WHERE code_iso = 'GR';
UPDATE countries SET priority = 25 WHERE code_iso = 'RS';
UPDATE countries SET priority = 26 WHERE code_iso = 'BA';
UPDATE countries SET priority = 27 WHERE code_iso = 'ME';
UPDATE countries SET priority = 28 WHERE code_iso = 'MK';
UPDATE countries SET priority = 29 WHERE code_iso = 'AL';
UPDATE countries SET priority = 30 WHERE code_iso = 'LT';
UPDATE countries SET priority = 31 WHERE code_iso = 'LV';
UPDATE countries SET priority = 32 WHERE code_iso = 'EE';
UPDATE countries SET priority = 33 WHERE code_iso = 'LU';
UPDATE countries SET priority = 34 WHERE code_iso = 'MT';
UPDATE countries SET priority = 35 WHERE code_iso = 'CY';
UPDATE countries SET priority = 36 WHERE code_iso = 'IS';
UPDATE countries SET priority = 37 WHERE code_iso = 'TR';
UPDATE countries SET priority = 38 WHERE code_iso = 'UA';

SELECT 'STEP 2b OK: priorities updated' AS status;

-- ============================================================
-- 3. TABLE countries : ajouter colonne languages JSON
-- ============================================================
ALTER TABLE countries ADD COLUMN languages JSON NOT NULL DEFAULT '["en"]'
  COMMENT 'Codes ISO 639-1 des langues du pays' AFTER name_en;

UPDATE countries SET languages = '["es"]' WHERE code_iso = 'ES';
UPDATE countries SET languages = '["fr"]' WHERE code_iso = 'FR';
UPDATE countries SET languages = '["pt"]' WHERE code_iso = 'PT';
UPDATE countries SET languages = '["it"]' WHERE code_iso = 'IT';
UPDATE countries SET languages = '["de"]' WHERE code_iso = 'DE';
UPDATE countries SET languages = '["de"]' WHERE code_iso = 'AT';
UPDATE countries SET languages = '["de","fr","it","rm"]' WHERE code_iso = 'CH';
UPDATE countries SET languages = '["fr","nl","de"]' WHERE code_iso = 'BE';
UPDATE countries SET languages = '["nl"]' WHERE code_iso = 'NL';
UPDATE countries SET languages = '["pl"]' WHERE code_iso = 'PL';
UPDATE countries SET languages = '["cs"]' WHERE code_iso = 'CZ';
UPDATE countries SET languages = '["hu"]' WHERE code_iso = 'HU';
UPDATE countries SET languages = '["sl"]' WHERE code_iso = 'SI';
UPDATE countries SET languages = '["hr"]' WHERE code_iso = 'HR';
UPDATE countries SET languages = '["sk"]' WHERE code_iso = 'SK';
UPDATE countries SET languages = '["da"]' WHERE code_iso = 'DK';
UPDATE countries SET languages = '["en","ga"]' WHERE code_iso = 'IE';
UPDATE countries SET languages = '["sv"]' WHERE code_iso = 'SE';
UPDATE countries SET languages = '["no","nb","nn"]' WHERE code_iso = 'NO';
UPDATE countries SET languages = '["fi","sv"]' WHERE code_iso = 'FI';
UPDATE countries SET languages = '["ro"]' WHERE code_iso = 'RO';
UPDATE countries SET languages = '["bg"]' WHERE code_iso = 'BG';
UPDATE countries SET languages = '["el"]' WHERE code_iso = 'GR';
UPDATE countries SET languages = '["sr"]' WHERE code_iso = 'RS';
UPDATE countries SET languages = '["bs","hr","sr"]' WHERE code_iso = 'BA';
UPDATE countries SET languages = '["cnr"]' WHERE code_iso = 'ME';
UPDATE countries SET languages = '["mk"]' WHERE code_iso = 'MK';
UPDATE countries SET languages = '["sq"]' WHERE code_iso = 'AL';
UPDATE countries SET languages = '["lt"]' WHERE code_iso = 'LT';
UPDATE countries SET languages = '["lv"]' WHERE code_iso = 'LV';
UPDATE countries SET languages = '["et"]' WHERE code_iso = 'EE';
UPDATE countries SET languages = '["fr","de","lb"]' WHERE code_iso = 'LU';
UPDATE countries SET languages = '["mt","en"]' WHERE code_iso = 'MT';
UPDATE countries SET languages = '["el","tr"]' WHERE code_iso = 'CY';
UPDATE countries SET languages = '["is"]' WHERE code_iso = 'IS';
UPDATE countries SET languages = '["tr"]' WHERE code_iso = 'TR';
UPDATE countries SET languages = '["uk"]' WHERE code_iso = 'UA';
UPDATE countries SET languages = '["en"]' WHERE code_iso = 'GB';

SELECT 'STEP 3 OK: languages column added and populated' AS status;

-- ============================================================
-- VERIFICATION FINALE
-- ============================================================
SELECT c.code_iso, c.name_fr, c.priority, c.languages, COUNT(r.id) AS nb_routes
FROM countries c
LEFT JOIN routes r ON r.country_id = c.id
GROUP BY c.id
ORDER BY c.priority;

DESCRIBE establishment_content;
