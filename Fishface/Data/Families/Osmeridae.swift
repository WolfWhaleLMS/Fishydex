import Foundation

// MARK: - Family 10: Osmeridae (Smelts) — 1 species

extension Fish {
    static let osmeridae: [Fish] = [
        Fish(
            id: 17,
            commonName: "Rainbow Smelt",
            scientificName: "Osmerus mordax",
            family: "Osmeridae",
            familyCommonName: "Smelts",
            category: .exotic,
            rarityTier: .rare,
            conservationStatus: "SNA (exotic)",
            cosewicStatus: nil,
            sizeRange: "Up to 20 cm",
            maxWeight: nil,
            description: "A small, slender, silvery fish with an adipose fin and a pointed snout with prominent teeth. The body is translucent silvery-green with iridescent rainbow reflections along the sides. Rainbow smelt are anadromous in their native range but become landlocked when introduced to inland waters. They have not established self-sustaining populations in Saskatchewan despite introduction attempts.",
            habitat: "Cold, deep lakes. Native to the Atlantic coast and Great Lakes basin. Introductions into Saskatchewan waters have not resulted in established populations.",
            funFact: "Rainbow smelt are famous for their distinctive cucumber-like odour — freshly caught smelt genuinely smell like fresh cucumbers. This odd trait is caused by a chemical compound called trans-2-cis-6-nonadienal in their skin.",
            isNative: false
        ),
    ]
}
