-- ============================================================
-- Migration : UNIQUE KEY (name, locality_id) sur establishments
-- Empêche les doublons même nom + même localité
-- ============================================================

USE caballarius_staging;

-- Ajouter la contrainte UNIQUE
ALTER TABLE establishments
  ADD UNIQUE KEY uq_name_locality (name, locality_id);

-- Vérification
SHOW INDEX FROM establishments WHERE Key_name = 'uq_name_locality';
