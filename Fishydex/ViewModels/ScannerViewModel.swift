import Foundation
import UIKit
import CoreLocation

// MARK: - ScannerViewModel

/// Drives the camera scanner flow — capture a photo, pick the species, and confirm the catch.
@Observable
@MainActor
final class ScannerViewModel {

    // MARK: - State

    var isScanning: Bool = false
    var capturedImage: UIImage? = nil
    var showSpeciesPicker: Bool = false
    var selectedFishId: Int? = nil
    var currentLocation: CLLocation? = nil
    var scanAnimationPhase: Double = 0
    var isProcessing: Bool = false
    var errorMessage: String? = nil

    /// Set after a successful catch to let the view present a discovery animation.
    var lastCatchWasNewDiscovery: Bool = false

    // MARK: - Dependencies

    private let catchService: CatchService
    private let locationService: LocationService

    // MARK: - Init

    init(catchService: CatchService, locationService: LocationService) {
        self.catchService = catchService
        self.locationService = locationService
    }

    // MARK: - Scanning Flow

    /// Begins the scanning session — requests location permission and starts the camera.
    func startScanning() async {
        isScanning = true
        capturedImage = nil
        selectedFishId = nil
        lastCatchWasNewDiscovery = false
        errorMessage = nil

        // Request location in the background; non-blocking if denied.
        do {
            try await locationService.requestPermission()
            currentLocation = try await locationService.currentLocation()
        } catch {
            // Location is optional — continue without it.
            currentLocation = nil
        }
    }

    /// Called when the camera captures a frame.
    func capturePhoto(_ image: UIImage) async {
        capturedImage = image
        isScanning = false
        showSpeciesPicker = true
    }

    /// Confirms the catch for the selected species.
    /// - Parameter fishId: The Pokedex ID chosen by the user.
    /// - Returns: `true` if this was a brand-new discovery, `false` for a repeat catch.
    @discardableResult
    func confirmCatch(fishId: Int) async -> Bool {
        isProcessing = true
        errorMessage = nil
        lastCatchWasNewDiscovery = false

        do {
            // Check if this is a new discovery
            let alreadyDiscovered = try await catchService.isDiscovered(fishId)

            // Compress the captured image
            let photoData = capturedImage?.jpegData(compressionQuality: 0.8)
            let locationName: String? = if let loc = currentLocation {
                try? await locationService.locationName(for: loc)
            } else {
                nil
            }

            // Log the catch (auto-discovers on first catch)
            _ = try await catchService.logCatch(
                fishId: fishId,
                latitude: currentLocation?.coordinate.latitude,
                longitude: currentLocation?.coordinate.longitude,
                locationName: locationName,
                photoData: photoData
            )

            // Check if this was a new discovery
            if !alreadyDiscovered {
                lastCatchWasNewDiscovery = true
                triggerDiscoveryHaptic()
            } else {
                triggerCatchHaptic()
            }

            // Clean up state
            showSpeciesPicker = false
            selectedFishId = fishId
            isProcessing = false

            return lastCatchWasNewDiscovery
        } catch {
            errorMessage = "Failed to confirm catch: \(error.localizedDescription)"
            isProcessing = false
            return false
        }
    }

    /// Cancels the current capture and returns to the scanning state.
    func cancelCapture() {
        capturedImage = nil
        selectedFishId = nil
        showSpeciesPicker = false
        lastCatchWasNewDiscovery = false
        isScanning = true
    }

    /// Resets all state to prepare for a fresh scanning session.
    func reset() {
        isScanning = false
        capturedImage = nil
        showSpeciesPicker = false
        selectedFishId = nil
        currentLocation = nil
        scanAnimationPhase = 0
        isProcessing = false
        errorMessage = nil
        lastCatchWasNewDiscovery = false
    }

    // MARK: - Haptics

    private func triggerDiscoveryHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func triggerCatchHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
