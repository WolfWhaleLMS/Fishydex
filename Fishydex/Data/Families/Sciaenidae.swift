import Foundation

// MARK: - Family 17: Sciaenidae (Drums) — 1 species + additional exotics

extension Fish {
    static let sciaenidae: [Fish] = [
        Fish(
            id: 82,
            commonName: "Freshwater Drum",
            scientificName: "Aplodinotus grunniens",
            family: "Sciaenidae",
            familyCommonName: "Drums",
            category: .coarseFish,
            rarityTier: .legendary,
            conservationStatus: "Status uncertain",
            cosewicStatus: nil,
            sizeRange: "Up to 50 cm",
            maxWeight: nil,
            description: "The only North American freshwater member of the predominantly marine drum family. The freshwater drum has a deep, laterally compressed body with a humped back, a bluntly rounded snout, and a subterminal mouth. The body is silvery-grey with a distinctive lateral line that extends onto the rounded caudal fin — unique among Saskatchewan fish. Males produce a distinctive drumming or grunting sound by vibrating muscles against their swim bladder. In Saskatchewan, this species is essentially a ghost — known from only two dead specimens.",
            habitat: "In its main range, inhabits large, warm rivers and lakes with sandy or silty bottoms. In Saskatchewan, known only from two dead specimens collected from Swift Current Creek in 1953. May represent vagrants rather than an established population.",
            funFact: "The freshwater drum is Saskatchewan's most mysterious fish — known only from two dead specimens found in Swift Current Creek in 1953. Whether it ever had a living population in the province remains an unsolved ichthyological mystery.",
            isNative: true
        ),
    ]

    // MARK: - Additional Exotics (no family file — housed here)

    static let additionalExotics: [Fish] = [
        Fish(
            id: 83,
            commonName: "Grass Carp",
            scientificName: "Ctenopharyngodon idella",
            family: "Cyprinidae",
            familyCommonName: "Minnows & Carps",
            category: .exotic,
            rarityTier: .rare,
            conservationStatus: "SNA (exotic)",
            cosewicStatus: nil,
            sizeRange: "Up to 100 cm",
            maxWeight: nil,
            description: "One of the largest members of the carp family, the grass carp is a robust, elongated fish with large scales, a broad flat head, and a terminal mouth with specialized pharyngeal teeth adapted for shredding aquatic vegetation. The body is olive to silvery-green with darker scale edges creating a cross-hatched pattern. Native to eastern Asia, grass carp were introduced to North America for aquatic weed control. Only sterile (triploid) individuals are permitted for stocking in Saskatchewan.",
            habitat: "Large rivers, lakes, and reservoirs with abundant aquatic vegetation. In Saskatchewan, only sterile (triploid) grass carp are stocked in specific water bodies for aquatic vegetation management. Cannot reproduce in the province.",
            funFact: "Grass carp are herbivorous machines that can consume their own body weight in aquatic vegetation every day. Only sterile (triploid) individuals are allowed in Saskatchewan to prevent them from establishing wild populations.",
            isNative: false
        ),
        Fish(
            id: 84,
            commonName: "American Eel",
            scientificName: "Anguilla rostrata",
            family: "Anguillidae",
            familyCommonName: "Freshwater Eels",
            category: .exotic,
            rarityTier: .legendary,
            conservationStatus: "SNA (exotic)",
            cosewicStatus: nil,
            sizeRange: "Up to 100 cm",
            maxWeight: nil,
            description: "A distinctive snake-like fish with an elongated, sinuous body, a continuous fin running from the middle of the back around the tail to the belly, and tiny embedded scales nearly invisible to the naked eye. The body is dark olive-brown to greenish above with a pale yellow belly. American eels have one of the most remarkable life cycles of any fish — they are born in the Sargasso Sea, migrate to freshwater rivers to grow, then return to the ocean to spawn and die. In landlocked Saskatchewan, eels cannot complete this migration.",
            habitat: "Rivers, lakes, and estuaries in their native Atlantic coastal range. Occasional specimens appear in Saskatchewan through bait bucket introductions or aquarium releases, but the species cannot complete its life cycle in the landlocked province.",
            funFact: "American eels are born in the Sargasso Sea in the middle of the Atlantic Ocean, migrate thousands of kilometres to freshwater rivers, live for decades, then return to the ocean to spawn and die. In landlocked Saskatchewan, they are trapped — unable to complete the most epic fish migration on Earth.",
            isNative: false
        ),
    ]
}
