import Foundation

// MARK: - Family 1: Petromyzontidae (Lampreys) — 1 species

extension Fish {
    static let petromyzontidae: [Fish] = [
        Fish(
            id: 1,
            commonName: "Chestnut Lamprey",
            scientificName: "Ichthyomyzon castaneus",
            family: "Petromyzontidae",
            familyCommonName: "Lampreys",
            category: .forageFish,
            rarityTier: .epic,
            conservationStatus: "SU (unrankable)",
            cosewicStatus: "Data Deficient",
            sizeRange: "Up to 36 cm",
            maxWeight: nil,
            description: "An eel-like, jawless parasitic fish — one of the most primitive vertebrates on Earth. The chestnut lamprey attaches to host fish with its circular, tooth-lined sucker mouth and feeds on blood and body fluids. Adults are chestnut-brown to olive and lack paired fins, jaws, and true bones. Larvae (ammocoetes) are blind, filter-feeding burrowers that live in stream sediments for several years before metamorphosing into parasitic adults.",
            habitat: "Saskatchewan-Nelson River drainage. Found in clear streams and rivers with sandy or silty substrates during larval stage; adults parasitize fish in larger rivers and lakes.",
            funFact: "The chestnut lamprey is the only non-bony fish species found in Saskatchewan — it belongs to an ancient lineage that predates the dinosaurs by over 200 million years.",
            isNative: true
        ),
    ]
}
