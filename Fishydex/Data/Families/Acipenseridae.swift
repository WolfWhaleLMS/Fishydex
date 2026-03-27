import Foundation

// MARK: - Family 2: Acipenseridae (Sturgeons) — 1 species

extension Fish {
    static let acipenseridae: [Fish] = [
        Fish(
            id: 2,
            commonName: "Lake Sturgeon",
            scientificName: "Acipenser fulvescens",
            family: "Acipenseridae",
            familyCommonName: "Sturgeons",
            category: .sportFish,
            rarityTier: .legendary,
            conservationStatus: "S2 (imperiled)",
            cosewicStatus: "Endangered",
            sizeRange: "Can exceed 1.5 m",
            maxWeight: "45+ kg",
            description: "Saskatchewan's largest freshwater fish and a living fossil that has remained virtually unchanged for over 150 million years. The lake sturgeon has a cartilaginous skeleton reinforced by five rows of bony scutes, a flat shovel-shaped snout, and four sensory barbels on the underside of the head used to detect prey on the bottom. Dorsal colouration ranges from dark olive to grey-brown with a pale underside. Strictly catch-and-release in Saskatchewan due to imperiled status.",
            habitat: "Large rivers and lakes including the Saskatchewan River, Cumberland Lake, Tobin Lake, and the Churchill River system. Prefers deep runs over sand, gravel, or rocky bottoms. Spawns in fast-flowing river reaches over cobble substrates in spring.",
            funFact: "Lake sturgeon can live over 100 years and do not reach sexual maturity until 15-25 years of age. A single large female can carry over 300,000 eggs. They are Saskatchewan's only strictly catch-and-release sport fish.",
            isNative: true
        ),
    ]
}
