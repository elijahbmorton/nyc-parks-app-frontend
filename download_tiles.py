#!/usr/bin/env python3
"""
NYC-optimized OpenStreetMap tile downloader.

Strategy:
- Zoom 10–11: broad surrounding-area bbox (cheap, few tiles)
- Zoom 12–15: NYC-only continuous polygon (incl. inter-borough water)
- Tile is downloaded at high zoom ONLY if tile center ∈ NYC polygon
"""

import math
import time
import requests
from pathlib import Path

# -------------------------
# CONFIG
# -------------------------

# Broad bbox for low zooms (cheap)
MIN_LAT = 40.40
MAX_LAT = 41.30
MIN_LON = -74.50
MAX_LON = -73.35

# Zoom levels
ZOOM_LEVELS = [10, 11, 12, 13, 14, 15, 16,]

# Tile server
TILE_URL = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"

# Output directory
OUTPUT_DIR = Path("assets/tiles")

# Politeness delay (seconds)
DELAY = 0.1

HEADERS = {
    "User-Agent": "ParkAppNYC/1.0 (tile downloader; contact: you@example.com)"
}

# -------------------------
# NYC CONTINUOUS POLYGON
# (lon, lat)
# -------------------------

NYC_POLYGON = [
    (-74.2591, 40.4700),  # SW Staten Island
    (-74.2550, 40.6600),
    (-74.0500, 40.7200),
    (-74.0200, 40.8900),
    (-73.9300, 40.9176),
    (-73.7000, 40.9250),  # NE Queens (Glen Oaks)
    (-73.6800, 40.8200),
    (-73.6800, 40.6500),
    (-73.7200, 40.5800),
    (-73.8500, 40.5400),
    (-74.0000, 40.5400),
    (-74.1400, 40.5100),
    (-74.2591, 40.4700)   # Close polygon
]

# -------------------------
# GEO HELPERS
# -------------------------

def lat_lon_to_tile(lat, lon, zoom):
    """Convert lat/lon to slippy map tile coordinates."""
    lat_rad = math.radians(lat)
    n = 2.0 ** zoom
    x = int((lon + 180.0) / 360.0 * n)
    y = int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    return x, y

def tile_center_lat_lon(x, y, zoom):
    """Return lat/lon of tile center."""
    n = 2.0 ** zoom
    lon = (x + 0.5) / n * 360.0 - 180.0
    lat_rad = math.atan(math.sinh(math.pi * (1 - 2 * (y + 0.5) / n)))
    lat = math.degrees(lat_rad)
    return lat, lon

def point_in_polygon(lon, lat, polygon):
    """Ray-casting point-in-polygon test."""
    inside = False
    j = len(polygon) - 1
    for i in range(len(polygon)):
        xi, yi = polygon[i]
        xj, yj = polygon[j]
        intersects = ((yi > lat) != (yj > lat)) and \
                     (lon < (xj - xi) * (lat - yi) / (yj - yi + 1e-12) + xi)
        if intersects:
            inside = not inside
        j = i
    return inside

# -------------------------
# TILE DOWNLOAD
# -------------------------

def download_tile(z, x, y):
    """Download a single tile if it doesn't exist."""
    tile_dir = OUTPUT_DIR / str(z) / str(x)
    tile_dir.mkdir(parents=True, exist_ok=True)
    tile_path = tile_dir / f"{y}.png"

    if tile_path.exists():
        return False

    try:
        url = TILE_URL.format(z=z, x=x, y=y)
        r = requests.get(url, headers=HEADERS, timeout=15)
        r.raise_for_status()
        tile_path.write_bytes(r.content)
        return True
    except Exception as e:
        print(f"Error downloading {z}/{x}/{y}: {e}")
        return False

# -------------------------
# MAIN
# -------------------------

def main():
    print("NYC Map Tile Downloader (Polygon-Optimized)")
    print("=" * 60)
    print(f"Zoom levels: {ZOOM_LEVELS}")
    print(f"Output dir: {OUTPUT_DIR}")
    print("=" * 60)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    downloaded = 0
    skipped = 0

    for zoom in ZOOM_LEVELS:
        print(f"\nZoom level {zoom}")

        min_x, max_y = lat_lon_to_tile(MIN_LAT, MIN_LON, zoom)
        max_x, min_y = lat_lon_to_tile(MAX_LAT, MAX_LON, zoom)

        for x in range(min_x, max_x + 1):
            for y in range(min_y, max_y + 1):

                # High zoom: restrict to NYC polygon
                if zoom >= 12:
                    lat, lon = tile_center_lat_lon(x, y, zoom)
                    if not point_in_polygon(lon, lat, NYC_POLYGON):
                        skipped += 1
                        continue

                if download_tile(zoom, x, y):
                    downloaded += 1
                else:
                    skipped += 1

                if downloaded % 25 == 0:
                    print(
                        f"Downloaded: {downloaded} | Skipped: {skipped}",
                        end="\r"
                    )

                time.sleep(DELAY)

    print("\n\nDownload complete.")
    print(f"Downloaded tiles: {downloaded}")
    print(f"Skipped tiles:    {skipped}")
    print(f"Saved to: {OUTPUT_DIR.absolute()}")

    print("\nNext steps:")
    print("1. Add assets/tiles to pubspec.yaml")
    print("2. flutter pub get")
    print("3. Use AssetTileProvider in your map")

if __name__ == "__main__":
    main()
