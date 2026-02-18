#!/usr/bin/env python3
"""
SKILL 00-import-gpx — Import localities from caminosantiago.org KML files
Caballarius VPS2 — /data/openclaw/workspace/skills/00-import-gpx/

Downloads .rar archives containing KML stage files for 305 European
pilgrimage routes. Parses coordinates, deduplicates localities,
reverse-geocodes via Nominatim, and populates the DB.

Usage:
    python3 import_gpx.py                    # Full run
    python3 import_gpx.py --skip-download    # Use cached .rar files
    python3 import_gpx.py --skip-geocode     # Use filename hints only
    python3 import_gpx.py --route es01a      # Process single route
    python3 import_gpx.py --dry-run          # Parse only, no DB writes
    python3 import_gpx.py --batch 10         # Process first 10 routes
"""

import os
import sys
import re
import subprocess
import time
import math
import json
import logging
import argparse
import unicodedata
from pathlib import Path

import requests
import xml.etree.ElementTree as ET
import pymysql

# ─── Configuration ───────────────────────────────────────────────────────────

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'cblrs_user'),
    'password': os.environ.get('DB_PASS', ''),
    'database': os.environ.get('DB_NAME', 'caballarius_staging'),
    'charset': 'utf8mb4',
}

BASE_DIR = Path('/data/openclaw/workspace/skills/00-import-gpx')
DOWNLOAD_DIR = BASE_DIR / 'downloads'
EXTRACT_DIR = BASE_DIR / 'extracted'
STATE_FILE = BASE_DIR / 'state.json'
LOG_FILE = BASE_DIR / 'import.log'

NOMINATIM_URL = 'https://nominatim.openstreetmap.org/reverse'
NOMINATIM_HEADERS = {'User-Agent': 'Caballarius/1.0 (pilgrimage-routes@cblrs.net)'}
NOMINATIM_DELAY = 1.1  # seconds between requests (Nominatim policy)

DEDUP_RADIUS_KM = 0.5  # Points within 500m = same locality
DOWNLOAD_DELAY = 0.3    # seconds between downloads (be polite)

# ─── Logging ─────────────────────────────────────────────────────────────────

def setup_logging():
    BASE_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format='[%(asctime)s] %(levelname)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(LOG_FILE, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )

# ─── Database ────────────────────────────────────────────────────────────────

def get_db():
    return pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)

def fetch_routes(db, single_route=None):
    with db.cursor() as cur:
        if single_route:
            cur.execute(
                "SELECT id, country_id, name, slug, total_km, gpx_file "
                "FROM routes WHERE slug=%s", (single_route,))
        else:
            cur.execute(
                "SELECT id, country_id, name, slug, total_km, gpx_file "
                "FROM routes WHERE gpx_file IS NOT NULL ORDER BY id")
        return cur.fetchall()

# ─── Download & Extract ──────────────────────────────────────────────────────

def download_rar(url, dest_path):
    """Download a .rar file from caminosantiago.org"""
    resp = requests.get(url, timeout=60, headers={
        'User-Agent': 'Mozilla/5.0 (compatible; Caballarius/1.0)'
    })
    resp.raise_for_status()
    with open(dest_path, 'wb') as f:
        f.write(resp.content)
    return len(resp.content)

def extract_rar(rar_path, dest_dir):
    """Extract .rar using unrar, return list of KML filenames"""
    dest_dir.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        ['unrar', 'e', '-o+', str(rar_path), str(dest_dir) + '/'],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise RuntimeError(f"unrar error: {result.stderr}")
    return sorted([f for f in os.listdir(dest_dir) if f.lower().endswith('.kml')])

# ─── KML Parsing ─────────────────────────────────────────────────────────────

def parse_kml(kml_path):
    """Parse KML file, return list of (lat, lng, alt) coordinates"""
    try:
        tree = ET.parse(kml_path)
    except ET.ParseError as e:
        logging.warning(f"  XML parse error in {kml_path}: {e}")
        return []

    root = tree.getroot()
    all_coords = []

    for elem in root.iter():
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        if tag.lower() == 'coordinates' and elem.text:
            for point in elem.text.strip().split():
                parts = point.strip().split(',')
                if len(parts) >= 2:
                    try:
                        lng = float(parts[0])
                        lat = float(parts[1])
                        alt = float(parts[2]) if len(parts) > 2 else 0
                        all_coords.append((lat, lng, alt))
                    except ValueError:
                        continue
    return all_coords

def track_distance_km(coords):
    """Total distance of a track in km from coordinate list"""
    total = 0.0
    for i in range(1, len(coords)):
        total += haversine(coords[i-1][0], coords[i-1][1],
                           coords[i][0], coords[i][1])
    return total

# ─── Filename Parsing ────────────────────────────────────────────────────────

def parse_stage_filename(filename, route_slug):
    """
    Parse KML filename to extract stage number and locality name hints.
    e.g. 'ES01a01a-SaintJeanPieddePort-Roncesvalles.kml'
    → {'stage': 1, 'variant': 'a', 'start_hint': '...', 'end_hint': '...'}
    """
    name = Path(filename).stem
    prefix = route_slug.upper()

    if not name.upper().startswith(prefix):
        return None

    rest = name[len(prefix):]  # e.g. '01a-SaintJeanPieddePort-Roncesvalles'

    match = re.match(r'(\d+)([a-z]?)-(.+)', rest)
    if not match:
        return None

    stage_num = int(match.group(1))
    variant = match.group(2) or 'a'
    locality_part = match.group(3)

    # Split on '-' for start-end (first dash = separator)
    parts = locality_part.split('-', 1)
    start_hint = camelcase_split(parts[0])
    end_hint = camelcase_split(parts[1]) if len(parts) > 1 else None

    return {
        'stage': stage_num,
        'variant': variant,
        'start_hint': start_hint,
        'end_hint': end_hint,
    }

def camelcase_split(s):
    """Split CamelCase into readable name.
    'SaintJeanPieddePort' → 'Saint Jean Pied de Port'
    'DEpernon' → 'D Epernon'
    """
    if not s:
        return s
    # Insert space before uppercase after lowercase
    result = re.sub(r'([a-z])([A-Z])', r'\1 \2', s)
    # Handle consecutive uppercase: 'DEpernon' → 'D Epernon'
    result = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1 \2', result)
    return result.strip()

# ─── Geo Utilities ───────────────────────────────────────────────────────────

def haversine(lat1, lng1, lat2, lng2):
    """Distance in km between two GPS points"""
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlng / 2) ** 2)
    return R * 2 * math.asin(math.sqrt(min(1.0, a)))

def reverse_geocode(lat, lng):
    """Reverse geocode using OpenStreetMap Nominatim (free, 1 req/sec)"""
    try:
        resp = requests.get(NOMINATIM_URL, params={
            'lat': lat, 'lon': lng,
            'format': 'json', 'zoom': 16,
            'addressdetails': 1,
        }, headers=NOMINATIM_HEADERS, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        addr = data.get('address', {})

        # Pick the most relevant locality name
        name = (addr.get('village') or addr.get('town') or
                addr.get('city') or addr.get('municipality') or
                addr.get('hamlet') or addr.get('suburb') or
                addr.get('locality') or
                data.get('display_name', '').split(',')[0])

        # Determine type
        loc_type = 'village'
        if addr.get('city'):
            pop = 50000  # approximate
            loc_type = 'city'
        elif addr.get('town'):
            loc_type = 'town'
        elif addr.get('hamlet'):
            loc_type = 'hamlet'
        elif addr.get('isolated_dwelling'):
            loc_type = 'lieu-dit'

        return {'name': name.strip() if name else None, 'type': loc_type}

    except Exception as e:
        logging.warning(f"  Geocode failed ({lat:.5f}, {lng:.5f}): {e}")
        return None

# ─── Deduplication ───────────────────────────────────────────────────────────

def find_nearby_idx(lat, lng, localities, radius_km=DEDUP_RADIUS_KM):
    """Find index of an existing locality within radius_km, or -1"""
    for i, loc in enumerate(localities):
        if haversine(lat, lng, loc['lat'], loc['lng']) < radius_km:
            return i
    return -1

# ─── Slugify ─────────────────────────────────────────────────────────────────

def slugify(name):
    """URL-safe slug from a locality name"""
    s = unicodedata.normalize('NFKD', name).encode('ascii', 'ignore').decode('ascii')
    s = re.sub(r'[^\w\s-]', '', s.lower())
    s = re.sub(r'[\s_]+', '-', s)
    return re.sub(r'-+', '-', s).strip('-') or 'unnamed'

def unique_slug(name, existing_slugs):
    """Generate a unique slug, appending -2, -3, etc. if needed"""
    base = slugify(name)
    slug = base
    n = 2
    while slug in existing_slugs:
        slug = f"{base}-{n}"
        n += 1
    existing_slugs.add(slug)
    return slug

# ─── State Persistence ───────────────────────────────────────────────────────

def load_state():
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text(encoding='utf-8'))
        except json.JSONDecodeError:
            logging.warning("Corrupt state file, starting fresh")
    return {'downloaded': [], 'geocoded': {}}

def save_state(state):
    STATE_FILE.write_text(json.dumps(state, indent=2, ensure_ascii=False),
                          encoding='utf-8')

# ─── Route Processing ────────────────────────────────────────────────────────

def process_route(route, state, skip_download=False):
    """
    Download .rar → extract KML → parse stages → return list of points.
    Each point: {route_id, lat, lng, alt, hint, km_from_start, order}
    """
    slug = route['slug']
    url = route['gpx_file']
    route_id = route['id']

    logging.info(f"[{slug}] {route['name']}")

    # 1. Download
    rar_path = DOWNLOAD_DIR / f"{slug}.rar"
    if not skip_download and slug not in state['downloaded']:
        DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
        try:
            size = download_rar(url, rar_path)
            state['downloaded'].append(slug)
            logging.info(f"  Downloaded {size:,} bytes")
            time.sleep(DOWNLOAD_DELAY)
        except Exception as e:
            logging.error(f"  Download FAILED: {e}")
            return []
    elif not rar_path.exists():
        logging.warning(f"  RAR not found and download skipped: {rar_path}")
        return []

    # 2. Extract
    extract_dir = EXTRACT_DIR / slug
    try:
        kml_files = extract_rar(rar_path, extract_dir)
        logging.info(f"  Extracted {len(kml_files)} KML files")
    except Exception as e:
        logging.error(f"  Extract FAILED: {e}")
        return []

    if not kml_files:
        logging.warning(f"  No KML files found in archive")
        return []

    # 3. Parse each KML → build stage list
    stages = []
    for kml_file in kml_files:
        kml_path = extract_dir / kml_file
        coords = parse_kml(kml_path)
        if len(coords) < 2:
            logging.debug(f"  Skip {kml_file}: <2 coords")
            continue

        stage_info = parse_stage_filename(kml_file, slug)
        distance = track_distance_km(coords)

        stages.append({
            'filename': kml_file,
            'info': stage_info,
            'start': coords[0],     # (lat, lng, alt)
            'end': coords[-1],
            'distance_km': distance,
        })

    if not stages:
        logging.warning(f"  No valid stages parsed")
        return []

    # Sort by stage number, then variant
    def sort_key(s):
        info = s['info']
        if info:
            return (info['stage'], info['variant'])
        return (999, 'z')
    stages.sort(key=sort_key)

    # 4. Build route points from MAIN stages (variant 'a')
    main_stages = [s for s in stages
                   if s['info'] and s['info']['variant'] == 'a']

    # Fallback: if no 'a' variants found, use all stages
    if not main_stages:
        main_stages = stages

    route_points = []
    cumulative_km = 0.0

    for i, stage in enumerate(main_stages):
        info = stage['info']

        # Add START point (only for first stage)
        if i == 0:
            route_points.append({
                'route_id': route_id,
                'lat': round(stage['start'][0], 7),
                'lng': round(stage['start'][1], 7),
                'alt': int(stage['start'][2]),
                'hint': info['start_hint'] if info else None,
                'km_from_start': 0.0,
                'order': 0,
            })

        cumulative_km += stage['distance_km']

        # Add END point
        route_points.append({
            'route_id': route_id,
            'lat': round(stage['end'][0], 7),
            'lng': round(stage['end'][1], 7),
            'alt': int(stage['end'][2]),
            'hint': info['end_hint'] if info else None,
            'km_from_start': round(cumulative_km, 1),
            'order': i + 1,
        })

    logging.info(f"  {len(main_stages)} main stages, "
                 f"{len(route_points)} points, "
                 f"{round(cumulative_km, 1)} km")

    return route_points

# ─── Main Pipeline ───────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description='Import localities from caminosantiago.org KML archives')
    parser.add_argument('--skip-download', action='store_true',
                        help='Use cached .rar files')
    parser.add_argument('--skip-geocode', action='store_true',
                        help='Use filename hints instead of Nominatim')
    parser.add_argument('--route', type=str,
                        help='Process a single route slug')
    parser.add_argument('--dry-run', action='store_true',
                        help='Parse only, no DB writes')
    parser.add_argument('--batch', type=int, default=0,
                        help='Process N routes then stop')
    args = parser.parse_args()

    setup_logging()
    logging.info("=" * 60)
    logging.info("SKILL 00-import-gpx — STARTING")
    logging.info("=" * 60)

    state = load_state()
    db = get_db()

    # ── Phase 1: Fetch routes ──
    routes = fetch_routes(db, args.route)
    total = len(routes)
    logging.info(f"Routes to process: {total}")

    # ── Phase 2: Download + Extract + Parse ──
    all_points = []
    processed = 0
    for route in routes:
        if args.batch and processed >= args.batch:
            break
        points = process_route(route, state, args.skip_download)
        all_points.extend(points)
        processed += 1
        if processed % 20 == 0:
            save_state(state)
            logging.info(f"  --- Progress: {processed}/{total} routes ---")

    save_state(state)
    logging.info(f"Phase 2 done: {len(all_points)} raw points from {processed} routes")

    # ── Phase 3: Deduplicate ──
    logging.info("Deduplicating localities...")
    unique_localities = []  # [{'lat', 'lng', 'alt', 'hint', 'name', 'type'}]

    for pt in all_points:
        idx = find_nearby_idx(pt['lat'], pt['lng'], unique_localities)
        if idx >= 0:
            pt['locality_idx'] = idx
        else:
            pt['locality_idx'] = len(unique_localities)
            unique_localities.append({
                'lat': pt['lat'],
                'lng': pt['lng'],
                'alt': pt.get('alt', 0),
                'hint': pt.get('hint'),
                'name': None,
                'type': 'village',
            })

    logging.info(f"Unique localities: {len(unique_localities)} "
                 f"(from {len(all_points)} raw points)")

    # ── Phase 4: Reverse Geocode ──
    if not args.skip_geocode:
        logging.info("Reverse geocoding via Nominatim...")
        new_lookups = 0
        cached_hits = 0
        for i, loc in enumerate(unique_localities):
            cache_key = f"{loc['lat']:.5f},{loc['lng']:.5f}"

            # Check cache
            if cache_key in state.get('geocoded', {}):
                cached = state['geocoded'][cache_key]
                loc['name'] = cached['name']
                loc['type'] = cached['type']
                cached_hits += 1
                continue

            # Call Nominatim
            result = reverse_geocode(loc['lat'], loc['lng'])
            if result and result['name']:
                loc['name'] = result['name']
                loc['type'] = result['type']
                state.setdefault('geocoded', {})[cache_key] = result
            else:
                # Fallback to filename hint
                loc['name'] = loc.get('hint') or f"Point {loc['lat']:.4f} {loc['lng']:.4f}"

            new_lookups += 1
            if new_lookups % 100 == 0:
                logging.info(f"  Geocoded {new_lookups}/{len(unique_localities)} "
                             f"({cached_hits} cached)")
                save_state(state)

            time.sleep(NOMINATIM_DELAY)

        save_state(state)
        logging.info(f"Geocoding done: {new_lookups} new, {cached_hits} cached")
    else:
        logging.info("Geocoding SKIPPED — using filename hints")
        for loc in unique_localities:
            if not loc['name']:
                loc['name'] = loc.get('hint') or f"Point {loc['lat']:.4f} {loc['lng']:.4f}"

    # ── Phase 5: Insert into Database ──
    if args.dry_run:
        logging.info("[DRY RUN] Would insert:")
        logging.info(f"  {len(unique_localities)} localities")
        logging.info(f"  {len(all_points)} route_locality links")
        # Print sample
        for loc in unique_localities[:20]:
            logging.info(f"  - {loc['name']} ({loc['lat']:.5f}, {loc['lng']:.5f}) [{loc['type']}]")
        if len(unique_localities) > 20:
            logging.info(f"  ... and {len(unique_localities) - 20} more")
    else:
        logging.info("Inserting into database...")
        used_slugs = set()
        idx_to_dbid = {}

        with db.cursor() as cur:
            # Load existing slugs
            cur.execute("SELECT slug FROM localities")
            for row in cur.fetchall():
                used_slugs.add(row['slug'])

            # Insert localities
            inserted = 0
            reused = 0
            for idx, loc in enumerate(unique_localities):
                if not loc['name']:
                    loc['name'] = f"Point {loc['lat']:.4f} {loc['lng']:.4f}"

                slug = unique_slug(loc['name'], used_slugs)

                # Check if same coords already exist (within 100m)
                cur.execute(
                    "SELECT id FROM localities "
                    "WHERE ABS(lat - %s) < 0.001 AND ABS(lng - %s) < 0.001 "
                    "LIMIT 1",
                    (loc['lat'], loc['lng']))
                existing = cur.fetchone()

                if existing:
                    idx_to_dbid[idx] = existing['id']
                    reused += 1
                else:
                    cur.execute(
                        "INSERT INTO localities "
                        "(name, slug, lat, lng, altitude, type, scrape_status) "
                        "VALUES (%s, %s, %s, %s, %s, %s, 'pending')",
                        (loc['name'], slug, loc['lat'], loc['lng'],
                         loc['alt'], loc['type']))
                    idx_to_dbid[idx] = cur.lastrowid
                    inserted += 1

                if (inserted + reused) % 200 == 0:
                    db.commit()
                    logging.info(f"  Localities: {inserted} inserted, {reused} reused")

            db.commit()
            logging.info(f"Localities: {inserted} inserted, {reused} reused")

            # Insert route_localities
            rl_inserted = 0
            rl_skipped = 0
            for pt in all_points:
                db_id = idx_to_dbid.get(pt['locality_idx'])
                if db_id is None:
                    continue

                # Check if link already exists
                cur.execute(
                    "SELECT id FROM route_localities "
                    "WHERE route_id=%s AND locality_id=%s",
                    (pt['route_id'], db_id))
                if cur.fetchone():
                    rl_skipped += 1
                    continue

                cur.execute(
                    "INSERT INTO route_localities "
                    "(route_id, locality_id, km_from_start, order_on_route) "
                    "VALUES (%s, %s, %s, %s)",
                    (pt['route_id'], db_id, pt['km_from_start'], pt['order']))
                rl_inserted += 1

                if rl_inserted % 500 == 0:
                    db.commit()

            db.commit()
            logging.info(f"Route-localities: {rl_inserted} inserted, {rl_skipped} skipped")

    # ── Summary ──
    logging.info("=" * 60)
    logging.info("IMPORT COMPLETE")
    logging.info(f"  Routes processed: {processed}/{total}")
    logging.info(f"  Unique localities: {len(unique_localities)}")
    logging.info(f"  Total route-locality links: {len(all_points)}")
    logging.info("=" * 60)

    db.close()
    return 0

if __name__ == '__main__':
    sys.exit(main())
