import Foundation

// MARK: - Family 16: Ictaluridae (Catfishes) — 5 species

extension Fish {
    static let ictaluridae: [Fish] = [
        Fish(
            id: 77,
            commonName: "Black Bullhead",
            scientificName: "Ameiurus melas",
            family: "Ictaluridae",
            familyCommonName: "Catfishes",
            category: .coarseFish,
            rarityTier: .uncommon,
            conservationStatus: "S3 (vulnerable)",
            cosewicStatus: nil,
            sizeRange: "Up to 35 cm",
            maxWeight: nil,
            description: "A stout, scaleless catfish with a broad, flat head and eight dark-coloured barbels (\"whiskers\") around the mouth. The body is uniformly dark olive-brown to black with a pale belly. Distinguished from the brown bullhead by its dark (rather than pale) chin barbels and lack of mottling. Has a sharp, venomous spine at the leading edge of each pectoral fin and the dorsal fin. Feeds on a wide variety of items including insects, snails, fish, and plant material — a true omnivore.",
            habitat: "Muddy-bottomed lakes, ponds, and slow-moving streams in southern Saskatchewan. Tolerant of poor water quality including low oxygen, high turbidity, and warm temperatures. Often found in shallow, weedy prairie water bodies.",
            funFact: "Black bullheads are among the hardiest fish in Saskatchewan — they can survive in warm, oxygen-poor, muddy water that would kill most other species. Handle with care though, as their pectoral and dorsal spines can deliver a painful sting.",
            isNative: true
        ),
        Fish(
            id: 78,
            commonName: "Brown Bullhead",
            scientificName: "Ameiurus nebulosus",
            family: "Ictaluridae",
            familyCommonName: "Catfishes",
            category: .coarseFish,
            rarityTier: .uncommon,
            conservationStatus: "S3 (vulnerable)",
            cosewicStatus: nil,
            sizeRange: "Up to 35 cm",
            maxWeight: nil,
            description: "A moderate-sized catfish similar to the black bullhead but with distinctively pale or yellowish chin barbels and a mottled brown body pattern. The body is olive-brown to yellowish-brown with dark mottling above and a cream to yellowish belly. Like all bullheads, it is scaleless with venomous pectoral and dorsal fin spines. An omnivorous bottom feeder that is most active at night, using its sensitive barbels to locate food by taste and touch.",
            habitat: "Warm, weedy lakes and slow-moving streams in the southern portions of Saskatchewan. Prefers slightly clearer water than the black bullhead, with submerged vegetation and soft bottoms.",
            funFact: "Brown bullheads are devoted parents — both male and female guard the eggs and young fry. The parents herd their school of jet-black babies around like aquatic shepherds, protecting them from predators for several weeks.",
            isNative: true
        ),
        Fish(
            id: 79,
            commonName: "Channel Catfish",
            scientificName: "Ictalurus punctatus",
            family: "Ictaluridae",
            familyCommonName: "Catfishes",
            category: .sportFish,
            rarityTier: .rare,
            conservationStatus: "S2 (imperiled)",
            cosewicStatus: nil,
            sizeRange: "Up to 70 cm",
            maxWeight: nil,
            description: "The largest catfish species in Saskatchewan and the only one classified as a sport fish. The channel catfish has a slender, streamlined body with a deeply forked tail — distinguishing it from the square-tailed bullheads. The body is blue-grey to olive with scattered dark spots (especially in younger fish), eight barbels around the mouth, and a pale belly. Feeds on fish, crayfish, insects, and molluscs. A powerful fighter when hooked.",
            habitat: "Large, warm rivers in the Saskatchewan River system, particularly the South Saskatchewan River and its tributaries. Prefers deep pools with moderate current and sand, gravel, or clay substrates. Range appears to be expanding northward.",
            funFact: "Channel catfish are the only catfish species in Saskatchewan classified as a sport fish. They are expanding their range in the Saskatchewan River system, possibly aided by warming water temperatures, and can grow to impressive sizes.",
            isNative: true
        ),
        Fish(
            id: 80,
            commonName: "Stonecat",
            scientificName: "Noturus flavus",
            family: "Ictaluridae",
            familyCommonName: "Catfishes",
            category: .forageFish,
            rarityTier: .legendary,
            conservationStatus: "S2 (imperiled)",
            cosewicStatus: nil,
            sizeRange: "Up to 20 cm",
            maxWeight: nil,
            description: "A small, secretive catfish with a distinctive adipose fin that is continuous with (connected to) the caudal fin — a feature that separates it from all other Saskatchewan catfishes. The body is uniformly olive-yellow to brown with a rounded head and eight barbels. Like its larger relatives, the stonecat has venomous spines in its pectoral and dorsal fins that can deliver a painful sting. Nocturnal and secretive, hiding under rocks during the day.",
            habitat: "Fast-flowing rocky riffles and runs of large rivers in the Saskatchewan River system. Hides under flat rocks and cobble during the day and emerges at night to feed on aquatic insect larvae and crayfish. One of the rarest and least-seen fish in Saskatchewan.",
            funFact: "The stonecat is one of Saskatchewan's rarest fish. It hides under rocks in fast rivers during the day and emerges only at night. Its pectoral spines are venomous — delivering a wasp-like sting if carelessly handled.",
            isNative: true
        ),
        Fish(
            id: 81,
            commonName: "Tadpole Madtom",
            scientificName: "Noturus gyrinus",
            family: "Ictaluridae",
            familyCommonName: "Catfishes",
            category: .forageFish,
            rarityTier: .rare,
            conservationStatus: "S3 (vulnerable)",
            cosewicStatus: nil,
            sizeRange: "Up to 10 cm",
            maxWeight: nil,
            description: "A tiny, plump catfish with a tadpole-like body shape — a rounded head tapering to a narrow, elongated tail. The adipose fin is long and low, connected to (or nearly touching) the rounded caudal fin. The body is uniformly dark olive-brown to yellowish-brown with a pale belly. Has eight barbels and venomous pectoral spines like other catfishes. Strictly nocturnal, hiding in vegetation and debris during the day.",
            habitat: "Slow-moving streams, backwaters, and vegetated lake margins with soft, muddy substrates and abundant organic debris. Secretive and nocturnal. Found in select locations across the southern portion of Saskatchewan.",
            funFact: "At under 10 cm, the tadpole madtom is Saskatchewan's smallest catfish. Its rounded, tadpole-like body and secretive nocturnal habits mean most people in Saskatchewan have never seen one — or even heard of it.",
            isNative: true
        ),
    ]
}
