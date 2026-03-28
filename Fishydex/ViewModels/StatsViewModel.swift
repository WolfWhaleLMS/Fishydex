import Foundation

// MARK: - StatsViewModel

/// Aggregates discovery and catch statistics, breakdowns by category/family/rarity,
/// and tracks achievement progress.
@Observable
@MainActor
final class StatsViewModel {

    // MARK: - State

    var totalDiscovered: Int = 0
    var totalCatches: Int = 0
    var discoveredByCategory: [FishCategory: (discovered: Int, total: Int)] = [:]
    var discoveredByFamily: [(family: String, discovered: Int, total: Int)] = []
    var discoveredByRarity: [RarityTier: (discovered: Int, total: Int)] = [:]
    var recentCatches: [CatchRecord] = []
    var achievements: [Achievement] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Achievement Model

    struct Achievement: Identifiable {
        let id: String
        let name: String
        let description: String
        let iconName: String
        var isUnlocked: Bool
    }

    // MARK: - Dependencies

    private let catchService: CatchService

    // MARK: - Init

    init(catchService: CatchService) {
        self.catchService = catchService
    }

    // MARK: - Data Loading

    /// Loads all stats from the catch service and computes breakdowns.
    func loadStats() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch raw data concurrently
            async let discoveredIdsResult = catchService.discoveredFishIds()
            async let allCatchesResult = catchService.allCatches()
            async let discoveredCountResult = catchService.discoveredCount()

            let discoveredIds = try await discoveredIdsResult
            let allCatches = try await allCatchesResult
            let discoveredCount = try await discoveredCountResult

            let allFish = FishDatabase.allFish

            // Top-level counts
            totalDiscovered = discoveredCount
            totalCatches = allCatches.count

            // Breakdown by category
            computeCategoryBreakdown(allFish: allFish, discoveredIds: discoveredIds)

            // Breakdown by family
            computeFamilyBreakdown(allFish: allFish, discoveredIds: discoveredIds)

            // Breakdown by rarity
            computeRarityBreakdown(allFish: allFish, discoveredIds: discoveredIds)

            // Recent catches (newest first, capped at 10)
            recentCatches = allCatches
                .sorted { $0.caughtDate > $1.caughtDate }
                .prefix(10)
                .map { $0 }

            // Compute achievements
            computeAchievements(
                discoveredIds: discoveredIds,
                allCatches: allCatches,
                allFish: allFish
            )
        } catch {
            errorMessage = "Failed to load stats: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Breakdowns

    /// Groups discovery counts by FishCategory.
    private func computeCategoryBreakdown(allFish: [Fish], discoveredIds: Set<Int>) {
        var map: [FishCategory: (discovered: Int, total: Int)] = [:]

        for category in FishCategory.allCases {
            let fishInCategory = allFish.filter { $0.category == category }
            let discoveredInCategory = fishInCategory.filter { discoveredIds.contains($0.id) }
            map[category] = (discovered: discoveredInCategory.count, total: fishInCategory.count)
        }

        discoveredByCategory = map
    }

    /// Groups discovery counts by family name, sorted alphabetically.
    private func computeFamilyBreakdown(allFish: [Fish], discoveredIds: Set<Int>) {
        let grouped = Dictionary(grouping: allFish) { $0.familyCommonName }

        discoveredByFamily = grouped.map { (family, fish) in
            let discovered = fish.filter { discoveredIds.contains($0.id) }.count
            return (family: family, discovered: discovered, total: fish.count)
        }
        .sorted { $0.family < $1.family }
    }

    /// Groups discovery counts by RarityTier.
    private func computeRarityBreakdown(allFish: [Fish], discoveredIds: Set<Int>) {
        var map: [RarityTier: (discovered: Int, total: Int)] = [:]

        for tier in RarityTier.allCases {
            let fishInTier = allFish.filter { $0.rarityTier == tier }
            let discoveredInTier = fishInTier.filter { discoveredIds.contains($0.id) }
            map[tier] = (discovered: discoveredInTier.count, total: fishInTier.count)
        }

        discoveredByRarity = map
    }

    // MARK: - Achievements

    /// The full roster of achievements. Unlocked status is computed at runtime.
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_catch",
            name: "First Catch",
            description: "Log your very first catch.",
            iconName: "fish.fill",
            isUnlocked: false
        ),
        Achievement(
            id: "pike_master",
            name: "Pike Master",
            description: "Catch every species in the Pike family (Esocidae).",
            iconName: "bolt.fill",
            isUnlocked: false
        ),
        Achievement(
            id: "deep_diver",
            name: "Deep Diver",
            description: "Discover 5 species from the Sturgeon or Sculpin families.",
            iconName: "arrow.down.to.line",
            isUnlocked: false
        ),
        Achievement(
            id: "living_fossil",
            name: "Living Fossil",
            description: "Discover the Lake Sturgeon — a species older than dinosaurs.",
            iconName: "fossil.shell.fill",
            isUnlocked: false
        ),
        Achievement(
            id: "invasive_hunter",
            name: "Invasive Hunter",
            description: "Discover every invasive species in the Fishface.",
            iconName: "exclamationmark.triangle.fill",
            isUnlocked: false
        ),
        Achievement(
            id: "saskatchewan_angler",
            name: "Saskatchewan Angler",
            description: "Discover 50% of all species in the Fishface.",
            iconName: "star.fill",
            isUnlocked: false
        ),
        Achievement(
            id: "pokedex_complete",
            name: "Pokedex Complete",
            description: "Discover every single species. You are a true Fishface Master.",
            iconName: "crown.fill",
            isUnlocked: false
        ),
    ]

    /// Evaluates each achievement against the current data.
    private func computeAchievements(
        discoveredIds: Set<Int>,
        allCatches: [CatchRecord],
        allFish: [Fish]
    ) {
        var results = Self.allAchievements

        for index in results.indices {
            results[index].isUnlocked = isAchievementUnlocked(
                id: results[index].id,
                discoveredIds: discoveredIds,
                allCatches: allCatches,
                allFish: allFish
            )
        }

        achievements = results
    }

    /// Determines whether a specific achievement is unlocked.
    private func isAchievementUnlocked(
        id: String,
        discoveredIds: Set<Int>,
        allCatches: [CatchRecord],
        allFish: [Fish]
    ) -> Bool {
        switch id {

        // First Catch — at least one catch exists
        case "first_catch":
            return !allCatches.isEmpty

        // Pike Master — all Esocidae discovered
        case "pike_master":
            let pikeIds = Set(allFish.filter { $0.family == "Esocidae" }.map(\.id))
            return !pikeIds.isEmpty && pikeIds.isSubset(of: discoveredIds)

        // Deep Diver — 5+ species from Acipenseridae or Cottidae
        case "deep_diver":
            let deepFamilies: Set<String> = ["Acipenseridae", "Cottidae"]
            let deepIds = allFish.filter { deepFamilies.contains($0.family) }.map(\.id)
            let discovered = deepIds.filter { discoveredIds.contains($0) }
            return discovered.count >= 5

        // Living Fossil — Lake Sturgeon discovered (fish #1 by convention, or find by name)
        case "living_fossil":
            let sturgeonIds = allFish
                .filter { $0.commonName.lowercased().contains("lake sturgeon") }
                .map(\.id)
            return sturgeonIds.contains { discoveredIds.contains($0) }

        // Invasive Hunter — all invasive species discovered
        case "invasive_hunter":
            let invasiveIds = Set(allFish.filter { $0.category == .invasive }.map(\.id))
            return !invasiveIds.isEmpty && invasiveIds.isSubset(of: discoveredIds)

        // Saskatchewan Angler — 50%+ discovered
        case "saskatchewan_angler":
            guard !allFish.isEmpty else { return false }
            return Double(discoveredIds.count) / Double(allFish.count) >= 0.5

        // Pokedex Complete — 100% discovered
        case "pokedex_complete":
            return discoveredIds.count >= allFish.count

        default:
            return false
        }
    }
}
