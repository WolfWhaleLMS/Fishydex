#!/usr/bin/env python3
"""
Download fish photos from Wikimedia Commons for all 84 Saskatchewan fish species.
Saves images into Xcode .xcassets structure.

Uses a two-phase approach:
  Phase 1: Query the API to find the best image for each species (fast, batched)
  Phase 2: Download images one at a time with generous delays and retry logic
"""

import json
import os
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
import hashlib
import re

# Base paths
ASSETS_BASE = "/Users/rylanddupre/Fishydex/Fishydex/Assets.xcassets/Fish"

# All 84 species: (id, scientific_name, common_name, search_override)
SPECIES = [
    (1, "Ichthyomyzon castaneus", "Chestnut Lamprey", None),
    (2, "Acipenser fulvescens", "Lake Sturgeon", None),
    (3, "Carpiodes cyprinus", "Quillback", None),
    (4, "Catostomus catostomus", "Longnose Sucker", None),
    (5, "Catostomus commersonii", "White Sucker", None),
    (6, "Catostomus platyrhynchus", "Plains Sucker", None),
    (7, "Ictiobus cyprinellus", "Bigmouth Buffalo", None),
    (8, "Moxostoma anisurum", "Silver Redhorse", None),
    (9, "Moxostoma macrolepidotum", "Shorthead Redhorse", None),
    (10, "Chrosomus eos", "Northern Redbelly Dace", None),
    (11, "Chrosomus neogaeus", "Finescale Dace", None),
    (12, "Couesius plumbeus", "Lake Chub", None),
    (13, "Hybognathus argyritis", "Western Silvery Minnow", None),
    (14, "Hybognathus hankinsoni", "Brassy Minnow", None),
    (15, "Hybognathus placitus", "Plains Minnow", None),
    (16, "Luxilus cornutus", "Common Shiner", None),
    (17, "Margariscus nachtriebi", "Pearl Dace", None),
    (18, "Miniellus stramineus", "Sand Shiner", None),
    (19, "Notemigonus crysoleucas", "Golden Shiner", None),
    (20, "Notropis atherinoides", "Emerald Shiner", None),
    (21, "Notropis blennius", "River Shiner", None),
    (22, "Notropis heterolepis", "Blacknose Shiner", None),
    (23, "Notropis hudsonius", "Spottail Shiner", None),
    (24, "Notropis texanus", "Weed Shiner", None),
    (25, "Notropis volucellus", "Mimic Shiner", None),
    (26, "Pimephales promelas", "Fathead Minnow", None),
    (27, "Platygobio gracilis", "Flathead Chub", None),
    (28, "Rhinichthys cataractae", "Longnose Dace", None),
    (29, "Rhinichthys obtusus", "Blacknose Dace", None),
    (30, "Semotilus atromaculatus", "Creek Chub", None),
    (31, "Carassius auratus", "Goldfish", None),
    (32, "Carassius gibelio", "Prussian Carp", None),
    (33, "Cyprinus carpio", "Common Carp", None),
    (34, "Esox lucius", "Northern Pike", None),
    (35, "Umbra limi", "Central Mudminnow", None),
    (36, "Lota lota", "Burbot", None),
    (37, "Culaea inconstans", "Brook Stickleback", None),
    (38, "Pungitius pungitius", "Ninespine Stickleback", None),
    (39, "Hiodon alosoides", "Goldeye", None),
    (40, "Hiodon tergisus", "Mooneye", None),
    (41, "Osmerus mordax", "Rainbow Smelt", None),
    (42, "Ambloplites rupestris", "Rock Bass", None),
    (43, "Lepomis macrochirus", "Bluegill", None),
    (44, "Micropterus dolomieu", "Smallmouth Bass", None),
    (45, "Micropterus salmoides", "Largemouth Bass", None),
    (46, "Pomoxis annularis", "White Crappie", None),
    (47, "Pomoxis nigromaculatus", "Black Crappie", None),
    (48, "Etheostoma exile", "Iowa Darter", None),
    (49, "Etheostoma nigrum", "Johnny Darter", None),
    (50, "Perca flavescens", "Yellow Perch", None),
    (51, "Percina caprodes", "Logperch", None),
    (52, "Percina maculata", "Blackside Darter", None),
    (53, "Percina shumardi", "River Darter", None),
    (54, "Sander canadensis", "Sauger", None),
    (55, "Sander vitreus", "Walleye", None),
    (56, "Percopsis omiscomaycus", "Trout-perch", None),
    (57, "Coregonus artedi", "Cisco", None),
    (58, "Coregonus clupeaformis", "Lake Whitefish", None),
    (59, "Coregonus zenithicus", "Shortjaw Cisco", None),
    (60, "Oncorhynchus virginalis", "Cutthroat Trout", ["Oncorhynchus clarkii", "Cutthroat Trout"]),
    (61, "Oncorhynchus kisutch", "Coho Salmon", None),
    (62, "Oncorhynchus mykiss", "Rainbow Trout", None),
    (63, "Oncorhynchus nerka", "Kokanee Salmon", None),
    (64, "Prosopium cylindraceum", "Round Whitefish", None),
    (65, "Prosopium williamsoni", "Mountain Whitefish", None),
    (66, "Salmo salar", "Atlantic Salmon", None),
    (67, "Salmo trutta", "Brown Trout", None),
    (68, None, "Tiger Trout", ["Tiger trout"]),
    (69, "Salvelinus alpinus", "Arctic Char", None),
    (70, "Salvelinus fontinalis", "Brook Trout", None),
    (71, None, "Splake", ["Splake fish"]),
    (72, "Salvelinus namaycush", "Lake Trout", None),
    (73, "Thymallus arcticus", "Arctic Grayling", None),
    (74, "Cottus cognatus", "Slimy Sculpin", None),
    (75, "Cottus ricei", "Spoonhead Sculpin", None),
    (76, "Myoxocephalus thompsonii", "Deepwater Sculpin", None),
    (77, "Ameiurus melas", "Black Bullhead", None),
    (78, "Ameiurus nebulosus", "Brown Bullhead", None),
    (79, "Ictalurus punctatus", "Channel Catfish", None),
    (80, "Noturus flavus", "Stonecat", None),
    (81, "Noturus gyrinus", "Tadpole Madtom", None),
    (82, "Aplodinotus grunniens", "Freshwater Drum", None),
    (83, "Ctenopharyngodon idella", "Grass Carp", None),
    (84, "Anguilla rostrata", "American Eel", None),
]

API_URL = "https://commons.wikimedia.org/w/api.php"
# Wikimedia requires a descriptive User-Agent with contact info
USER_AGENT = "FishydexBot/1.0 (https://github.com/fishydex; rylan@wolfwhale.ca) python-urllib/3"

# Delay between API requests (seconds)
API_DELAY = 2.0
# Delay between image downloads (seconds)
DOWNLOAD_DELAY = 3.0
# Max retries for rate-limited requests
MAX_RETRIES = 5


def robust_request(url, timeout=30, max_retries=MAX_RETRIES):
    """Make an HTTP request with retry logic for rate limiting."""
    req = urllib.request.Request(url, headers={
        "User-Agent": USER_AGENT,
        "Accept": "application/json, image/*, */*",
    })
    for attempt in range(max_retries):
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return resp.read()
        except urllib.error.HTTPError as e:
            if e.code == 429:
                # Rate limited -- wait with exponential backoff
                wait = (2 ** attempt) * 5  # 5, 10, 20, 40, 80 seconds
                print(f"    Rate limited (429). Waiting {wait}s before retry {attempt+1}/{max_retries}...")
                time.sleep(wait)
                continue
            elif e.code in (500, 502, 503, 504):
                wait = (2 ** attempt) * 3
                print(f"    Server error ({e.code}). Waiting {wait}s before retry...")
                time.sleep(wait)
                continue
            else:
                print(f"    HTTP error {e.code}: {e.reason}")
                return None
        except Exception as e:
            if attempt < max_retries - 1:
                wait = (2 ** attempt) * 2
                print(f"    Error: {e}. Retrying in {wait}s...")
                time.sleep(wait)
                continue
            print(f"    Failed after {max_retries} attempts: {e}")
            return None
    print(f"    Exhausted all {max_retries} retries")
    return None


def api_request(params):
    """Make a request to the Wikimedia Commons API."""
    params["format"] = "json"
    url = API_URL + "?" + urllib.parse.urlencode(params)
    data = robust_request(url)
    if data:
        return json.loads(data.decode("utf-8"))
    return None


def get_thumb_url_from_filename(filename, width=800):
    """
    Construct the thumbnail URL directly from the filename using
    Wikimedia's URL structure (avoids an extra API call).

    Format: https://upload.wikimedia.org/wikipedia/commons/thumb/HASH/FILENAME/WIDTHpx-FILENAME
    """
    # Remove "File:" prefix if present
    if filename.startswith("File:"):
        filename = filename[5:]

    # Wikimedia uses MD5 hash of the filename for directory structure
    filename_encoded = filename.replace(" ", "_")
    md5 = hashlib.md5(filename_encoded.encode("utf-8")).hexdigest()

    a = md5[0]
    ab = md5[0:2]

    encoded_name = urllib.parse.quote(filename_encoded)

    # For JPEGs
    thumb_url = f"https://upload.wikimedia.org/wikipedia/commons/thumb/{a}/{ab}/{encoded_name}/{width}px-{encoded_name}"

    return thumb_url


def search_species_image(search_terms):
    """
    Search Wikimedia Commons for images of a species.
    Returns a list of candidate images sorted by score.
    """
    for term in search_terms:
        params = {
            "action": "query",
            "generator": "search",
            "gsrnamespace": "6",
            "gsrsearch": term,
            "gsrlimit": "15",
            "prop": "imageinfo",
            "iiprop": "url|size|mime|extmetadata",
            "iiurlwidth": "800",
        }

        time.sleep(API_DELAY)
        data = api_request(params)

        if not data or "query" not in data or "pages" not in data["query"]:
            continue

        candidates = []
        for page_id, page in data["query"]["pages"].items():
            if "imageinfo" not in page:
                continue
            info = page["imageinfo"][0]
            mime = info.get("mime", "")
            if mime not in ("image/jpeg", "image/png"):
                continue
            width = info.get("width", 0)
            height = info.get("height", 0)
            if width < 200 or height < 100:
                continue

            thumburl = info.get("thumburl", "")
            url = info.get("url", "")
            title = page.get("title", "")

            if not thumburl and not url:
                continue

            # Score the image
            score = 0
            title_lower = title.lower()

            # Prefer photos (JPEG) over illustrations
            if mime == "image/jpeg":
                score += 50

            # Prefer landscape orientation
            if width > height:
                score += 30

            # Prefer larger originals (better quality source)
            score += min(width / 100, 30)

            # Penalize icons/logos/maps/stamps/diagrams
            bad_words = [
                "icon", "logo", "map", "range", "distribution", "diagram",
                "chart", "stamp", "flag", "coin", "postage", "heraldic",
                "emblem", "silhouette", "skeleton", "bone", "fossil",
            ]
            for bad_word in bad_words:
                if bad_word in title_lower:
                    score -= 100

            # Boost if scientific name or common name is in the title
            for t in search_terms:
                if t.lower() in title_lower:
                    score += 20
                    break

            # Check extmetadata for photo categories
            ext = info.get("extmetadata", {})
            categories = ext.get("Categories", {}).get("value", "").lower()
            if "photograph" in categories or "photo" in categories:
                score += 20

            # Penalize SVGs that somehow got through
            if ".svg" in title_lower:
                score -= 200

            candidates.append({
                "title": title,
                "url": url,
                "thumburl": thumburl,
                "thumbwidth": info.get("thumbwidth", 800),
                "thumbheight": info.get("thumbheight", 0),
                "width": width,
                "height": height,
                "mime": mime,
                "score": score,
            })

        if candidates:
            candidates.sort(key=lambda c: c["score"], reverse=True)
            return candidates

    return []


def download_image(url, dest_path):
    """Download an image from a URL to a local file with retry logic."""
    data = robust_request(url, timeout=60)
    if data:
        with open(dest_path, "wb") as f:
            f.write(data)
        return True
    return False


def create_contents_json(imageset_dir, filename):
    """Create the Xcode Contents.json for an imageset."""
    contents = {
        "images": [
            {
                "filename": filename,
                "idiom": "universal",
                "scale": "1x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    path = os.path.join(imageset_dir, "Contents.json")
    with open(path, "w") as f:
        json.dump(contents, f, indent=2)
        f.write("\n")


def main():
    os.makedirs(ASSETS_BASE, exist_ok=True)

    successes = []
    failures = []
    skipped = []

    total = len(SPECIES)
    print(f"Downloading photos for {total} Saskatchewan fish species")
    print(f"Target: {ASSETS_BASE}")
    print(f"API delay: {API_DELAY}s, Download delay: {DOWNLOAD_DELAY}s")
    print("=" * 70)

    for idx, (fish_id, sci_name, common_name, search_override) in enumerate(SPECIES):
        padded_id = f"{fish_id:03d}"
        label = f"fish_{padded_id}: {common_name}"
        if sci_name:
            label += f" ({sci_name})"
        print(f"\n[{idx+1}/{total}] {label}")

        # Build search terms
        if search_override:
            search_terms = list(search_override)
        else:
            search_terms = [sci_name]
            if common_name:
                search_terms.append(common_name)

        # Check if already downloaded
        imageset_dir = os.path.join(ASSETS_BASE, f"fish_{padded_id}.imageset")
        if os.path.exists(imageset_dir):
            existing_files = os.listdir(imageset_dir)
            image_files = [f for f in existing_files if f.endswith((".png", ".jpg", ".jpeg"))]
            if image_files:
                print(f"  Already exists ({image_files[0]}), skipping")
                skipped.append((fish_id, common_name))
                continue

        # Search for images
        print(f"  Searching: {', '.join(search_terms[:2])}...")
        candidates = search_species_image(search_terms)

        if not candidates:
            print(f"  FAILED: No images found for any search term")
            failures.append((fish_id, common_name, "No images found"))
            continue

        best = candidates[0]
        ext = ".jpg" if best["mime"] == "image/jpeg" else ".png"
        filename = f"fish_{padded_id}{ext}"

        print(f"  Best: {best['title'][:70]} (score={best['score']:.0f})")

        # Create imageset directory
        os.makedirs(imageset_dir, exist_ok=True)

        # Download the thumbnail
        dest_path = os.path.join(imageset_dir, filename)
        download_url = best["thumburl"] or best["url"]

        print(f"  Downloading...")
        time.sleep(DOWNLOAD_DELAY)

        if download_image(download_url, dest_path):
            fsize = os.path.getsize(dest_path)
            if fsize < 1000:
                print(f"  FAILED: File too small ({fsize} bytes), removing")
                os.remove(dest_path)
                failures.append((fish_id, common_name, f"File too small ({fsize} bytes)"))
                continue

            create_contents_json(imageset_dir, filename)
            print(f"  OK: {filename} ({fsize:,} bytes)")
            successes.append((fish_id, common_name, filename, fsize))
        else:
            # Clean up empty imageset dir
            try:
                os.rmdir(imageset_dir)
            except OSError:
                pass
            failures.append((fish_id, common_name, "Download failed"))

    # Summary
    print("\n" + "=" * 70)
    print("DOWNLOAD SUMMARY")
    print("=" * 70)
    print(f"Total species:  {total}")
    print(f"Successful:     {len(successes)}")
    print(f"Already existed:{len(skipped)}")
    print(f"Failed:         {len(failures)}")

    if failures:
        print(f"\nFAILED SPECIES ({len(failures)}):")
        for fish_id, name, reason in failures:
            print(f"  fish_{fish_id:03d} {name}: {reason}")

    if successes:
        total_bytes = sum(s[3] for s in successes)
        print(f"\nNewly downloaded: {total_bytes / 1024 / 1024:.1f} MB across {len(successes)} images")

    if skipped:
        print(f"\nSkipped (already downloaded): {len(skipped)} species")

    print()
    return len(failures)


if __name__ == "__main__":
    sys.exit(main())
