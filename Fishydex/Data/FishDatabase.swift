import Foundation

// MARK: - FishDatabase

/// Central static database assembling all 84 Saskatchewan fish species from 17 family files.
/// All data is compiled into the app — no network required.
enum FishDatabase {

    // MARK: - All Fish (sorted by Pokedex ID)

    /// Complete array of all 84 Saskatchewan fish species, sorted by ID (#001–#084).
    static let allFish: [Fish] = {
        let families: [[Fish]] = [
            Fish.petromyzontidae,     // Family 1:  Lampreys (1)
            Fish.acipenseridae,       // Family 2:  Sturgeons (1)
            Fish.catostomidae,        // Family 3:  Suckers (7)
            Fish.cyprinidae,          // Family 4:  Minnows & Carps (24)
            Fish.esocidae,            // Family 5:  Pikes (1)
            Fish.umbridae,            // Family 6:  Mudminnows (1)
            Fish.gadidae,             // Family 7:  Cods (1)
            Fish.gasterosteidae,      // Family 8:  Sticklebacks (2)
            Fish.hiodontidae,         // Family 9:  Mooneyes (2)
            Fish.osmeridae,           // Family 10: Smelts (1)
            Fish.centrarchidae,       // Family 11: Sunfishes & Basses (6)
            Fish.percidae,            // Family 12: Perches & Darters (8)
            Fish.percopsidae,         // Family 13: Trout-perches (1)
            Fish.salmonidae,          // Family 14: Salmon, Trout & Whitefish (17)
            Fish.cottidae,            // Family 15: Sculpins (3)
            Fish.ictaluridae,         // Family 16: Catfishes (5)
            Fish.sciaenidae,          // Family 17: Drums (1)
            Fish.additionalExotics,   // Additional exotics: Grass Carp, American Eel (2)
        ]
        return families.flatMap { $0 }.sorted { $0.id < $1.id }
    }()

    /// Total number of fish species in the database.
    static let totalCount: Int = allFish.count

    // MARK: - Lookups

    /// Look up a fish by its Pokedex ID (1–84). Returns nil if ID is out of range.
    static func fish(byId id: Int) -> Fish? {
        allFish.first { $0.id == id }
    }

    /// All fish in a given category.
    static func fish(inCategory category: FishCategory) -> [Fish] {
        allFish.filter { $0.category == category }
    }

    /// All fish in a given rarity tier.
    static func fish(withRarity rarity: RarityTier) -> [Fish] {
        allFish.filter { $0.rarityTier == rarity }
    }

    /// All fish in a given family (by scientific name).
    static func fish(inFamily familyName: String) -> [Fish] {
        allFish.filter { $0.family == familyName }
    }

    /// All native fish species.
    static var nativeFish: [Fish] {
        allFish.filter { $0.isNative }
    }

    /// All non-native (exotic/invasive/hybrid) fish species.
    static var nonNativeFish: [Fish] {
        allFish.filter { !$0.isNative }
    }

    /// All fish with a COSEWIC status (species at risk).
    static var speciesAtRisk: [Fish] {
        allFish.filter { $0.cosewicStatus != nil }
    }

    // MARK: - Search

    /// Search fish by common name, scientific name, or family name (case-insensitive).
    static func search(query: String) -> [Fish] {
        guard !query.isEmpty else { return allFish }
        let lowered = query.lowercased()
        return allFish.filter { fish in
            fish.commonName.lowercased().contains(lowered)
            || fish.scientificName.lowercased().contains(lowered)
            || fish.family.lowercased().contains(lowered)
            || fish.familyCommonName.lowercased().contains(lowered)
        }
    }

    // MARK: - Statistics

    /// Count of fish per category.
    static var countsByCategory: [FishCategory: Int] {
        Dictionary(grouping: allFish, by: \.category).mapValues(\.count)
    }

    /// Count of fish per rarity tier.
    static var countsByRarity: [RarityTier: Int] {
        Dictionary(grouping: allFish, by: \.rarityTier).mapValues(\.count)
    }

    /// Count of fish per family (scientific name).
    static var countsByFamily: [String: Int] {
        Dictionary(grouping: allFish, by: \.family).mapValues(\.count)
    }

    /// Unique family names, sorted by the lowest fish ID in each family.
    static var familyNames: [String] {
        let grouped = Dictionary(grouping: allFish, by: \.family)
        return grouped
            .sorted { ($0.value.first?.id ?? 0) < ($1.value.first?.id ?? 0) }
            .map(\.key)
    }
}
