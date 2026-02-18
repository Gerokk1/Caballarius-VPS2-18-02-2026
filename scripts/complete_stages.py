#!/usr/bin/env python3
"""
complete_stages.py — Create stages for routes that have no stages yet.
Uses KML files already downloaded by import_gpx.py.

Usage (on VPS2):
    DB_PASS='...' python3 complete_stages.py                # Full run
    DB_PASS='...' python3 complete_stages.py --dry-run      # Parse only, no DB
    DB_PASS='...' python3 complete_stages.py --route es09a  # Single route
    DB_PASS='...' python3 complete_stages.py --batch 20     # First 20 routes

Requires:
    - pymysql, requests
    - Environment variables: DB_HOST, DB_NAME, DB_USER, DB_PASS (or defaults)
"""

import os
import sys
import re
import math
import json
import time
import logging
import argparse
import unicodedata
from pathlib import Path

import zipfile
import requests
import xml.etree.ElementTree as ET
import pymysql

# ─── Configuration ───────────────────────────────────────────────────────────

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'cblrs_user'),
    'password': os.environ.get('DB_PASS', ''),  # Set via env var or .env
    'database': os.environ.get('DB_NAME', 'caballarius_staging'),
    'charset': 'utf8mb4',
}

BASE_DIR = Path('/data/openclaw/workspace/skills/00-import-gpx')
EXTRACT_DIR = BASE_DIR / 'extracted'
STATE_FILE = BASE_DIR / 'state.json'
LOG_FILE = BASE_DIR / 'complete_stages.log'

NOMINATIM_URL = 'https://nominatim.openstreetmap.org/reverse'
NOMINATIM_HEADERS = {'User-Agent': 'Caballarius/1.0 (pilgrimage-routes@cblrs.net)'}
NOMINATIM_DELAY = 1.1

DEDUP_RADIUS_KM = 0.5

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

# ─── Geo Utilities ───────────────────────────────────────────────────────────

def haversine(lat1, lng1, lat2, lng2):
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlng / 2) ** 2)
    return R * 2 * math.asin(math.sqrt(min(1.0, a)))

def track_distance_km(coords):
    total = 0.0
    for i in range(1, len(coords)):
        total += haversine(coords[i-1][0], coords[i-1][1],
                           coords[i][0], coords[i][1])
    return total

def track_elevation(coords):
    d_plus = 0
    d_minus = 0
    for i in range(1, len(coords)):
        diff = coords[i][2] - coords[i-1][2]
        if abs(diff) > 500:
            continue
        if diff > 0:
            d_plus += diff
        else:
            d_minus += abs(diff)
    d_plus = min(int(d_plus), 5000)
    d_minus = min(int(d_minus), 5000)
    return d_plus, d_minus

# ─── KML Parsing ─────────────────────────────────────────────────────────────

def parse_kml(kml_path):
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

def parse_kmz(kmz_path):
    try:
        with zipfile.ZipFile(kmz_path, 'r') as zf:
            kml_names = [n for n in zf.namelist() if n.lower().endswith('.kml')]
            if not kml_names:
                logging.warning(f"  No .kml found inside {kmz_path}")
                return []
            kml_name = kml_names[0]
            temp_kml = kmz_path.parent / f"_temp_{kmz_path.stem}.kml"
            with zf.open(kml_name) as src, open(temp_kml, 'wb') as dst:
                dst.write(src.read())
            coords = parse_kml(temp_kml)
            temp_kml.unlink()
            return coords
    except Exception as e:
        logging.warning(f"  KMZ parse error {kmz_path}: {e}")
        return []

def parse_gpx(gpx_path):
    try:
        tree = ET.parse(gpx_path)
    except ET.ParseError as e:
        logging.warning(f"  GPX parse error in {gpx_path}: {e}")
        return []
    root = tree.getroot()
    all_coords = []
    ns = ''
    if root.tag.startswith('{'):
        ns = root.tag.split('}')[0] + '}'
    for trkpt in root.iter(f'{ns}trkpt'):
        try:
            lat = float(trkpt.get('lat'))
            lng = float(trkpt.get('lon'))
            ele_elem = trkpt.find(f'{ns}ele')
            alt = float(ele_elem.text) if ele_elem is not None and ele_elem.text else 0
            all_coords.append((lat, lng, alt))
        except (ValueError, TypeError):
            continue
    if not all_coords:
        for wpt in root.iter(f'{ns}wpt'):
            try:
                lat = float(wpt.get('lat'))
                lng = float(wpt.get('lon'))
                ele_elem = wpt.find(f'{ns}ele')
                alt = float(ele_elem.text) if ele_elem is not None and ele_elem.text else 0
                all_coords.append((lat, lng, alt))
            except (ValueError, TypeError):
                continue
    return all_coords

def parse_track_file(file_path):
    ext = file_path.suffix.lower()
    if ext == '.kml':
        return parse_kml(file_path)
    elif ext == '.kmz':
        return parse_kmz(file_path)
    elif ext == '.gpx':
        return parse_gpx(file_path)
    return []

# ─── Filename Parsing ────────────────────────────────────────────────────────

def camelcase_split(s):
    if not s:
        return s
    result = re.sub(r'([a-z])([A-Z])', r'\1 \2', s)
    result = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1 \2', result)
    result = re.sub(r'\b(De|Del|La|Le|Les|En|Des|Du|Das|Von|Am|Im|An|Auf|Zu|Und)\b',
                    lambda m: m.group(0).lower(), result)
    return result.strip()

def parse_stage_filename(filename, route_slug):
    name = Path(filename).stem
    prefix = route_slug.upper()
    if not name.upper().startswith(prefix):
        return None
    rest = name[len(prefix):]
    match = re.match(r'(\d+)([a-z]?)-(.+)', rest)
    if not match:
        return None
    stage_num = int(match.group(1))
    variant = match.group(2) or 'a'
    locality_part = match.group(3)
    parts = locality_part.split('-', 1)
    start_hint = camelcase_split(parts[0])
    end_hint = camelcase_split(parts[1]) if len(parts) > 1 else None
    return {
        'stage': stage_num,
        'variant': variant,
        'start_hint': start_hint,
        'end_hint': end_hint,
    }

# ─── Slugify ─────────────────────────────────────────────────────────────────

def slugify(name):
    s = unicodedata.normalize('NFKD', name).encode('ascii', 'ignore').decode('ascii')
    s = re.sub(r'[^\w\s-]', '', s.lower())
    s = re.sub(r'[\s_]+', '-', s)
    return re.sub(r'-+', '-', s).strip('-') or 'unnamed'

# ─── Reverse Geocode ─────────────────────────────────────────────────────────

def reverse_geocode(lat, lng, geocode_cache):
    cache_key = f"{lat:.5f},{lng:.5f}"
    if cache_key in geocode_cache:
        return geocode_cache[cache_key]
    try:
        resp = requests.get(NOMINATIM_URL, params={
            'lat': lat, 'lon': lng,
            'format': 'json', 'zoom': 16,
            'addressdetails': 1,
        }, headers=NOMINATIM_HEADERS, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        addr = data.get('address', {})
        name = (addr.get('village') or addr.get('town') or
                addr.get('city') or addr.get('municipality') or
                addr.get('hamlet') or addr.get('suburb') or
                addr.get('locality') or
                data.get('display_name', '').split(',')[0])
        loc_type = 'village'
        if addr.get('city'):
            loc_type = 'city'
        elif addr.get('town'):
            loc_type = 'town'
        elif addr.get('hamlet'):
            loc_type = 'hamlet'
        elif addr.get('isolated_dwelling'):
            loc_type = 'lieu-dit'
        result = {'name': name.strip() if name else None, 'type': loc_type}
        geocode_cache[cache_key] = result
        time.sleep(NOMINATIM_DELAY)
        return result
    except Exception as e:
        logging.warning(f"  Geocode failed ({lat:.5f}, {lng:.5f}): {e}")
        return None

# ─── Find or Create Locality ────────────────────────────────────────────────

def find_or_create_locality(lat, lng, hint, geocode_cache, db, used_slugs):
    cur = db.cursor()
    cur.execute(
        "SELECT id, name FROM localities "
        "WHERE ABS(lat - %s) < 0.005 AND ABS(lng - %s) < 0.005",
        (lat, lng)
    )
    candidates = cur.fetchall()
    for cand in candidates:
        cur2 = db.cursor()
        cur2.execute("SELECT lat, lng FROM localities WHERE id = %s", (cand['id'],))
        row = cur2.fetchone()
        if row and haversine(lat, lng, float(row['lat']), float(row['lng'])) < DEDUP_RADIUS_KM:
            return cand['id'], cand['name']

    geo = reverse_geocode(lat, lng, geocode_cache)
    if geo and geo['name']:
        name = geo['name']
        loc_type = geo['type']
    elif hint:
        name = hint
        loc_type = 'village'
    else:
        name = f"Point {lat:.4f} {lng:.4f}"
        loc_type = 'village'

    base_slug = slugify(name)
    slug = base_slug
    n = 2
    while slug in used_slugs:
        slug = f"{base_slug}-{n}"
        n += 1
    used_slugs.add(slug)

    cur.execute("SELECT COUNT(*) as cnt FROM localities WHERE slug = %s", (slug,))
    if cur.fetchone()['cnt'] > 0:
        slug = f"{slug}-{int(time.time()) % 10000}"
        used_slugs.add(slug)

    cur.execute(
        "INSERT INTO localities (name, slug, lat, lng, type, scrape_status) "
        "VALUES (%s, %s, %s, %s, %s, 'pending')",
        (name, slug, round(lat, 7), round(lng, 7), loc_type)
    )
    db.commit()
    new_id = cur.lastrowid
    return new_id, name

# ─── Process One Route ──────────────────────────────────────────────────────

def process_route(route, geocode_cache, db, used_slugs, dry_run=False):
    slug = route['slug']
    route_id = route['id']
    route_name = route['name']
    extract_path = EXTRACT_DIR / slug

    if not extract_path.exists():
        logging.warning(f"  [{slug}] No extracted directory")
        return 0, 0

    kml_files = sorted([f for f in os.listdir(extract_path)
                        if f.lower().endswith(('.kml', '.kmz', '.gpx'))
                        and not f.startswith('_temp_')])
    if not kml_files:
        logging.warning(f"  [{slug}] No KML/KMZ/GPX files")
        return 0, 0

    raw_stages = []
    for kml_file in kml_files:
        file_path = extract_path / kml_file
        coords = parse_track_file(file_path)
        if len(coords) < 2:
            continue

        base_name = Path(kml_file).stem + '.kml'
        info = parse_stage_filename(base_name, slug)
        if not info:
            distance = track_distance_km(coords)
            d_plus, d_minus = track_elevation(coords)
            raw_stages.append({
                'filename': kml_file,
                'stage_num': 1,
                'variant': 'a',
                'start_hint': None,
                'end_hint': None,
                'start_coord': coords[0],
                'end_coord': coords[-1],
                'distance_km': distance,
                'd_plus': d_plus,
                'd_minus': d_minus,
            })
            continue

        distance = track_distance_km(coords)
        d_plus, d_minus = track_elevation(coords)

        raw_stages.append({
            'filename': kml_file,
            'stage_num': info['stage'],
            'variant': info['variant'],
            'start_hint': info['start_hint'],
            'end_hint': info['end_hint'],
            'start_coord': coords[0],
            'end_coord': coords[-1],
            'distance_km': distance,
            'd_plus': d_plus,
            'd_minus': d_minus,
        })

    main_stages = [s for s in raw_stages if s['variant'] == 'a']
    if not main_stages:
        main_stages = raw_stages

    main_stages.sort(key=lambda s: s['stage_num'])

    seen_nums = set()
    deduped = []
    for s in main_stages:
        if s['stage_num'] not in seen_nums:
            seen_nums.add(s['stage_num'])
            deduped.append(s)
    main_stages = deduped

    logging.info(f"  [{slug}] {route_name}: {len(main_stages)} stages from {len(kml_files)} KML files")

    if dry_run:
        for s in main_stages:
            logging.info(f"    Stage {s['stage_num']}: {s['start_hint']} → {s['end_hint']} "
                         f"({s['distance_km']:.1f}km, +{s['d_plus']}/-{s['d_minus']}m)")
        return len(main_stages), 0

    cur = db.cursor()
    stages_created = 0
    localities_created = 0
    cumulative_km = 0.0
    route_locality_pairs = []

    for i, stage in enumerate(main_stages):
        lat_s, lng_s = stage['start_coord'][0], stage['start_coord'][1]
        lat_e, lng_e = stage['end_coord'][0], stage['end_coord'][1]

        loc_start_id, loc_start_name = find_or_create_locality(
            lat_s, lng_s, stage['start_hint'], geocode_cache, db, used_slugs)

        loc_end_id, loc_end_name = find_or_create_locality(
            lat_e, lng_e, stage['end_hint'], geocode_cache, db, used_slugs)

        stage_name = f"{loc_start_name} - {loc_end_name}"
        stage_slug = slugify(f"{slug}-{stage['stage_num']:02d}-{loc_start_name}-{loc_end_name}")

        cur.execute("SELECT COUNT(*) as cnt FROM stages WHERE slug = %s", (stage_slug,))
        if cur.fetchone()['cnt'] > 0:
            stage_slug = f"{stage_slug}-{route_id}"

        est_hours = round(stage['distance_km'] / 4.0 + stage['d_plus'] / 600, 1)

        cur.execute(
            "INSERT INTO stages (route_id, stage_number, name, slug, "
            "locality_start_id, locality_end_id, km, d_plus, d_minus, estimated_hours) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (route_id, stage['stage_num'], stage_name, stage_slug,
             loc_start_id, loc_end_id,
             round(stage['distance_km'], 1),
             stage['d_plus'] if stage['d_plus'] > 0 else None,
             stage['d_minus'] if stage['d_minus'] > 0 else None,
             est_hours if est_hours > 0 else None)
        )
        stages_created += 1

        order_start = i * 2
        order_end = i * 2 + 1
        route_locality_pairs.append((route_id, loc_start_id, cumulative_km, order_start))
        cumulative_km += stage['distance_km']
        route_locality_pairs.append((route_id, loc_end_id, round(cumulative_km, 1), order_end))

    seen_rl = set()
    for rl_route_id, rl_loc_id, rl_km, rl_order in route_locality_pairs:
        pair = (rl_route_id, rl_loc_id)
        if pair in seen_rl:
            continue
        seen_rl.add(pair)

        cur.execute(
            "SELECT id FROM route_localities WHERE route_id = %s AND locality_id = %s",
            (rl_route_id, rl_loc_id))
        if not cur.fetchone():
            cur.execute(
                "INSERT INTO route_localities (route_id, locality_id, km_from_start, order_on_route) "
                "VALUES (%s, %s, %s, %s)",
                (rl_route_id, rl_loc_id, rl_km, rl_order))

    db.commit()
    return stages_created, len(seen_rl)

# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description='Create stages for routes that have no stages yet')
    parser.add_argument('--dry-run', action='store_true',
                        help='Parse only, no DB writes')
    parser.add_argument('--route', type=str,
                        help='Process a single route slug')
    parser.add_argument('--batch', type=int, default=0,
                        help='Process N routes then stop')
    parser.add_argument('--skip-geocode', action='store_true',
                        help='Use filename hints only, no Nominatim')
    args = parser.parse_args()

    if not args.dry_run and not DB_CONFIG['password']:
        print("ERROR: DB_PASS environment variable not set")
        print("Usage: DB_PASS='...' python3 complete_stages.py")
        sys.exit(1)

    setup_logging()
    logging.info("=" * 60)
    logging.info("COMPLETE_STAGES — Create stages for routes without stages")
    logging.info("=" * 60)

    if not args.dry_run:
        import subprocess
        result = subprocess.run(['pgrep', '-f', 'import_gpx.py'],
                                capture_output=True, text=True)
        if result.returncode == 0:
            logging.warning("import_gpx.py is still running! Waiting for it to finish...")
            while True:
                result = subprocess.run(['pgrep', '-f', 'import_gpx.py'],
                                        capture_output=True, text=True)
                if result.returncode != 0:
                    break
                logging.info("  Still waiting... (checking every 30s)")
                time.sleep(30)
            logging.info("import_gpx.py finished. Proceeding.")

    geocode_cache = {}
    if STATE_FILE.exists():
        try:
            state = json.loads(STATE_FILE.read_text(encoding='utf-8'))
            geocode_cache = state.get('geocoded', {})
            logging.info(f"Loaded {len(geocode_cache)} geocoded entries from cache")
        except json.JSONDecodeError:
            logging.warning("Could not load state.json cache")

    if args.skip_geocode:
        global reverse_geocode
        _orig = reverse_geocode
        def reverse_geocode(lat, lng, cache):
            ck = f"{lat:.5f},{lng:.5f}"
            if ck in cache:
                return cache[ck]
            return None

    db = pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)
    cur = db.cursor()

    if args.route:
        cur.execute(
            "SELECT r.id, r.name, r.slug, r.gpx_file FROM routes r WHERE r.slug = %s",
            (args.route,))
    else:
        cur.execute(
            "SELECT r.id, r.name, r.slug, r.gpx_file "
            "FROM routes r LEFT JOIN stages s ON s.route_id = r.id "
            "WHERE s.id IS NULL AND r.gpx_file IS NOT NULL "
            "ORDER BY r.id")
    routes = cur.fetchall()
    total = len(routes)
    logging.info(f"Routes without stages: {total}")

    if args.batch:
        routes = routes[:args.batch]
        logging.info(f"Processing batch of {len(routes)} routes")

    cur.execute("SELECT slug FROM localities")
    used_slugs = {row['slug'] for row in cur.fetchall()}
    logging.info(f"Existing locality slugs: {len(used_slugs)}")

    total_stages = 0
    total_rl = 0
    routes_with_stages = 0
    routes_no_kml = 0

    for i, route in enumerate(routes):
        stages_created, rl_created = process_route(
            route, geocode_cache, db, used_slugs, args.dry_run)

        if stages_created > 0:
            routes_with_stages += 1
            total_stages += stages_created
            total_rl += rl_created
        else:
            routes_no_kml += 1

        if (i + 1) % 20 == 0:
            logging.info(f"  --- Progress: {i + 1}/{len(routes)} routes, "
                         f"{total_stages} stages created ---")
            if STATE_FILE.exists() and not args.dry_run:
                try:
                    state = json.loads(STATE_FILE.read_text(encoding='utf-8'))
                    state['geocoded'] = geocode_cache
                    STATE_FILE.write_text(
                        json.dumps(state, indent=2, ensure_ascii=False),
                        encoding='utf-8')
                except Exception:
                    pass

    if not args.dry_run and STATE_FILE.exists():
        try:
            state = json.loads(STATE_FILE.read_text(encoding='utf-8'))
            state['geocoded'] = geocode_cache
            STATE_FILE.write_text(
                json.dumps(state, indent=2, ensure_ascii=False),
                encoding='utf-8')
        except Exception:
            pass

    cur.execute("SELECT COUNT(*) as cnt FROM localities")
    total_loc = cur.fetchone()['cnt']
    cur.execute("SELECT COUNT(*) as cnt FROM stages")
    total_stg = cur.fetchone()['cnt']
    cur.execute("SELECT COUNT(*) as cnt FROM route_localities")
    total_rl_db = cur.fetchone()['cnt']
    cur.execute(
        "SELECT COUNT(*) as cnt FROM routes r LEFT JOIN stages s ON s.route_id = r.id "
        "WHERE s.id IS NULL")
    remaining = cur.fetchone()['cnt']

    logging.info("=" * 60)
    logging.info("COMPLETE_STAGES — DONE")
    logging.info(f"  Routes processed: {len(routes)}")
    logging.info(f"  Routes with new stages: {routes_with_stages}")
    logging.info(f"  Routes without KML data: {routes_no_kml}")
    logging.info(f"  New stages created: {total_stages}")
    logging.info(f"  New route_localities: {total_rl}")
    logging.info(f"  ---")
    logging.info(f"  DB total localities: {total_loc}")
    logging.info(f"  DB total stages: {total_stg}")
    logging.info(f"  DB total route_localities: {total_rl_db}")
    logging.info(f"  Routes still without stages: {remaining}")
    logging.info("=" * 60)

    db.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
