import Foundation

// MARK: - Family 13: Percopsidae (Trout-perches) — 1 species

extension Fish {
    static let percopsidae: [Fish] = [
        Fish(
            id: 56,
            commonName: "Trout-perch",
            scientificName: "Percopsis omiscomaycus",
            family: "Percopsidae",
            familyCommonName: "Trout-perches",
            category: .forageFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 12 cm",
            maxWeight: nil,
            description: "A small, enigmatic fish that combines features of both trout and perch — hence the hyphenated name. It has an adipose fin like a trout and weak spiny rays like a perch, making it a taxonomic oddity. The body is semi-translucent silvery with rows of dark spots along the back and upper sides. The eyes are large, adapted for its nocturnal lifestyle. Feeds on aquatic insects, crustaceans, and zooplankton, primarily at night.",
            habitat: "Lakes and rivers throughout Saskatchewan, most active at night in shallow water over sandy substrates. During the day, retreats to deeper water. Often overlooked despite being quite common because of its nocturnal habits.",
            funFact: "Trout-perch are one of only two living species in the family Percopsidae — a North American endemic family. They are so secretive and nocturnal that most people never see them, despite being one of the more common fish in Saskatchewan's lakes.",
            isNative: true
        ),
    ]
}
