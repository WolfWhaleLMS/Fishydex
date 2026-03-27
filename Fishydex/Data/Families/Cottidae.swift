import Foundation

// MARK: - Family 15: Cottidae (Sculpins) — 3 species

extension Fish {
    static let cottidae: [Fish] = [
        Fish(
            id: 74,
            commonName: "Slimy Sculpin",
            scientificName: "Cottus cognatus",
            family: "Cottidae",
            familyCommonName: "Sculpins",
            category: .forageFish,
            rarityTier: .common,
            conservationStatus: "S4 (apparently secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 10 cm",
            maxWeight: nil,
            description: "A small, bottom-dwelling fish with a large, flattened head, wide fan-like pectoral fins, and a mottled dark brown to olive body that provides excellent camouflage on rocky substrates. The skin is smooth and scaleless (hence \"slimy\"). The eyes are positioned on top of the head, and the body tapers sharply from the oversized head to the narrow tail. Slimy sculpins lack a swim bladder and rest directly on the bottom. Feeds on aquatic insect larvae, particularly stoneflies and mayflies.",
            habitat: "Cold, clear streams and lake bottoms with rocky, gravel, or cobble substrates throughout Saskatchewan. An important indicator species — their presence signals clean, well-oxygenated water. Common in boreal streams and along rocky lake shorelines.",
            funFact: "Slimy sculpins are excellent indicators of water quality — if you find them in a stream, the water is clean and well-oxygenated. Males guard their eggs by wedging themselves into cavities under rocks, fanning the eggs continuously until they hatch.",
            isNative: true
        ),
        Fish(
            id: 75,
            commonName: "Spoonhead Sculpin",
            scientificName: "Cottus ricei",
            family: "Cottidae",
            familyCommonName: "Sculpins",
            category: .forageFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 9 cm",
            maxWeight: nil,
            description: "A small, bottom-dwelling sculpin distinguished from the slimy sculpin by its broader, more flattened head (spoon-shaped when viewed from above) and its preference for deeper water habitats. The body is mottled brown with darker saddle markings and pale spots. Like all sculpins, it has a large head, fan-like pectoral fins, and no swim bladder, spending its life resting on and darting across the bottom substrate.",
            habitat: "Deep, cold lake bottoms in northern Saskatchewan, typically over rocky or sandy substrates in water deeper than where slimy sculpins are found. Also in some cold rivers. Common in northern shield lakes.",
            funFact: "Spoonhead sculpins are deeper-water specialists than their relative the slimy sculpin. When viewed from above, their flattened head resembles the bowl of a spoon — the feature that gives them their name.",
            isNative: true
        ),
        Fish(
            id: 76,
            commonName: "Deepwater Sculpin",
            scientificName: "Myoxocephalus thompsonii",
            family: "Cottidae",
            familyCommonName: "Sculpins",
            category: .forageFish,
            rarityTier: .uncommon,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 9 cm",
            maxWeight: nil,
            description: "A small, cold-adapted sculpin that lives in the deepest, coldest layers of northern lakes — a true relict of the last Ice Age. The body is similar to other sculpins: large flattened head, fan-like pectoral fins, mottled brown colouration, and no swim bladder. Distinguished by its proportionally larger head and eyes compared to other sculpins, and its preference for very deep, near-freezing water. Feeds on benthic amphipods and insect larvae on deep lake floors.",
            habitat: "Very deep, cold lakes in northern Saskatchewan, typically found at depths exceeding 30 metres where water temperatures remain near 4°C year-round. A marine relict species — its closest relatives are saltwater sculpins, suggesting it became isolated in deep freshwater lakes as glaciers retreated.",
            funFact: "The deepwater sculpin is a marine relict — its closest relatives are saltwater species. It became trapped in deep freshwater lakes when the glaciers retreated after the last Ice Age, more than 10,000 years ago, and has lived in the cold depths ever since.",
            isNative: true
        ),
    ]
}
