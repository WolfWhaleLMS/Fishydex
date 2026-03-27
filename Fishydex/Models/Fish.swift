import Foundation

/// Static reference data model for a single Saskatchewan fish species.
/// This is NOT a SwiftData model — fish data is compiled into the app.
struct Fish: Identifiable, Hashable, Codable {
    let id: Int                     // 1-84 (Pokedex number)
    let commonName: String
    let scientificName: String
    let family: String              // Family scientific name
    let familyCommonName: String
    let category: FishCategory
    let rarityTier: RarityTier
    let conservationStatus: String?
    let cosewicStatus: String?
    let sizeRange: String
    let maxWeight: String?
    let description: String
    let habitat: String
    let funFact: String?
    let isNative: Bool

    /// Asset catalog image name derived from the Pokedex number.
    var imageName: String {
        "fish_\(String(format: "%03d", id))"
    }

    /// Display-formatted Pokedex number (e.g. "#034").
    var formattedId: String {
        String(format: "#%03d", id)
    }

    /// Silhouette asset name for undiscovered state.
    var silhouetteImageName: String {
        "fish_\(String(format: "%03d", id))_silhouette"
    }

    // MARK: - Hashable

    static func == (lhs: Fish, rhs: Fish) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
