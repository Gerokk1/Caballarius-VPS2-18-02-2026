# SKILL 00-import-gpx

## Description
Importe les localites depuis les fichiers KML (archives .rar) de caminosantiago.org
pour les 305 routes de pelerinage europeennes stockees dans caballarius_staging.

## Source des donnees
- **caminosantiago.org** : 305 archives .rar contenant des fichiers KML par etape
- Format : KML avec `<LineString><coordinates>` (lng,lat,alt)
- Noms de fichiers : `{ROUTE_SLUG}{STAGE}{VARIANT}-{Depart}-{Arrivee}.kml`

## Pipeline
1. Telecharge les 305 .rar depuis les URLs dans `routes.gpx_file`
2. Extrait les KML de chaque archive (unrar)
3. Parse les coordonnees KML (premier/dernier point de chaque etape)
4. Deduplique les localites proches (rayon 500m)
5. Geocode inversement via Nominatim (noms propres des localites)
6. Insere dans `localities` + `route_localities`

## Dependances
- Python 3.12 + venv
- Packages : gpxpy, requests, pymysql
- Systeme : unrar
- API : Nominatim (gratuit, 1 req/sec)

## Usage
```bash
# Activer le venv
source /data/openclaw/workspace/skills/00-import-gpx/venv/bin/activate

# Run complet (305 routes, ~45min avec geocoding)
python3 import_gpx.py

# Test sur une seule route
python3 import_gpx.py --route es01a --dry-run

# Sans geocoding (rapide, noms approximatifs)
python3 import_gpx.py --skip-geocode

# Reprendre apres interruption (les .rar deja telecharges sont caches)
python3 import_gpx.py --skip-download
```

## Tables alimentees
- `localities` : name, slug, lat, lng, altitude, type
- `route_localities` : route_id, locality_id, km_from_start, order_on_route

## Fichiers
- `import_gpx.py` : script principal
- `SKILL.md` : cette documentation
- `state.json` : etat de progression (telecharges, geocodes)
- `import.log` : log detaille
- `downloads/` : cache des .rar telecharges
- `extracted/` : KML extraits (par route)
- `venv/` : environnement Python
