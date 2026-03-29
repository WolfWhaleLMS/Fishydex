import CoreLocation

struct WaterBody: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let type: WaterBodyType

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum WaterBodyType: String, Codable {
        case lake
        case river
        case reservoir
        case creek
        case region
    }
}
