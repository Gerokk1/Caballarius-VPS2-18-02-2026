-- ============================================================
-- MEGA INSERT : 8 nouveaux pays + 305 routes (319 caminosantiago.org)
-- Source : caminosantiago.org (source master)
-- Validation : nco.ign.es (Espagne uniquement)
-- Date : 2026-02-18
-- ============================================================

SET NAMES utf8mb4;

-- ============================================================
-- PARTIE 1 : 8 nouveaux pays
-- ============================================================
INSERT INTO countries (code_iso, name_fr, name_es, name_en, priority) VALUES
('NL', 'Pays-Bas', 'Paises Bajos', 'Netherlands', 11),
('IE', 'Irlande', 'Irlanda', 'Ireland', 12),
('HR', 'Croatie', 'Croacia', 'Croatia', 13),
('CZ', 'Republique Tcheque', 'Republica Checa', 'Czech Republic', 14),
('HU', 'Hongrie', 'Hungria', 'Hungary', 15),
('SI', 'Slovenie', 'Eslovenia', 'Slovenia', 16),
('SK', 'Slovaquie', 'Eslovaquia', 'Slovakia', 17),
('DK', 'Danemark', 'Dinamarca', 'Denmark', 18);

-- ============================================================
-- PARTIE 2 : Variables country_id
-- ============================================================
SET @es = (SELECT id FROM countries WHERE code_iso='ES');
SET @fr = (SELECT id FROM countries WHERE code_iso='FR');
SET @pt = (SELECT id FROM countries WHERE code_iso='PT');
SET @it = (SELECT id FROM countries WHERE code_iso='IT');
SET @de = (SELECT id FROM countries WHERE code_iso='DE');
SET @ch = (SELECT id FROM countries WHERE code_iso='CH');
SET @be = (SELECT id FROM countries WHERE code_iso='BE');
SET @pl = (SELECT id FROM countries WHERE code_iso='PL');
SET @at = (SELECT id FROM countries WHERE code_iso='AT');
SET @nl = (SELECT id FROM countries WHERE code_iso='NL');
SET @ie = (SELECT id FROM countries WHERE code_iso='IE');
SET @hr = (SELECT id FROM countries WHERE code_iso='HR');
SET @cz = (SELECT id FROM countries WHERE code_iso='CZ');
SET @hu = (SELECT id FROM countries WHERE code_iso='HU');
SET @si = (SELECT id FROM countries WHERE code_iso='SI');
SET @sk = (SELECT id FROM countries WHERE code_iso='SK');
SET @dk = (SELECT id FROM countries WHERE code_iso='DK');
SET @gb = (SELECT id FROM countries WHERE code_iso='GB');

-- ============================================================
-- PARTIE 3 : ESPAGNE — 52 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@es, 'Camino Frances por Navarra', 'es01a', 137.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01a.rar'),
(@es, 'Camino Frances por Aragon', 'es01b', 274.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01b.rar'),
(@es, 'Camino Frances', 'es01c', 970.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES01c.rar'),
(@es, 'Camino Portugues desde Tui', 'es02a', 137.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES02a.rar'),
(@es, 'Camino del Norte', 'es03a', 1038.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES03a.rar'),
(@es, 'Camino Mozarabe - Via de la Plata', 'es04a', 1148.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES04a.rar'),
(@es, 'Via de la Plata de Zamora a Astorga', 'es04b', 190.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES04b.rar'),
(@es, 'Camino Primitivo', 'es05a', 291.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES05a.rar'),
(@es, 'Camino Ingles', 'es06a', 147.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES06a.rar'),
(@es, 'Camino de Fisterra y Muxia', 'es07a', 143.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES07a.rar'),
(@es, 'Camino de Levante', 'es08a', 843.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES08a.rar'),
(@es, 'Camino del Sureste', 'es09a', 889.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES09a.rar'),
(@es, 'Camino Mozarabe de Almeria', 'es10a', 205.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10a.rar'),
(@es, 'Camino Mozarabe de Cordoba', 'es10b', 308.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10b.rar'),
(@es, 'Camino Mozarabe de Granada', 'es10c', 108.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10c.rar'),
(@es, 'Camino Mozarabe de Jaen', 'es10d', 47.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10d.rar'),
(@es, 'Camino Mozarabe de Malaga', 'es10e', 240.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES10e.rar'),
(@es, 'Camino Olvidado', 'es11a', 703.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES11a.rar'),
(@es, 'Camino de Madrid', 'es12a', 451.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES12a.rar'),
(@es, 'Camino de la Lana', 'es13a', 770.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES13a.rar'),
(@es, 'Camino Santiago del Ebro', 'es14a', 459.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES14a.rar'),
(@es, 'Ruta del Argar', 'es15a', 411.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES15a.rar'),
(@es, 'Camino de Invierno', 'es17a', 217.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES17a.rar'),
(@es, 'Camino Portugues de la Costa - A Guarda-Baiona-Vigo-Redondela', 'es18a', 79.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES18a.rar'),
(@es, 'Camino Argar del Sureste de Almeria', 'es19a', 230.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES19a.rar'),
(@es, 'Camino del Interior Vasco Riojano', 'es20a', 209.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES20a.rar'),
(@es, 'Camino Castellano Aragones en Soria', 'es21a', 255.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES21a.rar'),
(@es, 'Camino de Santiago de Barcelona a San Juan de la Pena', 'es22a', 408.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES22a.rar'),
(@es, 'Camino de Santiago de Castellon - Bajo Aragon', 'es23a', 305.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES23a.rar'),
(@es, 'Cami Gironi de Sant Jaume', 'es24a', 278.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24a.rar'),
(@es, 'Cami de Sant Jaume del Llobregat', 'es24b', 59.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24b.rar'),
(@es, 'Cami Catala de Sant Jaume', 'es24c', 528.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES24c.rar'),
(@es, 'Camino de Sagunto', 'es25a', 439.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES25a.rar'),
(@es, 'Camino de El Salvador', 'es28a', 150.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES28a.rar'),
(@es, 'Ruta Vadiniense', 'es29a', 212.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES29a.rar'),
(@es, 'Camino del Besaya - Calzada romana', 'es30a', 252.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES30a.rar'),
(@es, 'Camino Via de Bayona', 'es32a', 301.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES32a.rar'),
(@es, 'Camino de Baztan', 'es33a', 115.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES33a.rar'),
(@es, 'Camino Manchego de Ciudad Real a Toledo', 'es34a', 167.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES34a.rar'),
(@es, 'Camino Sur de Huelva', 'es35a', 191.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES35a.rar'),
(@es, 'Via Augusta desde Cadiz', 'es36a', 181.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES36a.rar'),
(@es, 'Camino de la Lana Valencia-Requena', 'es37a', 224.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES37a.rar'),
(@es, 'Camino del Alba', 'es38a', 166.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES38a.rar'),
(@es, 'Camino del Sureste desde Benidorm', 'es39a', 102.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES39a.rar'),
(@es, 'Camino Variante Espiritual', 'es40b', 68.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES40b.rar'),
(@es, 'Camino del Sureste - Ramal Sur', 'es42a', 108.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES42a.rar'),
(@es, 'Camino de la Santa Cruz', 'es43a', 77.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES43a.rar'),
(@es, 'Camino del Sureste - Cartagena-Murcia', 'es44a', 240.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES44a.rar'),
(@es, 'Camino Lebaniego', 'es45a', 71.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES45a.rar'),
(@es, 'Camino de Santiago de Gran Canaria', 'es46a', 94.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES46a.rar'),
(@es, 'Camino de las Asturias', 'es48a', 577.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES48a.rar'),
(@es, 'Camino Mendocino a Santiago', 'es49a', 97.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/ES49a.rar');

-- ============================================================
-- FRANCE — 65 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@fr, 'Voie Turonensis tranche Chartres', 'fr01a', 321.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01a.rar'),
(@fr, 'Voie Turonensis tranche Orleans', 'fr01b', 274.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01b.rar'),
(@fr, 'Voie Turonensis Paris', 'fr01c', 786.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR01c.rar'),
(@fr, 'Via Lemovicensis Nord par Bourges', 'fr02a', 270.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02a.rar'),
(@fr, 'Via Lemovicensis Sud par Nevers', 'fr02b', 349.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02b.rar'),
(@fr, 'Via Lemovicensis Vezelay', 'fr02c', 624.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR02c.rar'),
(@fr, 'Via Podiensis Le Puy en Velay', 'fr03a', 763.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR03a.rar'),
(@fr, 'Via Tolosana Arles', 'fr04a', 789.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR04a.rar'),
(@fr, 'Voie des Piemonts', 'fr05a', 671.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR05a.rar'),
(@fr, 'Chemin Mont Saint Michel', 'fr06a', 413.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR06a.rar'),
(@fr, 'Chemin Saint Michel - Royan', 'fr07a', 329.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR07a.rar'),
(@fr, 'Via Gallia Belgica - Maubeuge-Saint Quentin', 'fr08a', 101.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR08a.rar'),
(@fr, 'Chemin Tournai - Paris', 'fr09a', 309.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR09a.rar'),
(@fr, 'Chemin Dieppe - Mont Saint Michel', 'fr10a', 83.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR10a.rar'),
(@fr, 'Chemin Reims - Paris', 'fr11a', 211.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR11a.rar'),
(@fr, 'Chemin Voie Littorale - Royan - Irun', 'fr12a', 412.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR12a.rar'),
(@fr, 'Le Chemin Cotie - Lesseron - Bayonne', 'fr13a', 91.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR13a.rar'),
(@fr, 'Chemin Rocroi - Vezelay', 'fr14a', 536.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR14a.rar'),
(@fr, 'Chemin Campaniensis', 'fr15a', 397.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR15a.rar'),
(@fr, 'Chemin Gy - Vezelay', 'fr16a', 210.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR16a.rar'),
(@fr, 'Chemin Vezelay - Le Puy', 'fr17a', 439.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR17a.rar'),
(@fr, 'Chemin Trier - Le Puy', 'fr18a', 848.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR18a.rar'),
(@fr, 'Chemin Horbach - Metz', 'fr19a', 217.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR19a.rar'),
(@fr, 'Chemin Bad Bergzabern - Beaune', 'fr20a', 538.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR20a.rar'),
(@fr, 'La Voie Senonensis de Paris - Vezelay', 'fr21a', 252.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR21a.rar'),
(@fr, 'Chemin Firmi - Toulouse', 'fr22a', 202.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR22a.rar'),
(@fr, 'Via Domitia - Sestriere-Arles', 'fr23a', 426.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR23a.rar'),
(@fr, 'Le Chemin de Regordane - Le Puy - Arles', 'fr24a', 240.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR24a.rar'),
(@fr, 'Chemin Meurchin - Thievres', 'fr25a', 74.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR25a.rar'),
(@fr, 'Voie de Garonne - Toulouse-St Gaudens', 'fr26a', 129.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR26a.rar'),
(@fr, 'Chemin Maubourguet - Lourdes', 'fr27a', 63.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR27a.rar'),
(@fr, 'Via Aurelia - Ventimiglia-Arles', 'fr28a', 385.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR28a.rar'),
(@fr, 'Via Gebennensis - Geneve-LePuy', 'fr29a', 396.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR29a.rar'),
(@fr, 'La Voie des Plantagenets', 'fr30a', 559.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR30a.rar'),
(@fr, 'Voie De la Pointe - Saint Mathieu a Clisson', 'fr31a', 533.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR31a.rar'),
(@fr, 'La Voie Locquirec ou Mogueriec', 'fr32a', 501.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR32a.rar'),
(@fr, 'La Voie de l''Abbaye de Beauport', 'fr33a', 403.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR33a.rar'),
(@fr, 'La Vie des Capitales', 'fr34a', 350.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR34a.rar'),
(@fr, 'Chemin Bergerac - Montreal du Gers', 'fr35a', 182.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR35a.rar'),
(@fr, 'La Voie Pays Mogueriec - Morlaix', 'fr36a', 35.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR36a.rar'),
(@fr, 'Chemin Rouen - Chartres', 'fr37a', 154.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR37a.rar'),
(@fr, 'Chemin Sancoins a Clermont-Ferrand', 'fr38a', 198.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR38a.rar'),
(@fr, 'Via Arverna - Clermont-Ferrand-Cahors', 'fr39a', 535.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR39a.rar'),
(@fr, 'Voie de Rocamadour en Limousin et Haut Quercy', 'fr40a', 548.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR40a.rar'),
(@fr, 'Voie de Rocamadour - Cahors', 'fr41a', 69.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR41a.rar'),
(@fr, 'Voie Figeac - Rocamadour', 'fr42a', 56.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR42a.rar'),
(@fr, 'Voie Bergerac - Rocamadour', 'fr43a', 166.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR43a.rar'),
(@fr, 'Voie Col d''Ourdiss - Lortet-Port d''Ourdiss', 'fr44a', 59.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR44a.rar'),
(@fr, 'Voie Arudy - Col du Somport', 'fr45a', 59.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR45a.rar'),
(@fr, 'Chemin de Fontcaude Saint Gervais sur Mare - Capestang', 'fr46a', 55.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR46a.rar'),
(@fr, 'Chemin Vallee du Cele - Bach Cahors', 'fr47a', 54.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR47a.rar'),
(@fr, 'Chemin Beduer - Bouzies', 'fr48a', 54.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR48a.rar'),
(@fr, 'Le Grand Chemin Montois - Mont Saint Michel Tours', 'fr49a', 342.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR49a.rar'),
(@fr, 'Ouistreham Caen - Le Mans', 'fr50a', 353.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR50a.rar'),
(@fr, 'Voie Basel - Hericourt', 'fr51a', 86.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR51a.rar'),
(@fr, 'Chemin Orcival Rocamadour', 'fr52a', 348.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR52a.rar'),
(@fr, 'Chemin Geneve LePuy', 'fr53a', 342.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR53a.rar'),
(@fr, 'Chemin Guillonay LePuy', 'fr54a', 289.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR54a.rar'),
(@fr, 'Chemin Cluny LePuy', 'fr55a', 296.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR55a.rar'),
(@fr, 'Chemin Lyon La Roche de Glun', 'fr56a', 141.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR56a.rar'),
(@fr, 'Chemin Guillonay-Arles', 'fr57a', 413.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR57a.rar'),
(@fr, 'Chemin Libercourt-Folleville', 'fr58a', 232.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR58a.rar'),
(@fr, 'Chemin Beauvais-Baillon', 'fr59a', 52.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR59a.rar'),
(@fr, 'Chemin Amiens-Rouen', 'fr60a', 162.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR60a.rar'),
(@fr, 'Chemin Amiens-Chartres', 'fr61a', 261.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/FR61a.rar');

-- ============================================================
-- PORTUGAL — 9 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@pt, 'Caminho Central Regiao Centro e Norte', 'pt01a', 499.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT01a.rar'),
(@pt, 'Caminho Portugues Interior a Santiago', 'pt02a', 243.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT02a.rar'),
(@pt, 'Caminho da Costa', 'pt03a', 136.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT03a.rar'),
(@pt, 'Caminho Portugues Porto - Braga - Ponte de Lima', 'pt05a', 100.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT05a.rar'),
(@pt, 'Camino Torres', 'pt06a', 392.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT06a.rar'),
(@pt, 'Caminho Portugues de la Via de la Plata', 'pt07a', 232.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT07a.rar'),
(@pt, 'Caminho Central Alentejo e Ribatejo', 'pt08a', 508.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT08a.rar'),
(@pt, 'Caminho Nascente', 'pt09a', 663.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT09a.rar'),
(@pt, 'Caminho Central Via Atlantico', 'pt10a', 135.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PT10a.rar');

-- ============================================================
-- ITALIE — 18 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@it, 'Via Francigena Roma - Sarzana', 'it01a', 527.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT01a.rar'),
(@it, 'Via della Costa - Sarzana-Ventimiglia', 'it02a', 310.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT02a.rar'),
(@it, 'Via Francigena Nord - Sarzana-Montgenevre', 'it03a', 615.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT03a.rar'),
(@it, 'Via Francigena Sud - Brindisi-Roma', 'it04a', 685.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT04a.rar'),
(@it, 'Cammino di Santu Jacu centrale Cagliari - Porto Torres', 'it05a', 532.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05a.rar'),
(@it, 'Cammino di Santu Jacu Braccio sudovest - Capoterra-CarloForte', 'it05b', 247.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05b.rar'),
(@it, 'Cammino di Santu Jacu Braccio lateral nordest - Olbia-Orosei', 'it05c', 373.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05c.rar'),
(@it, 'Cammino di Santu Jacu Braccio lateral nordovest - Oristano-Bolotana', 'it05d', 149.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT05d.rar'),
(@it, 'Via Micaelica - Roma-Monte Sant''Angelo', 'it07a', 404.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT07a.rar'),
(@it, 'Via Postumia - Aquileia-Genova', 'it09a', 958.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT09a.rar'),
(@it, 'Romea Strata - Via Allemagna', 'it13a', 192.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13a.rar'),
(@it, 'Romea Strata - Via Romea Annia', 'it13b', 265.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13b.rar'),
(@it, 'Romea Strata - Via Romea Aquileiense', 'it13c', 105.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13c.rar'),
(@it, 'Romea Strata - Via Romea Longobarda', 'it13d', 398.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13d.rar'),
(@it, 'Romea Strata - Via Romea Vicetia', 'it13f', 106.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT13f.rar'),
(@it, 'Via Romea Germanica - Brennero-Padova', 'it16a', 322.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT16a.rar'),
(@it, 'Il Cammino di San Giacomo in Sicilia', 'it32a', 486.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT32a.rar'),
(@it, 'Cammino di San Jacopo', 'it33a', 173.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IT33a.rar');

-- ============================================================
-- ALLEMAGNE — 48 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@de, 'Via Baltica - Swinemunde-Osnabruck', 'de01a', 817.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE01a.rar'),
(@de, 'Via Scandinavica - Fehmarn-Creuzburg', 'de02a', 624.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE02a.rar'),
(@de, 'Via Jutlandica a Padborg-Lubeck', 'de03a', 156.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE03a.rar'),
(@de, 'Via Jutlandica b Padborg-Harsefeld', 'de04a', 217.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE04a.rar'),
(@de, 'Jakobsweg Osnabruck - Aachen', 'de05a', 603.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE05a.rar'),
(@de, 'Jakobsweg Nijmegen - Koln', 'de06a', 204.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE06a.rar'),
(@de, 'Jakobsweg Stettin - Berlin', 'de07a', 213.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE07a.rar'),
(@de, 'Jakobsweg Frankfurt an der Oder - Berlin', 'de08a', 112.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE08a.rar'),
(@de, 'Jakobsweg Bad Wilsnack - Berlin', 'de09a', 139.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE09a.rar'),
(@de, 'Jakobsweg Rostock-Bad Wilsnack', 'de10a', 182.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE10a.rar'),
(@de, 'Jakobsweg Frankfurt an der Oder - Berlin-Tangermunde', 'de11a', 143.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE11a.rar'),
(@de, 'Jakobsweg Bad Wilsnack - Freyburg', 'de12a', 433.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE12a.rar'),
(@de, 'Jakobsweg Halberstadt - Dortmund', 'de13a', 313.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE13a.rar'),
(@de, 'Jakobsweg Frankfurt an der Oder - Leipzig', 'de14a', 234.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE14a.rar'),
(@de, 'Jakobsweg Berlin - Leipzig', 'de15a', 208.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE15a.rar'),
(@de, 'Via Regia - Gorlitz-Fulda', 'de16a', 527.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE16a.rar'),
(@de, 'Sachsischer Jakobsweg Bautzen - Hof', 'de17a', 285.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE17a.rar'),
(@de, 'Jakobsweg Leipzig - Zwickau', 'de18a', 105.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE18a.rar'),
(@de, 'Jakobsweg Paderborn - Koln', 'de19a', 234.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE19a.rar'),
(@de, 'Jakobsweg Eisenach - Koln', 'de20a', 340.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE20a.rar'),
(@de, 'Via Imperii - Hof-Nurnberg', 'de21a', 183.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE21a.rar'),
(@de, 'Jakobsweg Erfurt - Nurnberg', 'de22a', 223.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE22a.rar'),
(@de, 'Jakobsweg Bamberg - Uffenheim', 'de23a', 99.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE23a.rar'),
(@de, 'Jakobsweg Fulda Mainz', 'de24a', 165.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE24a.rar'),
(@de, 'Jakobsweg Fulda - Wurzburg', 'de25a', 155.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE25a.rar'),
(@de, 'Jakobsweg Koln - Metz', 'de26a', 393.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE26a.rar'),
(@de, 'Jakobsweg Andernach - Trier', 'de27a', 120.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE27a.rar'),
(@de, 'Jakobsweg Mainz - Trier', 'de28a', 159.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE28a.rar'),
(@de, 'Frankisch Schwabischer Jakobsweg Wurzburg - Ulm', 'de29a', 270.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE29a.rar'),
(@de, 'Oberpfalzer Jakobsweg - Tillyschanz-Nurnberg', 'de30a', 177.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE30a.rar'),
(@de, 'Jakobsweg Nurnberg - Rothenburg', 'de31a', 86.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE31a.rar'),
(@de, 'Jakobsweg Rothenburg - Metz', 'de32a', 549.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE32a.rar'),
(@de, 'Jakobsweg Nurnberg - Eichstatt', 'de33a', 55.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE33a.rar'),
(@de, 'Jakobsweg Nurnberg - Konstanz', 'de34a', 381.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE34a.rar'),
(@de, 'Ostbayrischer Jakobsweg Vseruby - Donauworth', 'de35a', 271.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE35a.rar'),
(@de, 'Jakobsweg Nordlingen - Kempten', 'de36a', 339.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE36a.rar'),
(@de, 'Jakobsweg Rothenburg - Rottenburg', 'de37a', 196.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE37a.rar'),
(@de, 'Kinzigtaler Jakobsweg - Horb am Neckar-Strasbourg', 'de38a', 146.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE38a.rar'),
(@de, 'Jakobsweg Mainz - Speyer', 'de39a', 100.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE39a.rar'),
(@de, 'Jakobsweg Weinstadt - Neckartenzlingen', 'de40a', 112.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE40a.rar'),
(@de, 'Jakobsweg Rottenburg - Blumberg', 'de41a', 148.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE41a.rar'),
(@de, 'Jakobsweg Hufingen - Basel', 'de42a', 191.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE42a.rar'),
(@de, 'Jakobsweg St Oswald bei Haslach - Peissenberg', 'de43a', 496.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE43a.rar'),
(@de, 'Munchener Jakobsweg - Munchen-Bregenz', 'de44a', 570.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE44a.rar'),
(@de, 'Jakobsweg Salzburg - Bad Aibling', 'de45a', 135.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE45a.rar'),
(@de, 'Badischer Jakobsweg Ettlingen - Breisach', 'de46a', 140.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE46a.rar'),
(@de, 'Jakobsweg Wolfach-Thann', 'de47a', 183.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE47a.rar'),
(@de, 'Zittauer Jakobsweg', 'de48a', 47.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DE48a.rar');

-- ============================================================
-- BELGIQUE — 14 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@be, 'Via Brabantica', 'be01a', 435.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE01a.rar'),
(@be, 'Via Limburgica', 'be02a', 259.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE02a.rar'),
(@be, 'Via Monastica', 'be03a', 283.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE03a.rar'),
(@be, 'Via Mosana-2', 'be03b', 93.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE03b.rar'),
(@be, 'Via Scaldea', 'be04a', 277.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE04a.rar'),
(@be, 'Via Thierache', 'be05a', 134.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE05a.rar'),
(@be, 'Via Brugensis', 'be06a', 198.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE06a.rar'),
(@be, 'Via Mosana', 'be07a', 960.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE07a.rar'),
(@be, 'Via Tenera', 'be08a', 391.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE08a.rar'),
(@be, 'Via Yprensis Nieuwpoort-Wervik', 'be09a', 71.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE09a.rar'),
(@be, 'Via Lovaniensis Mechelen-Helecine', 'be10a', 65.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE10a.rar'),
(@be, 'Arras Epernon', 'be11a', 281.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE11a.rar'),
(@be, 'Arras Saint Quentin-Reims', 'be12a', 228.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE12a.rar'),
(@be, 'Via Gallia Belgica', 'be13a', 240.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/BE13a.rar');

-- ============================================================
-- PAYS-BAS — 7 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@nl, 'Jacobsweg Amstelredam Den Oever - Postel', 'nl01a', 410.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL01a.rar'),
(@nl, 'Jacobsweg Amsvorde - Uithuizen Kapellen', 'nl02a', 498.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL02a.rar'),
(@nl, 'Jacobsweg Audenzeel Oldenzaal - Doesburg', 'nl03a', 95.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL03a.rar'),
(@nl, 'Jacobsweg DieHage Haarlem - Brugge Gent', 'nl04a', 286.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL04a.rar'),
(@nl, 'Jacobsweg Nieumeghen Hasselt - Eijsden', 'nl05a', 686.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL05a.rar'),
(@nl, 'Jacobsweg Thuredrecht - Schipluiden Kapellen', 'nl06a', 153.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL06a.rar'),
(@nl, 'Jacobsweg Afsluitdijk DenOever - Sint Jacobiparochie', 'nl07a', 64.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/NL07a.rar');

-- ============================================================
-- SUISSE — 4 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@ch, 'Via Jacobi Rorschach - Einsiedeln', 'ch01a', 110.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01a.rar'),
(@ch, 'Via Jacobi Einsiedeln - Geneve', 'ch01b', 428.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01b.rar'),
(@ch, 'Via Jacobi Konstanz - Einsiedeln', 'ch01c', 88.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01c.rar'),
(@ch, 'Via Jacobi Luzern - Fribourg', 'ch01d', 132.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CH01d.rar');

-- ============================================================
-- IRLANDE — 4 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@ie, 'Boyne Valley Camino', 'ie01a', 22.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE01a.rar'),
(@ie, 'Bray Coastal Camino', 'ie02a', 31.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE02a.rar'),
(@ie, 'Croagh Patrick Heritage Trail', 'ie03a', 60.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE03a.rar'),
(@ie, 'Saint Declan''s Way', 'ie04a', 115.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/IE04a.rar');

-- ============================================================
-- AUTRICHE — 12 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@at, 'Jakobsweg Bohmerwald St.Oswald bei Haslach - Passau', 'at01a', 92.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT01a.rar'),
(@at, 'Jakobsweg Muhlviertel Kautzen - Pyburg', 'at02a', 163.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT02a.rar'),
(@at, 'Jakobsweg Weinviertel Drasenhofen - Krems', 'at03a', 154.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT03a.rar'),
(@at, 'Jakobsweg Wolfsthal - Lofer', 'at04a', 611.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT04a.rar'),
(@at, 'Jakobsweg Pamhagen - Maria Ellend', 'at05a', 76.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT05a.rar'),
(@at, 'Jakobsweg Innviertel Passau - Salzburg', 'at06a', 145.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT06a.rar'),
(@at, 'Jakobsweg Tirol Lofer - Innsbruck', 'at07a', 300.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT07a.rar'),
(@at, 'Jakobsweg Weststeiermark Graz - Lavamund', 'at08a', 152.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT08a.rar'),
(@at, 'Jakobsweg Karnten Dravograd - Nikolsdorf', 'at09a', 300.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT09a.rar'),
(@at, 'Jakobsweg Nikolsdorf - Innsbruck', 'at10a', 245.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT10a.rar'),
(@at, 'Jakobsweg Vorarlberg Pettneu - Rankweil', 'at11a', 115.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT11a.rar'),
(@at, 'Jakobsweg Vorarlberg Missen - Bregenz - Widnau', 'at11b', 117.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/AT11b.rar');

-- ============================================================
-- POLOGNE — 31 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@pl, 'Dolnoslaska Droga sw. Jakuba', 'pl01a', 159.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL01a.rar'),
(@pl, 'Droga Polska (Camino Polaco)', 'pl02a', 671.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL02a.rar'),
(@pl, 'Wielkopolska Droga sw. Jakuba', 'pl03a', 292.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL03a.rar'),
(@pl, 'Droga sw. Jakuba Via Regia', 'pl04a', 1005.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL04a.rar'),
(@pl, 'Pomorska Droga sw. Jakuba (Via Baltica)', 'pl05a', 696.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL05a.rar'),
(@pl, 'Via Imperii', 'pl06a', 23.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL06a.rar'),
(@pl, 'Lubelska Droga sw. Jakuba', 'pl07a', 145.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL07a.rar'),
(@pl, 'Malopolska Droga sw. Jakuba', 'pl08a', 324.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL08a.rar'),
(@pl, 'Tarnobrzeska droga sw. Jakuba', 'pl09a', 20.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL09a.rar'),
(@pl, 'Swietokrzyska Droga sw. Jakuba', 'pl10a', 333.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL10a.rar'),
(@pl, 'Beskidzka droga sw. Jakuba', 'pl11a', 289.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL11a.rar'),
(@pl, 'Jasnogorska droga sw. Jakuba', 'pl12a', 57.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL12a.rar'),
(@pl, 'Czestochowska droga sw. Jakuba', 'pl13a', 103.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL13a.rar'),
(@pl, 'Slasko Morawska droga sw. Jakuba', 'pl14a', 95.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL14a.rar'),
(@pl, 'Raciborska droga sw. Jakuba', 'pl15a', 107.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL15a.rar'),
(@pl, 'Nyska droga sw. Jakuba', 'pl16a', 97.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL16a.rar'),
(@pl, 'Sudecka droga sw. Jakuba', 'pl17a', 221.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL17a.rar'),
(@pl, 'Slezanska droga sw. Jakuba', 'pl18a', 51.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL18a.rar'),
(@pl, 'Scinawska droga sw. Jakuba', 'pl19a', 51.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL19a.rar'),
(@pl, 'Lubuska droga sw. Jakuba', 'pl20a', 361.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL20a.rar'),
(@pl, 'Warszawska droga sw. Jakuba', 'pl21a', 382.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL21a.rar'),
(@pl, 'Mazowiecka droga sw. Jakuba', 'pl22a', 167.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL22a.rar'),
(@pl, 'Dobrzynsko-Kujawska droga sw. Jakuba', 'pl23a', 108.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL23a.rar'),
(@pl, 'Bydgoska droga sw. Jakuba', 'pl24a', 86.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL24a.rar'),
(@pl, 'Nadwarcianska droga sw. Jakuba', 'pl25a', 108.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL25a.rar'),
(@pl, 'Lowicka droga sw. Jakuba', 'pl26a', 225.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL26a.rar'),
(@pl, 'Kaliska droga sw. Jakuba', 'pl27a', 154.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL27a.rar'),
(@pl, 'Pelplinska droga sw. Jakuba', 'pl28a', 114.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL28a.rar'),
(@pl, 'Czluchowska droga sw. Jakuba', 'pl29a', 209.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL29a.rar'),
(@pl, 'Nadsanska droga sw. Jakuba', 'pl30a', 102.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL30a.rar'),
(@pl, 'Podlaska droga sw. Jakuba', 'pl31a', 473.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/PL31a.rar');

-- ============================================================
-- REPUBLIQUE TCHEQUE — 6 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@cz, 'Zitavska trasa', 'cz01a', 151.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ01a.rar'),
(@cz, 'Vserubska trasa', 'cz02a', 206.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ02a.rar'),
(@cz, 'Zelezna trasa', 'cz03a', 258.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ03a.rar'),
(@cz, 'Vychodoceska trasa', 'cz04a', 265.6, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ04a.rar'),
(@cz, 'Jihoceska trasa', 'cz05a', 214.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ05a.rar'),
(@cz, 'Moravskoslezska trasa', 'cz06a', 276.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/CZ06a.rar');

-- ============================================================
-- HONGRIE — 3 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@hu, 'Camino Hungaro', 'hu01a', 273.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU01a.rar'),
(@hu, 'Camino Benedictus', 'hu02a', 211.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU02a.rar'),
(@hu, 'Via Peregrinus', 'hu03a', 114.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HU03a.rar');

-- ============================================================
-- SLOVENIE — 5 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@si, 'Dolenjska Veja', 'si01a', 171.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI01a.rar'),
(@si, 'Primorska Veja', 'si01b', 145.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI01b.rar'),
(@si, 'Gorenjska Veja', 'si02a', 182.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI02a.rar'),
(@si, 'Prekmurska in Stajerska Veja', 'si03a', 288.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI03a.rar'),
(@si, 'Preddvorska Veja', 'si04a', 59.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SI04a.rar');

-- ============================================================
-- CROATIE — 17 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@hr, 'Camino Podravina', 'hr01a', 154.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR01a.rar'),
(@hr, 'Camino Medimurje', 'hr02a', 51.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR02a.rar'),
(@hr, 'Hrvatsko Zagorje', 'hr03a', 56.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR03a.rar'),
(@hr, 'Camino Samobor', 'hr04a', 60.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR04a.rar'),
(@hr, 'Camino Krizevci', 'hr05a', 61.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR05a.rar'),
(@hr, 'Camino Banovina', 'hr06a', 74.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR06a.rar'),
(@hr, 'Camino Gorski-Kotar', 'hr07a', 346.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR07a.rar'),
(@hr, 'Camino Imota', 'hr08a', 72.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR08a.rar'),
(@hr, 'Camino Srednja-Dalmacija', 'hr09a', 120.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR09a.rar'),
(@hr, 'Camino Sibenik', 'hr10a', 108.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR10a.rar'),
(@hr, 'Camino Zadar', 'hr11a', 143.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR11a.rar'),
(@hr, 'Camino Lika', 'hr12a', 434.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR12a.rar'),
(@hr, 'Camino South-Istria', 'hr13a', 192.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR13a.rar'),
(@hr, 'Camino North-Istria', 'hr14a', 37.1, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR14a.rar'),
(@hr, 'Camino Korcula', 'hr15a', 156.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR15a.rar'),
(@hr, 'Camino Krk', 'hr16a', 161.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR16a.rar'),
(@hr, 'Camino Brac', 'hr17a', 157.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/HR17a.rar');

-- ============================================================
-- SLOVAQUIE — 1 route
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@sk, 'Svatojakubska cesta na Slovensku', 'sk01a', 760.8, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/SK01a.rar');

-- ============================================================
-- DANEMARK — 9 routes
-- ============================================================
INSERT INTO routes (country_id, name, slug, total_km, gpx_file) VALUES
(@dk, 'Den Danske Pilgrimsrute Sydfyn', 'dk01a', 146.0, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK01a.rar'),
(@dk, 'Den Danske Pilgrimsrute Sydsjaelland', 'dk02a', 154.7, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK02a.rar'),
(@dk, 'Den Danske Pilgrimsrute Midtjylland', 'dk03a', 153.2, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK03a.rar'),
(@dk, 'Den Danske Pilgrimsrute Ostsjaelland', 'dk04a', 52.3, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK04a.rar'),
(@dk, 'Den Danske Pilgrimsrute Vestsjaelland', 'dk05a', 112.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK05a.rar'),
(@dk, 'Den Danske Pilgrimsrute Nordsjaelland', 'dk06a', 115.5, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK06a.rar'),
(@dk, 'Den Danske Pilgrimsrute Sonderjylland', 'dk07a', 141.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK07a.rar'),
(@dk, 'Den Danske Pilgrimsrute Ost og Vestfyn', 'dk08a', 166.9, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK08a.rar'),
(@dk, 'Den Danske Pilgrimsrute Nordjylland Ost', 'dk09a', 136.4, 'https://www.caminosantiago.org/cpperegrino/caminos/tracks/DK09a.rar');

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'COUNTRIES' AS type, COUNT(*) AS total FROM countries
UNION ALL
SELECT 'ROUTES' AS type, COUNT(*) AS total FROM routes;

SELECT c.code_iso, c.name_fr, COUNT(r.id) AS nb_routes, ROUND(SUM(r.total_km),0) AS total_km
FROM countries c
LEFT JOIN routes r ON r.country_id = c.id
GROUP BY c.id
ORDER BY c.priority;
