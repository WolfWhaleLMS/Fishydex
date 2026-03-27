import Foundation

// MARK: - Family 5: Esocidae (Pikes) — 1 species

extension Fish {
    static let esocidae: [Fish] = [
        Fish(
            id: 34,
            commonName: "Northern Pike",
            scientificName: "Esox lucius",
            family: "Esocidae",
            familyCommonName: "Pikes",
            category: .sportFish,
            rarityTier: .common,
            conservationStatus: "S5 (secure)",
            cosewicStatus: nil,
            sizeRange: "50–120 cm",
            maxWeight: "19+ kg",
            description: "Saskatchewan's most iconic and widely distributed sport fish, known locally as \"jackfish.\" The northern pike is a powerful ambush predator with an elongated, torpedo-shaped body, a broad flat snout resembling a duck's bill, and a mouth full of hundreds of razor-sharp teeth. Colouration is dark green to olive with rows of lighter bean-shaped spots along the sides. The dorsal and anal fins are set far back near the tail for explosive acceleration. Feeds on fish, frogs, crayfish, small mammals, and waterfowl.",
            habitat: "Found in virtually every lake and river system across Saskatchewan, from the southern prairies to the far north. Prefers weedy bays, river backwaters, and lake margins with abundant vegetation for ambush hunting. The most widely distributed sport fish in the province.",
            funFact: "The Saskatchewan record northern pike weighed 19.4 kg (42.75 lbs) and was caught in Lake Athabasca in 1954. Pike can strike at speeds of up to 50 km/h and are known to eat prey up to half their own body length.",
            isNative: true
        ),
    ]
}
