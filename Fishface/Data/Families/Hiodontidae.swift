import Foundation

// MARK: - Family 9: Hiodontidae (Mooneyes) — 2 species

extension Fish {
    static let hiodontidae: [Fish] = [
        Fish(
            id: 15,
            commonName: "Goldeye",
            scientificName: "Hiodon alosoides",
            family: "Hiodontidae",
            familyCommonName: "Mooneyes",
            category: .sportFish,
            rarityTier: .uncommon,
            conservationStatus: "S4 (apparently secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 40 cm",
            maxWeight: nil,
            description: "A handsome, herring-like fish with a deep, laterally compressed body and large, brilliant golden-yellow eyes adapted for feeding in turbid water and low-light conditions. The back is dark blue-grey and the sides are bright silver with a golden sheen. The mouth is large and terminal with small but sharp teeth. A surface and mid-water feeder that takes insects, small fish, and crustaceans, often leaping out of the water to catch flying insects.",
            habitat: "Large turbid rivers and connected lakes in the Saskatchewan River system. Prefers slow to moderate current in the main channels and backwaters of major prairie rivers.",
            funFact: "Winnipeg smoked goldeye is considered one of Canada's great culinary delicacies. The technique was developed in the 1880s and remains a sought-after specialty of Manitoba and Saskatchewan. The fish turns a rich golden colour when hot-smoked.",
            isNative: true
        ),
        Fish(
            id: 16,
            commonName: "Mooneye",
            scientificName: "Hiodon tergisus",
            family: "Hiodontidae",
            familyCommonName: "Mooneyes",
            category: .sportFish,
            rarityTier: .rare,
            conservationStatus: "S3 (vulnerable)",
            cosewicStatus: nil,
            sizeRange: "Up to 35 cm",
            maxWeight: nil,
            description: "The goldeye's less common relative, distinguished by its silver-white (rather than golden) eyes and a keel along the belly that extends forward only to the pelvic fin base (in goldeye, the keel extends to the pectoral fins). The body is similar in shape — deep, compressed, and silvery — but the mooneye generally prefers clearer water. Feeds on insects, small crustaceans, and small fish.",
            habitat: "Large, clear to moderately clear rivers in the Saskatchewan River system. Prefers cleaner, less turbid water than the goldeye, with moderate current over gravel or rocky substrates.",
            funFact: "Mooneye and goldeye are the only two members of the family Hiodontidae, which is found exclusively in North America. The mooneye's silvery eyes have a reflective layer (tapetum lucidum) that gives them exceptional low-light vision.",
            isNative: true
        ),
    ]
}
