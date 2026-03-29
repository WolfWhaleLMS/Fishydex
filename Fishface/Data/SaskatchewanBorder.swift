import CoreLocation

// MARK: - Saskatchewan Province Border

/// Simplified polygon coordinates for the Saskatchewan provincial boundary.
/// Used to draw the province outline on the fish map.
///
/// Saskatchewan is roughly rectangular:
/// - South border: 49°N (US border)
/// - North border: 60°N (NWT border)
/// - West border: ~110°W (Alberta border, slight offset north of 54°N)
/// - East border: ~102°W (Manitoba border, slight offset north of ~54°N)
enum SaskatchewanBorder {

    /// Province boundary as an array of CLLocationCoordinate2D, ordered clockwise.
    /// Uses the actual legal boundaries including the jogs near the 4th meridian.
    static let coordinates: [CLLocationCoordinate2D] = [
        // SW corner (US border / Alberta border)
        CLLocationCoordinate2D(latitude: 49.00, longitude: -110.00),
        // NW — west border goes north along ~110°W
        CLLocationCoordinate2D(latitude: 54.00, longitude: -110.00),
        // Jog west at 54°N (Alberta border shifts slightly)
        CLLocationCoordinate2D(latitude: 54.00, longitude: -110.00),
        CLLocationCoordinate2D(latitude: 60.00, longitude: -110.00),
        // NE corner (NWT / Manitoba)
        CLLocationCoordinate2D(latitude: 60.00, longitude: -102.00),
        // East border goes south along ~102°W
        CLLocationCoordinate2D(latitude: 54.00, longitude: -102.00),
        // SE corner shift — below 54°N, east border is at ~101.36°W
        CLLocationCoordinate2D(latitude: 54.00, longitude: -101.36),
        CLLocationCoordinate2D(latitude: 49.00, longitude: -101.36),
        // Close back to SW corner along 49th parallel
        CLLocationCoordinate2D(latitude: 49.00, longitude: -110.00),
    ]
}
