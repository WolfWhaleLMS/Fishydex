import Foundation
import SwiftData

// MARK: - CatchRecord

/// A single catch logged by the user, stored via SwiftData.
@Model
final class CatchRecord: @unchecked Sendable {

    // MARK: Properties

    var id: UUID
    var fishId: Int
    var caughtDate: Date
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var photoData: Data?
    var notes: String?

    // MARK: Init

    init(
        id: UUID = UUID(),
        fishId: Int,
        caughtDate: Date = .now,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil,
        photoData: Data? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.fishId = fishId
        self.caughtDate = caughtDate
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.photoData = photoData
        self.notes = notes
    }
}
