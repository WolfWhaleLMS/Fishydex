import Foundation

// MARK: - Family 7: Gadidae (Cods) — 1 species

extension Fish {
    static let gadidae: [Fish] = [
        Fish(
            id: 36,
            commonName: "Burbot",
            scientificName: "Lota lota",
            family: "Gadidae",
            familyCommonName: "Cods",
            category: .sportFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "Up to 70 cm",
            maxWeight: nil,
            description: "The only freshwater member of the cod family in North America. The burbot has an elongated, eel-like body with a single barbel on the chin, two dorsal fins (one short, one very long), and a rounded caudal fin. Colouration is dark mottled olive to yellow-brown with a marbled pattern. Known locally as \"dogfish,\" \"maria,\" \"mariah,\" or \"ling.\" A voracious nocturnal predator that feeds on fish, crayfish, and aquatic insects.",
            habitat: "Deep, cold lakes and rivers throughout Saskatchewan. A cold-water species most common in the northern half of the province. Bottom dweller that is most active at night and during winter. The only freshwater fish in Saskatchewan that spawns under the ice, typically in January or February.",
            funFact: "Burbot are the only freshwater fish in Saskatchewan that spawn in the dead of winter, gathering in writhing spawning balls under the ice in January and February. Their liver is considered a delicacy — Saskatchewan's answer to cod liver.",
            isNative: true
        ),
    ]
}
