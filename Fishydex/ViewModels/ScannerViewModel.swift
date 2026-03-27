import Foundation
import UIKit
import CoreLocation

// MARK: - ScannerViewModel

/// Drives the camera scanner flow — capture a photo, auto-identify via iNaturalist, and confirm the catch.
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

    // MARK: - AI Identification State

    /// Current state of the auto-identification process.
    var identificationState: IdentificationUIState = .idle

    /// Top matches from iNaturalist, ranked by confidence.
    var identifiedMatches: [FishIdentificationService.Match] = []

    /// Whether the auto-ID found a confident match (>= 60% confidence).
    var hasConfidentMatch: Bool {
        guard let top = identifiedMatches.first else { return false }
        return top.confidence >= 0.6
    }

    enum IdentificationUIState: Equatable {
        case idle
        case analyzing       // "ANALYZING..." spinner
        case identified      // Got results — show top match + confirm button
        case noMatch         // No fish found — fall back to manual picker
        case failed(String)  // Error — show message + manual fallback

        static func == (lhs: IdentificationUIState, rhs: IdentificationUIState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.analyzing, .analyzing),
                 (.identified, .identified), (.noMatch, .noMatch):
                return true
            case (.failed(let a), .failed(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    private let catchService: CatchService
    private let locationService: LocationService
    private let identificationService: FishIdentificationService

    // MARK: - Init

    init(
        catchService: CatchService,
        locationService: LocationService,
        identificationService: FishIdentificationService
    ) {
        self.catchService = catchService
        self.locationService = locationService
        self.identificationService = identificationService
    }

    // MARK: - Scanning Flow

    /// Begins the scanning session — requests location permission and starts the camera.
    func startScanning() async {
        isScanning = true
        capturedImage = nil
        selectedFishId = nil
        lastCatchWasNewDiscovery = false
        errorMessage = nil
        identificationState = .idle
        identifiedMatches = []

        // Request location in the background; non-blocking if denied.
        do {
            try await locationService.requestPermission()
            currentLocation = try await locationService.currentLocation()
        } catch {
            currentLocation = nil
        }
    }

    /// Called when the camera captures a frame. Triggers auto-identification.
    func capturePhoto(_ image: UIImage) async {
        capturedImage = image
        isScanning = false
        identificationState = .analyzing

        // Run auto-identification
        let result = await identificationService.identify(
            image: image,
            location: currentLocation
        )

        switch result {
        case .identified(let matches):
            identifiedMatches = matches
            identificationState = .identified

            // If top match is very confident (>= 80%), auto-select it
            if let topMatch = matches.first, topMatch.confidence >= 0.8 {
                selectedFishId = topMatch.fish.id
            }

        case .noMatch:
            identifiedMatches = []
            identificationState = .noMatch
            // Fall back to manual picker
            showSpeciesPicker = true

        case .failed(let message):
            identifiedMatches = []
            identificationState = .failed(message)
            // Fall back to manual picker
            showSpeciesPicker = true

        case .idle, .analyzing:
            break
        }
    }

    /// User confirms the auto-identified species or picks manually.
    func confirmIdentification(fishId: Int) async {
        await confirmCatch(fishId: fishId)
    }

    /// User rejects auto-ID and wants to pick manually.
    func rejectIdentification() {
        identificationState = .idle
        showSpeciesPicker = true
    }

    /// Confirms the catch for the selected species.
    @discardableResult
    func confirmCatch(fishId: Int) async -> Bool {
        isProcessing = true
        errorMessage = nil
        lastCatchWasNewDiscovery = false

        do {
            let alreadyDiscovered = try await catchService.isDiscovered(fishId)

            let photoData = capturedImage?.jpegData(compressionQuality: 0.8)
            let locationName: String? = if let loc = currentLocation {
                try? await locationService.locationName(for: loc)
            } else {
                nil
            }

            _ = try await catchService.logCatch(
                fishId: fishId,
                latitude: currentLocation?.coordinate.latitude,
                longitude: currentLocation?.coordinate.longitude,
                locationName: locationName,
                photoData: photoData
            )

            if !alreadyDiscovered {
                lastCatchWasNewDiscovery = true
                triggerDiscoveryHaptic()
            } else {
                triggerCatchHaptic()
            }

            showSpeciesPicker = false
            selectedFishId = fishId
            identificationState = .idle
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
        identificationState = .idle
        identifiedMatches = []
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
        identificationState = .idle
        identifiedMatches = []
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
