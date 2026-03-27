import Foundation

// MARK: - PokedexViewModel

/// Drives the main Pokedex grid — loads discoveries, applies filters, and tracks progress.
@Observable
@MainActor
final class PokedexViewModel {

    // MARK: - State

    var allFish: [Fish] = FishDatabase.allFish
    var discoveredFishIds: Set<Int> = []
    var searchText: String = ""
    var selectedCategory: FishCategory? = nil
    var showCaughtOnly: Bool = false
    var showUncaughtOnly: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Computed Properties

    /// Fish list filtered by search text, category, and caught/uncaught toggles.
    var filteredFish: [Fish] {
        var results = allFish

        // Category filter
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }

        // Caught / uncaught toggles (mutually exclusive)
        if showCaughtOnly {
            results = results.filter { discoveredFishIds.contains($0.id) }
        } else if showUncaughtOnly {
            results = results.filter { !discoveredFishIds.contains($0.id) }
        }

        // Search text — matches common name, scientific name, or family
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter { fish in
                fish.commonName.lowercased().contains(query)
                || fish.scientificName.lowercased().contains(query)
                || fish.family.lowercased().contains(query)
                || fish.familyCommonName.lowercased().contains(query)
            }
        }

        return results
    }

    /// Number of unique species the user has discovered.
    var discoveredCount: Int {
        discoveredFishIds.count
    }

    /// Progress toward completing the Pokedex (0.0–1.0).
    var progressPercentage: Double {
        guard !allFish.isEmpty else { return 0 }
        return Double(discoveredCount) / Double(allFish.count)
    }

    /// Human-readable progress string, e.g. "32 of 84 Discovered".
    var progressText: String {
        "\(discoveredCount) of \(allFish.count) Discovered"
    }

    // MARK: - Dependencies

    private let catchService: CatchService

    // MARK: - Init

    init(catchService: CatchService) {
        self.catchService = catchService
    }

    // MARK: - Actions

    /// Loads the set of discovered fish IDs from the catch service.
    func loadDiscoveries() async {
        isLoading = true
        errorMessage = nil

        do {
            let ids = try await catchService.discoveredFishIds()
            discoveredFishIds = ids
        } catch {
            errorMessage = "Failed to load discoveries: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Refreshes discovery data — call on pull-to-refresh or when returning to the list.
    func refresh() async {
        await loadDiscoveries()
    }
}
