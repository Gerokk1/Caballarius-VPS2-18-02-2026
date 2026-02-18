#!/usr/bin/env python3
"""
Parse VPS1 Laravel seeders → Extract localities + stages → Insert into caballarius_staging

Usage (on VPS2):
    python3 parse_seeders.py

Requires:
    - mysql-connector-python
    - VPS1 repo cloned at /tmp/vps1-repo
    - Environment variables: DB_HOST, DB_NAME, DB_USER, DB_PASS (or defaults)
"""
import os, re, sys, unicodedata, mysql.connector
from collections import OrderedDict

SEEDERS_DIR = os.environ.get("SEEDERS_DIR", "/tmp/vps1-repo/database/seeders")
DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "localhost"),
    "database": os.environ.get("DB_NAME", "caballarius_staging"),
    "user": os.environ.get("DB_USER", "cblrs_user"),
    "password": os.environ.get("DB_PASS", ""),  # Set via env var or .env
}

# === VPS1 chemin slug → VPS2 route_id mapping ===
CHEMIN_TO_ROUTE = {
    "camino-frances": 3,
    "camino-aragones": 2,
    "camino-portugues": 4,
    "camino-del-norte": 5,
    "camino-mozarabe": 6,
    "camino-primitivo": 8,
    "camino-ingles": 9,
    "camino-finisterre-muxia": 10,
    "camino-levante": 11,
    "camino-de-madrid": 19,
    "camino-madrid": 19,
    "camino-de-la-lana-cuenca": 20,
    "camino-lana-cuenca": 20,
    "camino-del-ebro": 21,
    "camino-ebro": 21,
    "camino-de-invierno": 23,
    "camino-invierno": 23,
    "camino-vasco-del-interior": 26,
    "camino-vasco-interior": 26,
    "camino-catalan": 32,
    "camino-de-baztan": 38,
    "camino-manchego": 39,
    "camino-sanabres": 7,
    "camino-portugues-interior": 119,
    "ruta-de-la-lana": 42,
    "ruta-lana": 42,
    "via-de-la-plata": 6,
    "via-francigena-france": 129,
    "via-gebennensis": 85,
    "chemin-arles": 60,
    "chemin-bourges": 56,
    "chemin-cluny": 111,
    "chemin-cologne": 170,
    "chemin-conques": 78,
    "chemin-huguenots": 75,
    "chemin-limoges": 57,
    "chemin-de-limoges": 57,
    "chemin-montpellier": 102,
    "chemin-paris": 55,
    "chemin-piemont-pyreneen": 61,
    "chemin-puy-en-velay": 59,
    "chemin-rocamadour": 96,
    "chemin-saint-guilhem": 102,
    "chemin-stevenson": 80,
    "chemin-tours": 53,
    "chemin-vezelay": 58,
    "caminho-fatima": 118,
    "caminho-tejo": 124,
    "voie-narbonnaise": 60,
    "voie-puy-nord": 73,
    "voie-soulac": 68,
}


def slugify(text):
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"-+", "-", text).strip("-")
    return text


def guess_type(name):
    cities = [
        "santiago de compostela", "pampelune", "pamplona", "burgos", "leon",
        "logrono", "astorga", "ponferrada", "lugo", "oviedo", "bilbao",
        "san sebastian", "santander", "gijon", "salamanca", "zamora",
        "sevilla", "merida", "caceres", "lisboa", "porto", "coimbra",
        "tomar", "fatima", "braga", "le puy-en-velay", "cahors", "condom",
        "toulouse", "montpellier", "arles", "paris", "vezelay", "bourges",
        "lyon", "geneve", "koln", "cologne", "trier", "metz", "strasbourg",
        "munich", "munchen", "innsbruck", "salzburg", "roma", "siena",
        "lucca", "parma", "piacenza", "torino", "saint-jean-pied-de-port",
    ]
    lower = name.lower()
    for c in cities:
        if c in lower or lower in c:
            return "city"
    towns = [
        "puente la reina", "estella", "najera", "santo domingo",
        "fromista", "sahagun", "hospital de orbigo", "molinaseca",
        "villafranca", "sarria", "portomarin", "melide", "arzua",
        "o pedrouzo", "padron", "tui", "valenca", "barcelos",
        "ponte de lima", "redondela", "roncevaux", "roncesvalles",
        "saint-palais", "navarrenx", "oloron-sainte-marie", "conques",
        "figeac", "moissac", "lectoure", "aire-sur-l-adour",
        "saugues", "aumont-aubrac", "estaing", "espagnac-sainte-eulalie",
    ]
    for t in towns:
        if t in lower or lower in t:
            return "town"
    return "village"


def extract_chemin_slug(content):
    m = re.search(r"where\(\s*['\"]slug['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*\)", content)
    if m:
        return m.group(1)
    return None


def extract_etapes(content):
    etapes = []
    num_pattern = re.compile(
        r"'numero'\s*=>\s*(\d+).*?"
        r"'ville_depart'\s*=>\s*'([^']+)'.*?"
        r"'ville_arrivee'\s*=>\s*'([^']+)'.*?"
        r"'slug'\s*=>\s*'([^']+)'.*?"
        r"'latitude_depart'\s*=>\s*([\d.-]+).*?"
        r"'longitude_depart'\s*=>\s*([\d.-]+).*?"
        r"'latitude_arrivee'\s*=>\s*([\d.-]+).*?"
        r"'longitude_arrivee'\s*=>\s*([\d.-]+).*?"
        r"'distance_km'\s*=>\s*([\d.]+)",
        re.DOTALL
    )

    for m in num_pattern.finditer(content):
        etape = {
            "numero": int(m.group(1)),
            "ville_depart": m.group(2),
            "ville_arrivee": m.group(3),
            "slug": m.group(4),
            "lat_depart": float(m.group(5)),
            "lng_depart": float(m.group(6)),
            "lat_arrivee": float(m.group(7)),
            "lng_arrivee": float(m.group(8)),
            "distance_km": float(m.group(9)),
        }
        etapes.append(etape)

    deniv_map = {}
    blocks = re.split(r"//\s*[EÉ]TAPE\s+\d+", content)
    for block in blocks:
        num_m = re.search(r"'numero'\s*=>\s*(\d+)", block)
        dp_m = re.search(r"'denivele_positif'\s*=>\s*([\d.]+)", block)
        dn_m = re.search(r"'denivele_negatif'\s*=>\s*([\d.]+)", block)
        dur_m = re.search(r"'duree_heures_moyenne'\s*=>\s*([\d.]+)", block)
        if num_m and dp_m and dn_m:
            n = int(num_m.group(1))
            deniv_map[n] = {
                "d_plus": int(float(dp_m.group(1))),
                "d_minus": int(float(dn_m.group(1))),
                "hours": float(dur_m.group(1)) if dur_m else None,
            }

    for e in etapes:
        if e["numero"] in deniv_map:
            e["d_plus"] = deniv_map[e["numero"]]["d_plus"]
            e["d_minus"] = deniv_map[e["numero"]]["d_minus"]
            e["hours"] = deniv_map[e["numero"]]["hours"]
        else:
            e["d_plus"] = None
            e["d_minus"] = None
            e["hours"] = None

    return etapes


def main():
    if not DB_CONFIG["password"]:
        print("ERROR: DB_PASS environment variable not set")
        print("Usage: DB_PASS='...' python3 parse_seeders.py")
        sys.exit(1)

    print("=" * 60)
    print("PARSE SEEDERS → EXTRACT LOCALITIES + STAGES")
    print("=" * 60)

    seeder_files = []
    for root, dirs, files in os.walk(SEEDERS_DIR):
        for f in files:
            if "Etapes" in f and f.endswith(".php"):
                seeder_files.append(os.path.join(root, f))
    seeder_files.sort()
    print(f"\nFound {len(seeder_files)} etapes seeders")

    all_localities = OrderedDict()
    all_stages = []
    no_route_count = 0

    for sf in seeder_files:
        with open(sf, "r", encoding="utf-8") as fh:
            content = fh.read()

        chemin_slug = extract_chemin_slug(content)
        etapes = extract_etapes(content)
        route_id = CHEMIN_TO_ROUTE.get(chemin_slug) if chemin_slug else None

        dirname = os.path.basename(os.path.dirname(sf))
        print(f"\n  {dirname}: slug={chemin_slug}, route_id={route_id}, {len(etapes)} etapes")

        if not route_id and chemin_slug:
            print(f"    WARNING: No route mapping for slug '{chemin_slug}'")
            no_route_count += 1

        for e in etapes:
            key_dep = (e["ville_depart"], round(e["lat_depart"], 3), round(e["lng_depart"], 3))
            if key_dep not in all_localities:
                all_localities[key_dep] = {
                    "name": e["ville_depart"],
                    "lat": e["lat_depart"],
                    "lng": e["lng_depart"],
                    "type": guess_type(e["ville_depart"]),
                }

            key_arr = (e["ville_arrivee"], round(e["lat_arrivee"], 3), round(e["lng_arrivee"], 3))
            if key_arr not in all_localities:
                all_localities[key_arr] = {
                    "name": e["ville_arrivee"],
                    "lat": e["lat_arrivee"],
                    "lng": e["lng_arrivee"],
                    "type": guess_type(e["ville_arrivee"]),
                }

            if route_id:
                stage_name = f"{e['ville_depart']} - {e['ville_arrivee']}"
                all_stages.append({
                    "route_id": route_id,
                    "numero": e["numero"],
                    "name": stage_name,
                    "slug": e["slug"],
                    "loc_start_key": key_dep,
                    "loc_end_key": key_arr,
                    "km": e["distance_km"],
                    "d_plus": e.get("d_plus"),
                    "d_minus": e.get("d_minus"),
                    "hours": e.get("hours"),
                })

    print(f"\n{'=' * 60}")
    print(f"TOTALS: {len(all_localities)} unique localities, {len(all_stages)} stages")
    print(f"Unmapped chemins: {no_route_count}")
    print(f"{'=' * 60}")

    print("\nConnecting to MariaDB...")
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM localities")
    existing_loc = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM stages")
    existing_stg = cursor.fetchone()[0]
    print(f"  Existing: {existing_loc} localities, {existing_stg} stages")

    print("\nInserting localities...")
    loc_id_map = {}
    inserted_loc = 0
    skipped_loc = 0

    for key, loc in all_localities.items():
        slug = slugify(loc["name"])
        cursor.execute("SELECT id FROM localities WHERE slug = %s", (slug,))
        row = cursor.fetchone()
        if row:
            loc_id_map[key] = row[0]
            skipped_loc += 1
            continue

        cursor.execute("SELECT COUNT(*) FROM localities WHERE slug LIKE %s", (slug + "%",))
        cnt = cursor.fetchone()[0]
        if cnt > 0:
            slug = f"{slug}-{cnt + 1}"

        cursor.execute(
            """INSERT INTO localities (name, slug, lat, lng, type, scrape_status)
               VALUES (%s, %s, %s, %s, %s, 'pending')""",
            (loc["name"], slug, loc["lat"], loc["lng"], loc["type"])
        )
        loc_id_map[key] = cursor.lastrowid
        inserted_loc += 1

    conn.commit()
    print(f"  Inserted: {inserted_loc} localities (skipped {skipped_loc} duplicates)")

    print("\nInserting stages...")
    inserted_stg = 0
    skipped_stg = 0

    for stg in all_stages:
        loc_start_id = loc_id_map.get(stg["loc_start_key"])
        loc_end_id = loc_id_map.get(stg["loc_end_key"])

        if not loc_start_id or not loc_end_id:
            print(f"    SKIP stage {stg['name']}: missing locality IDs")
            skipped_stg += 1
            continue

        cursor.execute(
            "SELECT id FROM stages WHERE route_id = %s AND stage_number = %s",
            (stg["route_id"], stg["numero"])
        )
        if cursor.fetchone():
            skipped_stg += 1
            continue

        slug = stg["slug"]
        cursor.execute("SELECT COUNT(*) FROM stages WHERE slug = %s", (slug,))
        if cursor.fetchone()[0] > 0:
            slug = f"{slug}-r{stg['route_id']}"

        cursor.execute(
            """INSERT INTO stages (route_id, stage_number, name, slug,
               locality_start_id, locality_end_id, km, d_plus, d_minus, estimated_hours)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            (stg["route_id"], stg["numero"], stg["name"], slug,
             loc_start_id, loc_end_id, stg["km"],
             stg.get("d_plus"), stg.get("d_minus"), stg.get("hours"))
        )
        inserted_stg += 1

    conn.commit()
    print(f"  Inserted: {inserted_stg} stages (skipped {skipped_stg})")

    print("\nInserting route_localities...")
    inserted_rl = 0
    route_loc_seen = set()

    for stg in all_stages:
        route_id = stg["route_id"]
        for loc_key in [stg["loc_start_key"], stg["loc_end_key"]]:
            loc_id = loc_id_map.get(loc_key)
            if not loc_id:
                continue
            pair = (route_id, loc_id)
            if pair in route_loc_seen:
                continue
            route_loc_seen.add(pair)

            cursor.execute(
                "SELECT id FROM route_localities WHERE route_id = %s AND locality_id = %s",
                (route_id, loc_id)
            )
            if cursor.fetchone():
                continue

            order_val = 0
            for s in all_stages:
                if s["route_id"] == route_id:
                    if s["loc_start_key"] == loc_key:
                        order_val = (s["numero"] - 1) * 2
                        break
                    elif s["loc_end_key"] == loc_key:
                        order_val = (s["numero"] - 1) * 2 + 1
                        break

            cursor.execute(
                """INSERT INTO route_localities (route_id, locality_id, km_from_start, order_on_route)
                   VALUES (%s, %s, %s, %s)""",
                (route_id, loc_id, 0.0, order_val)
            )
            inserted_rl += 1

    conn.commit()
    print(f"  Inserted: {inserted_rl} route_localities")

    cursor.execute("SELECT COUNT(*) FROM localities")
    total_loc = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM stages")
    total_stg = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM route_localities")
    total_rl = cursor.fetchone()[0]

    print(f"\n{'=' * 60}")
    print(f"FINAL DATABASE STATE:")
    print(f"  localities:       {total_loc}")
    print(f"  stages:           {total_stg}")
    print(f"  route_localities: {total_rl}")
    print(f"{'=' * 60}")

    cursor.close()
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
