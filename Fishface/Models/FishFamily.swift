import Foundation

struct FishFamily: Identifiable, Hashable {
    let id: String               // Scientific name used as stable identifier
    let name: String             // Scientific family name (e.g. "Salmonidae")
    let commonName: String       // Common family name (e.g. "Salmon, Trout & Whitefish")
    let description: String      // Brief family description

    /// All 16 Saskatchewan freshwater fish families.
    static let allFamilies: [FishFamily] = [
        FishFamily(
            id: "petromyzontidae",
            name: "Petromyzontidae",
            commonName: "Lampreys",
            description: "Primitive jawless fish with eel-like bodies and circular, sucker-like mouths. Among the oldest living vertebrates."
        ),
        FishFamily(
            id: "acipenseridae",
            name: "Acipenseridae",
            commonName: "Sturgeons",
            description: "Ancient armoured fish with bony scutes instead of scales. Among the largest and longest-lived freshwater fish in North America."
        ),
        FishFamily(
            id: "catostomidae",
            name: "Catostomidae",
            commonName: "Suckers",
            description: "Bottom-feeding fish with fleshy, downward-facing lips adapted for vacuum-feeding on invertebrates and organic matter."
        ),
        FishFamily(
            id: "esocidae",
            name: "Esocidae",
            commonName: "Pikes",
            description: "Ambush predators with elongated bodies, duck-bill snouts, and a mouthful of sharp teeth. Saskatchewan's quintessential sport fish."
        ),
        FishFamily(
            id: "umbridae",
            name: "Umbridae",
            commonName: "Mudminnows",
            description: "Small, hardy fish capable of breathing atmospheric air and surviving in low-oxygen environments by burrowing into mud."
        ),
        FishFamily(
            id: "gadidae",
            name: "Gadidae",
            commonName: "Cods",
            description: "Primarily marine family; the burbot is the only freshwater member in North America. Cold-water bottom dwellers."
        ),
        FishFamily(
            id: "gasterosteidae",
            name: "Gasterosteidae",
            commonName: "Sticklebacks",
            description: "Tiny fish armed with sharp dorsal spines. Males build elaborate nests and guard eggs with fierce territorial behaviour."
        ),
        FishFamily(
            id: "hiodontidae",
            name: "Hiodontidae",
            commonName: "Mooneyes",
            description: "Silvery, herring-like fish with large reflective eyes adapted for low-light feeding. Endemic to North America."
        ),
        FishFamily(
            id: "osmeridae",
            name: "Osmeridae",
            commonName: "Smelts",
            description: "Small, slender schooling fish known for their distinctive cucumber-like odour. Primarily anadromous but some landlocked populations exist."
        ),
        FishFamily(
            id: "centrarchidae",
            name: "Centrarchidae",
            commonName: "Sunfishes & Basses",
            description: "Warm-water fish native to eastern North America. Includes bass, crappie, and sunfish. Most Saskatchewan populations are introduced."
        ),
        FishFamily(
            id: "percidae",
            name: "Percidae",
            commonName: "Perches & Darters",
            description: "Diverse family including Saskatchewan's most prized sport fish (walleye) and colourful bottom-dwelling darters."
        ),
        FishFamily(
            id: "percopsidae",
            name: "Percopsidae",
            commonName: "Trout-perches",
            description: "Small, enigmatic fish combining features of both trout (adipose fin) and perch (spiny rays). Nocturnal and secretive."
        ),
        FishFamily(
            id: "salmonidae",
            name: "Salmonidae",
            commonName: "Salmon, Trout & Whitefish",
            description: "Cold-water fish prized by anglers. Includes Saskatchewan's only native trout (lake trout), commercially harvested whitefish, and numerous stocked species."
        ),
        FishFamily(
            id: "cottidae",
            name: "Cottidae",
            commonName: "Sculpins",
            description: "Small, bottom-dwelling fish with large flattened heads and fan-like pectoral fins. Indicators of clean, well-oxygenated water."
        ),
        FishFamily(
            id: "ictaluridae",
            name: "Ictaluridae",
            commonName: "Catfishes",
            description: "Scaleless fish with prominent whisker-like barbels, sharp pectoral and dorsal spines, and excellent senses of smell and taste."
        ),
        FishFamily(
            id: "sciaenidae",
            name: "Sciaenidae",
            commonName: "Drums",
            description: "Fish that produce a distinctive drumming sound using specialized muscles on their swim bladder. Primarily a marine family."
        ),
    ]

    /// Look up a family by its scientific name.
    static func family(named name: String) -> FishFamily? {
        allFamilies.first { $0.name == name }
    }
}
