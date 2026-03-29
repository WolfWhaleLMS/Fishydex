import Foundation
import UIKit

// MARK: - FishDetailViewModel

/// Manages the detail screen for a single fish species — discovery state, catch history,
/// and the ability to log new catches.
@Observable
@MainActor
final class FishDetailViewModel {

    // MARK: - State

    let fish: Fish
    var isDiscovered: Bool = false
    var catches: [CatchRecord] = []
    var isLoading: Bool = false
    var showCatchSheet: Bool = false
    var showARView: Bool = false
    var errorMessage: String? = nil

    /// Fields for the "new catch" form.
    var catchNotes: String = ""
    var catchPhoto: Data? = nil

    // MARK: - Dependencies

    private let catchService: CatchService
    private let locationService: LocationService

    // MARK: - Init

    init(fish: Fish, catchService: CatchService, locationService: LocationService) {
        self.fish = fish
        self.catchService = catchService
        self.locationService = locationService
    }

    // MARK: - Data Loading

    /// Loads discovery state and catch history for this fish.
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let discoveredResult = catchService.isDiscovered(fish.id)
            async let catchesResult = catchService.catches(for: fish.id)

            isDiscovered = try await discoveredResult
            catches = try await catchesResult
        } catch {
            errorMessage = "Failed to load fish data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Catch Logging

    /// Logs a new catch for this fish, discovers it if first catch, and triggers haptic feedback.
    func logCatch() async {
        isLoading = true
        errorMessage = nil

        do {
            // Grab current location if available
            let location = try? await locationService.currentLocation()
            let locationName: String? = if let location {
                try? await locationService.locationName(for: location)
            } else {
                nil
            }

            // Compress photo data if present
            let compressedPhoto: Data? = if let catchPhoto {
                compressPhotoData(catchPhoto)
            } else {
                nil
            }

            // Log the catch (auto-discovers on first catch)
            _ = try await catchService.logCatch(
                fishId: fish.id,
                latitude: location?.coordinate.latitude,
                longitude: location?.coordinate.longitude,
                locationName: locationName,
                photoData: compressedPhoto,
                notes: catchNotes.isEmpty ? nil : catchNotes
            )

            // Discover the fish if this is the first catch
            if !isDiscovered {
                isDiscovered = true
                triggerDiscoveryHaptic()
            } else {
                triggerCatchHaptic()
            }

            // Reset form
            catchNotes = ""
            catchPhoto = nil
            showCatchSheet = false

            // Reload catches to include the new one
            catches = try await catchService.catches(for: fish.id)
        } catch {
            errorMessage = "Failed to log catch: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Deletes a catch record and reloads the list.
    func deleteCatch(_ record: CatchRecord) async {
        errorMessage = nil

        do {
            try await catchService.deleteCatch(record)
            catches = try await catchService.catches(for: fish.id)
        } catch {
            errorMessage = "Failed to delete catch: \(error.localizedDescription)"
        }
    }

    // MARK: - Haptics

    /// Heavy impact for a brand-new species discovery.
    private func triggerDiscoveryHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Light impact for a repeat catch.
    private func triggerCatchHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Helpers

    /// Compresses raw photo data to JPEG at 80% quality to save storage.
    private func compressPhotoData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        return image.jpegData(compressionQuality: 0.8)
    }
}
