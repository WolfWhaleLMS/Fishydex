import Foundation

// MARK: - Family 6: Umbridae (Mudminnows) — 1 species

extension Fish {
    static let umbridae: [Fish] = [
        Fish(
            id: 35,
            commonName: "Central Mudminnow",
            scientificName: "Umbra limi",
            family: "Umbridae",
            familyCommonName: "Mudminnows",
            category: .forageFish,
            rarityTier: .legendary,
            conservationStatus: "S2 (imperiled)",
            cosewicStatus: nil,
            sizeRange: "Up to 10 cm",
            maxWeight: nil,
            description: "A small, stout fish with a rounded tail — unusual among Saskatchewan species, which almost all have forked or emarginate tails. The body is dark olive-brown with faint vertical bars and a dark bar at the base of the tail. Remarkable for its ability to breathe atmospheric air using a modified swim bladder, and to survive drought by burrowing tail-first into soft mud. One of the rarest fish species in Saskatchewan.",
            habitat: "Found only in the Carrot River drainage in east-central Saskatchewan. Inhabits heavily vegetated, slow-moving streams, beaver ponds, and boggy wetlands with soft, muddy substrates and low dissolved oxygen.",
            funFact: "The central mudminnow can survive being frozen in ice and can breathe air directly, allowing it to live in stagnant, oxygen-depleted water that would kill other fish. It burrows tail-first into mud to survive droughts and winters — a truly remarkable survival specialist.",
            isNative: true
        ),
    ]
}
