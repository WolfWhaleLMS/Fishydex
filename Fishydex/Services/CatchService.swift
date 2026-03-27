import Foundation
import SwiftData

// MARK: - CatchService

/// Actor-based service for managing catch records and discovery state via SwiftData.
///
/// Uses `@ModelActor` for automatic SwiftData actor isolation — each method runs
/// on the actor's serial executor with its own `ModelContext`.
@ModelActor
actor CatchService {

    // MARK: - Catch CRUD

    /// Log a new catch and automatically mark the fish as discovered.
    @discardableResult
    func logCatch(
        fishId: Int,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil,
        photoData: Data? = nil,
        notes: String? = nil
    ) throws -> CatchRecord {
        let record = CatchRecord(
            fishId: fishId,
            caughtDate: .now,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            photoData: photoData,
            notes: notes
        )
        modelContext.insert(record)

        // Auto-discover the fish on first catch
        try markDiscovered(fishId)

        try modelContext.save()
        return record
    }

    /// Fetch all catches for a specific fish, sorted newest-first.
    func catches(for fishId: Int) throws -> [CatchRecord] {
        let descriptor = FetchDescriptor<CatchRecord>(
            predicate: #Predicate { $0.fishId == fishId },
            sortBy: [SortDescriptor(\.caughtDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all catches across all species, sorted newest-first.
    func allCatches() throws -> [CatchRecord] {
        let descriptor = FetchDescriptor<CatchRecord>(
            sortBy: [SortDescriptor(\.caughtDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Delete a single catch record. Decrements the discovery total but does not un-discover.
    func deleteCatch(_ record: CatchRecord) throws {
        let fishId = record.fishId

        modelContext.delete(record)

        // Decrement the discovery catch count
        if let discovery = try fetchDiscovery(for: fishId) {
            discovery.totalCatches = max(0, discovery.totalCatches - 1)
        }

        try modelContext.save()
    }

    // MARK: - Discovery State

    /// Mark a fish as discovered. If already discovered, increments the catch count.
    func discoverFish(_ fishId: Int) throws {
        try markDiscovered(fishId)
        try modelContext.save()
    }

    /// Check whether a fish has been discovered.
    func isDiscovered(_ fishId: Int) throws -> Bool {
        guard let state = try fetchDiscovery(for: fishId) else {
            return false
        }
        return state.isDiscovered
    }

    /// Fetch all discovery states.
    func allDiscoveries() throws -> [DiscoveryState] {
        let descriptor = FetchDescriptor<DiscoveryState>(
            sortBy: [SortDescriptor(\.fishId)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Count of all discovered fish.
    func discoveredCount() throws -> Int {
        let descriptor = FetchDescriptor<DiscoveryState>(
            predicate: #Predicate { $0.isDiscovered == true }
        )
        return try modelContext.fetchCount(descriptor)
    }

    /// Set of all discovered fish IDs — useful for grid state.
    func discoveredFishIds() throws -> Set<Int> {
        let discoveries = try allDiscoveries().filter(\.isDiscovered)
        return Set(discoveries.map(\.fishId))
    }

    // MARK: - Private Helpers

    /// Fetch the `DiscoveryState` for a given fish ID, if it exists.
    private func fetchDiscovery(for fishId: Int) throws -> DiscoveryState? {
        let descriptor = FetchDescriptor<DiscoveryState>(
            predicate: #Predicate { $0.fishId == fishId }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Internal helper that creates or updates the discovery state.
    private func markDiscovered(_ fishId: Int) throws {
        if let existing = try fetchDiscovery(for: fishId) {
            // Already tracked — bump count
            existing.totalCatches += 1
            if !existing.isDiscovered {
                existing.isDiscovered = true
                existing.firstDiscoveredDate = .now
            }
        } else {
            // First time seeing this fish — create state
            let state = DiscoveryState(
                fishId: fishId,
                isDiscovered: true,
                firstDiscoveredDate: .now,
                totalCatches: 1
            )
            modelContext.insert(state)
        }
    }
}
