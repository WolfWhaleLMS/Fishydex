# Fishface — Saskatchewan Fish Pokedex (iOS App)

**Date:** 2026-03-27
**Status:** Approved

---

## Overview

Fishface is a standalone iOS app that functions as a real Pokedex — but for every fish species in Saskatchewan. Users discover and collect fish entries by logging catches. Undiscovered fish appear as dark silhouettes; caught fish reveal full-color entries with real photos, scientific data, habitat info, and stats. Includes an AR Scanner mode for the authentic Pokedex scanning experience.

**Target:** iPhone (iOS 17+), SwiftUI, local-only (no backend).

---

## Fish Database

84 species across 17 families. Each fish entry contains:

| Field | Type | Example |
|-------|------|---------|
| id | Int (1–84) | 34 |
| commonName | String | "Northern Pike" |
| scientificName | String | "Esox lucius" |
| family | String | "Esocidae" |
| familyCommonName | String | "Pikes" |
| category | Enum | .sportFish / .forageFish / .coarseFish / .invasive / .exotic / .hybrid |
| rarityTier | Enum | .common / .uncommon / .rare / .legendary |
| conservationStatus | String? | "S5 (secure)" |
| cosewicStatus | String? | "Endangered" |
| sizeRange | String | "50–120 cm" |
| maxWeight | String? | "19+ kg" |
| description | String | Full species description |
| habitat | String | Habitat and waters description |
| funFact | String? | "Also called 'jackfish' in Saskatchewan" |
| imageName | String | Asset catalog reference |
| silhouetteImageName | String | Dark silhouette version |
| isNative | Bool | true |

### Categories by count:
- **Sport Fish:** ~21 (walleye, pike, lake trout, perch, sauger, grayling, etc.)
- **Forage/Bait Fish:** ~30 (shiners, daces, chubs, darters, sculpins, sticklebacks)
- **Coarse Fish:** ~10 (suckers, redhorse, buffalo, bullheads)
- **Invasive/Exotic:** ~12 (carp, introduced trout/bass/salmon)
- **Hybrids:** 2 (splake, tiger trout)
- **Species at Risk:** 11 species flagged (lake sturgeon, shortjaw cisco, plains sucker, etc.)

### Rarity Tiers:
- **Common** (green): Province-wide, abundant (pike, perch, walleye, fathead minnow, etc.)
- **Uncommon** (blue): Regional distribution, moderate abundance (goldeye, rock bass, etc.)
- **Rare** (purple): Limited range or imperiled (channel catfish, stonecat, central mudminnow)
- **Legendary** (gold): Critically imperiled or iconic (lake sturgeon, shortjaw cisco, plains sucker, freshwater drum)

---

## Architecture

Follows WolfWhale iOS patterns:

```
Fishface/
├── FishfaceApp.swift                    # App entry point
├── Config/
│   └── AppConfig.swift                  # App-wide constants
├── Models/
│   ├── Fish.swift                       # Fish data model
│   ├── FishCategory.swift               # Category enum
│   ├── RarityTier.swift                 # Rarity enum
│   ├── CatchRecord.swift                # User catch record model
│   └── FishFamily.swift                 # Family grouping
├── Data/
│   ├── FishDatabase.swift               # All 84 fish entries (static data)
│   ├── Families/
│   │   ├── Petromyzontidae.swift        # Lampreys (1)
│   │   ├── Acipenseridae.swift          # Sturgeons (1)
│   │   ├── Catostomidae.swift           # Suckers (7)
│   │   ├── Cyprinidae.swift             # Minnows & Carps (24)
│   │   ├── Esocidae.swift               # Pikes (1)
│   │   ├── Umbridae.swift               # Mudminnows (1)
│   │   ├── Gadidae.swift                # Cods (1)
│   │   ├── Gasterosteidae.swift         # Sticklebacks (2)
│   │   ├── Hiodontidae.swift            # Mooneyes (2)
│   │   ├── Osmeridae.swift              # Smelts (1)
│   │   ├── Centrarchidae.swift          # Sunfishes & Basses (6)
│   │   ├── Percidae.swift               # Perches & Darters (8)
│   │   ├── Percopsidae.swift            # Trout-perches (1)
│   │   ├── Salmonidae.swift             # Salmon/Trout/Whitefish (17)
│   │   ├── Cottidae.swift               # Sculpins (3)
│   │   ├── Ictaluridae.swift            # Catfishes (5)
│   │   └── Sciaenidae.swift             # Drums (1)
│   └── SeedData.swift                   # Assembles all families
├── Services/
│   ├── CatchService.swift               # Actor: manages catch records (SwiftData)
│   ├── LocationService.swift            # Actor: GPS location tracking
│   └── HapticsService.swift             # Haptic feedback for catches/reveals
├── ViewModels/
│   ├── PokedexViewModel.swift           # Grid state, filtering, search, progress
│   ├── FishDetailViewModel.swift        # Single fish entry state
│   ├── ScannerViewModel.swift           # AR scanner camera state
│   └── StatsViewModel.swift             # Collection stats & achievements
├── Views/
│   ├── Shell/
│   │   ├── PokedexShellView.swift       # Red Pokedex outer shell frame
│   │   └── PokedexHingeView.swift       # Animated hinge/open effect
│   ├── Pokedex/
│   │   ├── PokedexGridView.swift        # Main grid of all fish
│   │   ├── PokedexEntryCell.swift       # Single cell (silhouette vs revealed)
│   │   ├── PokedexSearchBar.swift       # Search + filter controls
│   │   └── PokedexProgressBar.swift     # "X of 84 Discovered"
│   ├── Detail/
│   │   ├── FishDetailView.swift         # Full Pokedex entry screen
│   │   ├── FishStatsView.swift          # Stats bars (size, rarity, etc.)
│   │   ├── FishTypeBadge.swift          # Category/type badge
│   │   ├── FishHabitatView.swift        # Habitat & waters info
│   │   └── FishRevealAnimation.swift    # Silhouette → reveal transition
│   ├── Scanner/
│   │   ├── ScannerView.swift            # AR camera scanner view
│   │   ├── ScannerHUDView.swift         # Pokedex HUD overlay on camera
│   │   ├── ScannerReticle.swift         # Targeting reticle animation
│   │   └── ScannerCaptureButton.swift   # Capture/scan button
│   ├── ARDisplay/
│   │   ├── ARFishCardView.swift         # AR floating fish entry card
│   │   └── ARContainerView.swift        # RealityKit AR session wrapper
│   ├── Catch/
│   │   ├── CatchLogView.swift           # Log a new catch
│   │   ├── CatchHistoryView.swift       # Past catches timeline
│   │   └── CatchPhotoView.swift         # Photo attachment
│   ├── Stats/
│   │   ├── CollectionStatsView.swift    # Overall progress & achievements
│   │   └── FamilyProgressView.swift     # Per-family completion
│   └── Components/
│       ├── ScanLineOverlay.swift        # CRT scan line effect
│       ├── PokedexButton.swift          # Styled button (Pokedex aesthetic)
│       ├── RarityGlow.swift             # Glow effect by rarity tier
│       ├── TypeBadge.swift              # Colored type badge component
│       └── PixelText.swift              # Pixel/retro styled text
├── Utilities/
│   ├── PokedexTheme.swift               # Colors, fonts, spacing constants
│   └── Extensions.swift                 # Convenience extensions
├── Assets.xcassets/
│   ├── Fish/                            # 84 fish photos (real images)
│   ├── Silhouettes/                     # 84 fish silhouettes
│   ├── UI/                              # Pokedex shell textures, icons
│   └── Colors/                          # Theme colors
└── Preview Content/
    └── PreviewData.swift                # Sample data for previews
```

### Key Architecture Decisions:

1. **SwiftData** for persistence (catch records, discovery state) — modern, SwiftUI-native
2. **Static fish data** compiled into the app (no network needed)
3. **Actor-based services** for CatchService and LocationService (thread safety)
4. **@Observable + @MainActor** ViewModels (matching WolfWhale patterns)
5. **No backend** — fully offline-capable, all data local

---

## Visual Design

### Pokedex Shell
- **Primary red** (#DC0A2D) with darker red accents (#A00020)
- Metallic silver bezels and borders
- Rounded corners with subtle 3D depth (shadows, highlights)
- The app itself IS the Pokedex — the red shell frames every screen

### Screen Area (inside the shell)
- Dark background (#1a1a2e) with slight green-tint CRT effect
- Scan line overlay (subtle, semi-transparent horizontal lines)
- Pixel-style entry numbers: #001, #002, etc.
- Green (#00ff41) accent text for "data readout" elements

### Type Badge Colors
| Category | Color | Hex |
|----------|-------|-----|
| Sport Fish | Ocean Blue | #3B82F6 |
| Forage Fish | Forest Green | #22C55E |
| Coarse Fish | Amber | #F59E0B |
| Invasive | Red | #EF4444 |
| Exotic (Introduced) | Purple | #A855F7 |
| Hybrid | Teal | #14B8A6 |
| At Risk | Gold | #EAB308 |

### Rarity Glow Effects
- **Common:** No glow
- **Uncommon:** Subtle blue pulse
- **Rare:** Purple shimmer
- **Legendary:** Gold particle effect with glow

### Typography
- Entry numbers: Monospace/pixel font
- Fish names: Bold system font (SF Pro Bold)
- Scientific names: Italic system font
- Data readout text: Monospace with green tint

---

## Core Screens & User Flows

### 1. App Launch → Pokedex Open Animation
- Red Pokedex shell appears closed
- Hinge animation opens it (like opening a real Pokedex)
- Reveals the grid view inside

### 2. Pokedex Grid (Home)
- Scrollable grid (3 columns) of all 84 fish
- Each cell shows: entry number, silhouette OR revealed image, common name
- Undiscovered = dark silhouette + "???" name + entry number
- Discovered = full color image + name + type badge
- Top: search bar + filter chips (All / Sport / Forage / Invasive / Caught / Uncaught)
- Bottom: progress bar "32 of 84 Discovered"
- Tab bar: Pokedex | Scanner | Catches | Stats

### 3. Fish Detail (tap a discovered fish)
- Large fish photo at top with Pokedex frame
- Entry number badge (#034)
- Common name + scientific name (italic)
- Type badges row
- Rarity tier indicator with appropriate glow
- Stats section: size range, max weight, conservation status
- Description text (scrollable)
- Habitat & waters section
- Fun fact callout (if available)
- "View in AR" button → AR card display
- Catch history for this species (dates, locations, photos)
- "Log a Catch" button

### 4. Fish Detail (tap an undiscovered fish)
- Silhouette only — no photo
- Entry number shown
- "???" for name
- "Catch this fish to unlock its entry!"
- Category hint: "This is a Sport Fish" (optional — could hide for more mystery)

### 5. Scanner Mode (tab 2)
- Full-screen camera view
- Pokedex HUD overlay:
  - Red frame borders (Pokedex shell aesthetic)
  - Targeting reticle in center (animated — rotating, pulsing)
  - "SCANNING..." text with data stream animation
  - Corner readouts: GPS coordinates, date/time
- Large capture button at bottom (styled as Pokedex button)
- Tap capture:
  - Camera shutter + haptic feedback
  - Photo captured with HUD overlay baked in
  - Prompt: "Which fish did you catch?" → species picker
  - If new species: REVEAL ANIMATION (silhouette dissolves into full color, confetti, haptic burst)
  - Entry logged with photo, GPS, timestamp

### 6. Catch Log (tab 3)
- Timeline of all catches, newest first
- Each entry: fish photo, name, date, location, user's photo
- Tap to view full catch detail
- Filter by species, date range

### 7. Stats (tab 4)
- Overall: "32/84 Discovered (38%)" with circular progress ring
- Per-family completion bars (e.g., "Salmonidae: 8/17")
- Per-category completion (Sport: 15/21, Forage: 10/30, etc.)
- Rarity breakdown: Common 20/35, Uncommon 8/20, Rare 3/18, Legendary 1/11
- Achievements/badges (optional v1 stretch):
  - "First Catch" — Log your first fish
  - "Pike Master" — Catch a northern pike
  - "Deep Diver" — Discover a sculpin
  - "Living Fossil" — Discover the lake sturgeon
  - "Invasive Hunter" — Discover all invasive species
  - "Saskatchewan Angler" — Discover 50% of all fish
  - "Pokedex Complete" — Discover all 84 species

### 8. AR Fish Card (from detail view)
- RealityKit AR session
- Floating holographic card in real space
- Card shows: fish image, name, entry number, key stats
- Card rotates slowly, has subtle glow
- User can walk around it, screenshot it

---

## AR Scanner — Technical Detail

### Camera Scanner (AVFoundation — not full ARKit)
The scanner is a camera overlay, not a full AR scene. This keeps it lightweight:

```
AVCaptureSession → Camera preview layer
    ↓
SwiftUI overlay (ScannerHUDView)
    ├── Red Pokedex frame border
    ├── Animated reticle (rotating square brackets)
    ├── "SCANNING..." text + data stream
    ├── GPS coordinates readout
    └── Capture button
```

On capture:
1. Snapshot the camera frame
2. Composite the HUD overlay onto the image
3. Save to catch record
4. Prompt species selection
5. If new species → trigger reveal animation

### AR Card Display (RealityKit)
Separate from scanner. Used in detail view for "View in AR":

```
ARView (RealityKit)
    ├── AnchorEntity (horizontal plane)
    │   └── ModelEntity (card mesh)
    │       ├── Fish image texture
    │       ├── Stats text texture
    │       └── Glow material (rarity-based)
    └── Slow rotation animation
```

---

## Data Persistence (SwiftData)

### Models:

```swift
@Model
class CatchRecord {
    var id: UUID
    var fishId: Int           // References Fish.id (1-84)
    var caughtDate: Date
    var latitude: Double?
    var longitude: Double?
    var locationName: String? // Reverse geocoded
    var photoData: Data?      // User's photo
    var notes: String?
}

@Model
class DiscoveryState {
    var fishId: Int
    var isDiscovered: Bool
    var firstDiscoveredDate: Date?
    var totalCatches: Int
}
```

---

## Fish Images Strategy

For v1, use placeholder silhouette images generated programmatically (solid dark fish shapes). For real photos:
- Source from public domain / Creative Commons (Wikimedia Commons, USFWS, state/provincial wildlife agencies)
- Saskatchewan government fish identification guides have photos
- Each fish gets a primary photo (profile view) and a generated silhouette

Asset naming convention:
- `fish_001_northern_pike.jpg` (photo)
- `fish_001_northern_pike_silhouette.png` (silhouette, transparent background)

---

## Complete Species List (ordered by Pokedex number)

#001 Chestnut Lamprey | #002 Lake Sturgeon | #003 Quillback | #004 Longnose Sucker | #005 White Sucker | #006 Plains Sucker | #007 Bigmouth Buffalo | #008 Silver Redhorse | #009 Shorthead Redhorse | #010 Northern Redbelly Dace | #011 Finescale Dace | #012 Lake Chub | #013 Western Silvery Minnow | #014 Brassy Minnow | #015 Plains Minnow | #016 Common Shiner | #017 Pearl Dace | #018 Sand Shiner | #019 Golden Shiner | #020 Emerald Shiner | #021 River Shiner | #022 Blacknose Shiner | #023 Spottail Shiner | #024 Weed Shiner | #025 Mimic Shiner | #026 Fathead Minnow | #027 Flathead Chub | #028 Longnose Dace | #029 Blacknose Dace | #030 Creek Chub | #031 Goldfish | #032 Prussian Carp | #033 Common Carp | #034 Northern Pike | #035 Central Mudminnow | #036 Burbot | #037 Brook Stickleback | #038 Ninespine Stickleback | #039 Goldeye | #040 Mooneye | #041 Rainbow Smelt | #042 Rock Bass | #043 Bluegill | #044 Smallmouth Bass | #045 Largemouth Bass | #046 White Crappie | #047 Black Crappie | #048 Iowa Darter | #049 Johnny Darter | #050 Yellow Perch | #051 Logperch | #052 Blackside Darter | #053 River Darter | #054 Sauger | #055 Walleye | #056 Trout-perch | #057 Cisco | #058 Lake Whitefish | #059 Shortjaw Cisco | #060 Cutthroat Trout | #061 Coho Salmon | #062 Rainbow Trout | #063 Kokanee | #064 Round Whitefish | #065 Mountain Whitefish | #066 Atlantic Salmon | #067 Brown Trout | #068 Tiger Trout | #069 Arctic Char | #070 Brook Trout | #071 Splake | #072 Lake Trout | #073 Arctic Grayling | #074 Slimy Sculpin | #075 Spoonhead Sculpin | #076 Deepwater Sculpin | #077 Black Bullhead | #078 Brown Bullhead | #079 Channel Catfish | #080 Stonecat | #081 Tadpole Madtom | #082 Freshwater Drum | #083 Grass Carp | #084 American Eel

---

## Scope

### v1 (this build):
- All 84 fish with full data
- Pokedex grid with silhouette/reveal mechanic
- Fish detail views
- Camera scanner with Pokedex HUD
- Catch logging with GPS + photo
- SwiftData persistence
- Collection stats + progress
- AR fish card display
- Pokedex shell visual design
- Haptic feedback on catches/reveals

### NOT in v1:
- ML fish identification from camera
- Social features / sharing
- Leaderboards
- Apple Watch companion
- Backend / cloud sync
- iPad layout
