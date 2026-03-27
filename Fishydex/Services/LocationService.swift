import CoreLocation
import Foundation

// MARK: - LocationService

/// Actor-based service for GPS location and reverse geocoding.
///
/// Uses `CLLocationManager` with an async/await continuation pattern
/// so callers never deal with delegate callbacks directly.
actor LocationService {

    // MARK: - Private State

    private let manager = CLLocationManager()
    private let delegate = LocationDelegate()

    // MARK: - Init

    init() {
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Public API

    /// Request location permission from the user. Safe to call multiple times.
    func requestPermission() async {
        let status = manager.authorizationStatus

        guard status == .notDetermined else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            delegate.authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    /// Get the device's current location. Throws if permission is denied or location fails.
    func currentLocation() async throws -> CLLocation {
        let status = manager.authorizationStatus

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            delegate.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    /// Reverse-geocode a `CLLocation` into a human-readable place name.
    func locationName(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw LocationError.geocodingFailed
        }

        // Build a readable name: "Lake Diefenbaker, SK" or "Saskatoon, SK"
        let components = [
            placemark.name,
            placemark.locality,
            placemark.administrativeArea
        ].compactMap { $0 }

        // Deduplicate (name and locality are sometimes identical)
        var seen = Set<String>()
        let unique = components.filter { seen.insert($0).inserted }

        return unique.isEmpty ? "Unknown Location" : unique.joined(separator: ", ")
    }
}

// MARK: - LocationError

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission is required to tag your catches with GPS coordinates."
        case .locationUnavailable:
            return "Unable to determine your current location. Please try again."
        case .geocodingFailed:
            return "Unable to determine the name of your location."
        }
    }
}

// MARK: - LocationDelegate

/// Internal delegate that bridges `CLLocationManagerDelegate` callbacks into async continuations.
private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {

    var authorizationContinuation: CheckedContinuation<Void, Never>?
    var locationContinuation: CheckedContinuation<CLLocation, any Error>?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Only fire if we have a pending authorization request
        guard manager.authorizationStatus != .notDetermined else { return }
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: LocationError.locationUnavailable)
            locationContinuation = nil
            return
        }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.locationUnavailable)
        locationContinuation = nil
    }
}
