import Foundation
import SwiftData

// MARK: - DiscoveryState

/// Tracks whether a fish species has been discovered and how many times it has been caught.
@Model
final class DiscoveryState: @unchecked Sendable {

    // MARK: Properties

    /// The fish ID (1–84) this state belongs to.
    @Attribute(.unique) var fishId: Int

    /// Whether the user has discovered (caught at least once) this fish.
    var isDiscovered: Bool

    /// The date the fish was first discovered.
    var firstDiscoveredDate: Date?

    /// Running total of catches for this species.
    var totalCatches: Int

    // MARK: Init

    init(
        fishId: Int,
        isDiscovered: Bool = false,
        firstDiscoveredDate: Date? = nil,
        totalCatches: Int = 0
    ) {
        self.fishId = fishId
        self.isDiscovered = isDiscovered
        self.firstDiscoveredDate = firstDiscoveredDate
        self.totalCatches = totalCatches
    }
}
