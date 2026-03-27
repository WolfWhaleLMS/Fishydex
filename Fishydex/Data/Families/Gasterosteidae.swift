import Foundation

// MARK: - Family 8: Gasterosteidae (Sticklebacks) — 2 species

extension Fish {
    static let gasterosteidae: [Fish] = [
        Fish(
            id: 37,
            commonName: "Brook Stickleback",
            scientificName: "Culaea inconstans",
            family: "Gasterosteidae",
            familyCommonName: "Sticklebacks",
            category: .forageFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 7 cm",
            maxWeight: nil,
            description: "A tiny but feisty fish armed with 4 to 6 sharp dorsal spines that it erects when threatened. The body is laterally compressed with olive-green colouration and mottled dark markings. Lacks scales, instead having bony plates along the sides. Breeding males turn jet black and develop bright blue-green eyes. Feeds on small invertebrates, fish eggs, and algae.",
            habitat: "Province-wide distribution in a variety of habitats including ponds, streams, marshes, beaver ponds, and lake margins with dense aquatic vegetation. One of the most widespread small fish in Saskatchewan.",
            funFact: "Male brook sticklebacks build elaborate nests from plant material glued together with a sticky secretion from their kidneys. They guard the nest and fan the eggs with their fins to keep them oxygenated — some of the most devoted fish fathers in Saskatchewan.",
            isNative: true
        ),
        Fish(
            id: 38,
            commonName: "Ninespine Stickleback",
            scientificName: "Pungitius pungitius",
            family: "Gasterosteidae",
            familyCommonName: "Sticklebacks",
            category: .forageFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 7 cm",
            maxWeight: nil,
            description: "A tiny, slender stickleback with 7 to 12 short dorsal spines (despite the name suggesting nine). The body is very elongate and compressed, olive to brownish with a silvery belly. Like its relative the brook stickleback, it lacks true scales and has bony lateral plates. The caudal peduncle is extremely narrow, giving the tail a paddle-like appearance. Feeds on tiny crustaceans and aquatic insect larvae.",
            habitat: "Northern and boreal regions of Saskatchewan. Inhabits cold, weedy lakes, ponds, and slow-moving streams, often in shallow vegetated margins. Generally more northern in distribution than the brook stickleback.",
            funFact: "Despite its name, the ninespine stickleback can have anywhere from 7 to 12 dorsal spines. Males build their nests above the bottom, suspended among aquatic vegetation — an unusual strategy among freshwater fish.",
            isNative: true
        ),
    ]
}
