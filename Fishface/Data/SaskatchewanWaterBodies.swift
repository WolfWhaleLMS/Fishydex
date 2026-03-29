import Foundation

// MARK: - Saskatchewan Water Bodies

/// Major lakes, rivers, reservoirs, creeks, and regions where fish are found in Saskatchewan.
/// Coordinates are approximate centroids for map pin placement.
enum SaskatchewanWaterBodies {

    // MARK: - All Water Bodies

    static let all: [WaterBody] = lakes + rivers + reservoirs + creeks + regions

    // MARK: - Lakes (30)

    static let lakes: [WaterBody] = [
        // — Far North / Shield —
        WaterBody(id: "athabasca", name: "Lake Athabasca", latitude: 59.15, longitude: -109.40, type: .lake),
        WaterBody(id: "reindeer", name: "Reindeer Lake", latitude: 57.30, longitude: -102.30, type: .lake),
        WaterBody(id: "wollaston", name: "Wollaston Lake", latitude: 58.25, longitude: -103.30, type: .lake),
        WaterBody(id: "cree", name: "Cree Lake", latitude: 57.40, longitude: -107.00, type: .lake),
        WaterBody(id: "black", name: "Black Lake", latitude: 59.10, longitude: -105.50, type: .lake),
        WaterBody(id: "fond_du_lac", name: "Fond du Lac River/Lake", latitude: 59.33, longitude: -107.20, type: .lake),

        // — La Ronge / Mid-North —
        WaterBody(id: "lac_la_ronge", name: "Lac la Ronge", latitude: 55.10, longitude: -105.00, type: .lake),
        WaterBody(id: "peter_pond", name: "Peter Pond Lake", latitude: 55.55, longitude: -108.60, type: .lake),
        WaterBody(id: "montreal", name: "Montreal Lake", latitude: 54.20, longitude: -105.70, type: .lake),
        WaterBody(id: "dore", name: "Doré Lake", latitude: 54.75, longitude: -107.40, type: .lake),
        WaterBody(id: "jan", name: "Jan Lake", latitude: 54.92, longitude: -103.90, type: .lake),
        WaterBody(id: "nemeiben", name: "Nemeiben Lake", latitude: 55.25, longitude: -105.50, type: .lake),
        WaterBody(id: "wapawekka", name: "Wapawekka Lake", latitude: 55.00, longitude: -104.60, type: .lake),
        WaterBody(id: "otter", name: "Otter Lake", latitude: 56.50, longitude: -108.40, type: .lake),

        // — Prince Albert / Central —
        WaterBody(id: "candle", name: "Candle Lake", latitude: 53.80, longitude: -105.30, type: .lake),
        WaterBody(id: "emma", name: "Emma Lake", latitude: 53.63, longitude: -106.00, type: .lake),
        WaterBody(id: "anglin", name: "Anglin Lake", latitude: 53.72, longitude: -106.10, type: .lake),
        WaterBody(id: "christopher", name: "Christopher Lake", latitude: 53.62, longitude: -105.70, type: .lake),
        WaterBody(id: "waskesiu", name: "Waskesiu Lake", latitude: 53.92, longitude: -106.08, type: .lake),

        // — East-Central —
        WaterBody(id: "tobin", name: "Tobin Lake", latitude: 53.60, longitude: -103.40, type: .lake),
        WaterBody(id: "cumberland", name: "Cumberland Lake", latitude: 54.05, longitude: -102.30, type: .lake),
        WaterBody(id: "good_spirit", name: "Good Spirit Lake", latitude: 51.50, longitude: -102.65, type: .lake),

        // — Saskatoon / South-Central —
        WaterBody(id: "last_mountain", name: "Last Mountain Lake", latitude: 51.10, longitude: -105.20, type: .lake),
        WaterBody(id: "diefenbaker", name: "Lake Diefenbaker", latitude: 50.80, longitude: -107.00, type: .lake),
        WaterBody(id: "blackstrap", name: "Blackstrap Lake", latitude: 51.80, longitude: -106.50, type: .lake),
        WaterBody(id: "pike", name: "Pike Lake", latitude: 51.95, longitude: -106.90, type: .lake),
        WaterBody(id: "manitou", name: "Manitou Lake", latitude: 52.75, longitude: -109.80, type: .lake),

        // — South —
        WaterBody(id: "crooked", name: "Crooked Lake", latitude: 50.62, longitude: -102.75, type: .lake),
        WaterBody(id: "round", name: "Round Lake", latitude: 50.55, longitude: -102.30, type: .lake),
        WaterBody(id: "katepwa", name: "Katepwa Lake", latitude: 50.70, longitude: -103.60, type: .lake),
    ]

    // MARK: - Rivers (14)

    static let rivers: [WaterBody] = [
        // — Major Rivers —
        WaterBody(id: "north_sask", name: "North Saskatchewan River", latitude: 52.65, longitude: -106.10, type: .river),
        WaterBody(id: "south_sask", name: "South Saskatchewan River", latitude: 51.50, longitude: -107.20, type: .river),
        WaterBody(id: "sask_river", name: "Saskatchewan River", latitude: 53.80, longitude: -103.00, type: .river),
        WaterBody(id: "churchill", name: "Churchill River", latitude: 55.80, longitude: -108.20, type: .river),
        WaterBody(id: "quappelle", name: "Qu'Appelle River", latitude: 50.70, longitude: -104.00, type: .river),
        WaterBody(id: "assiniboine", name: "Assiniboine River", latitude: 51.10, longitude: -101.90, type: .river),

        // — Prince Albert / Saskatoon Area —
        WaterBody(id: "sturgeon", name: "Sturgeon River", latitude: 53.50, longitude: -105.00, type: .river),
        WaterBody(id: "torch", name: "Torch River", latitude: 53.55, longitude: -104.20, type: .river),
        WaterBody(id: "shell", name: "Shell River (PA)", latitude: 53.20, longitude: -105.75, type: .river),

        // — Other Notable —
        WaterBody(id: "carrot", name: "Carrot River", latitude: 53.50, longitude: -103.50, type: .river),
        WaterBody(id: "frenchman", name: "Frenchman River", latitude: 49.20, longitude: -108.50, type: .river),
        WaterBody(id: "souris", name: "Souris River", latitude: 49.60, longitude: -102.50, type: .river),
        WaterBody(id: "battle", name: "Battle River", latitude: 52.70, longitude: -109.20, type: .river),
        WaterBody(id: "clearwater", name: "Clearwater River", latitude: 56.70, longitude: -109.10, type: .river),
    ]

    // MARK: - Reservoirs (3)

    static let reservoirs: [WaterBody] = [
        WaterBody(id: "rafferty", name: "Rafferty Reservoir", latitude: 49.20, longitude: -102.60, type: .reservoir),
        WaterBody(id: "gardiner", name: "Gardiner Dam Reservoir", latitude: 51.10, longitude: -106.90, type: .reservoir),
        WaterBody(id: "codette", name: "Codette Lake (Reservoir)", latitude: 53.45, longitude: -103.95, type: .reservoir),
    ]

    // MARK: - Creeks (3)

    static let creeks: [WaterBody] = [
        WaterBody(id: "swift_current", name: "Swift Current Creek", latitude: 50.30, longitude: -107.80, type: .creek),
        WaterBody(id: "wascana", name: "Wascana Creek", latitude: 50.45, longitude: -104.60, type: .creek),
        WaterBody(id: "moose_jaw", name: "Moose Jaw River", latitude: 50.40, longitude: -105.55, type: .creek),
    ]

    // MARK: - Regions (3)

    static let regions: [WaterBody] = [
        WaterBody(id: "cypress_hills", name: "Cypress Hills", latitude: 49.60, longitude: -109.50, type: .region),
        WaterBody(id: "northern_boreal", name: "Northern Boreal", latitude: 56.00, longitude: -106.00, type: .region),
        WaterBody(id: "southern_prairie", name: "Southern Prairie", latitude: 50.50, longitude: -105.50, type: .region),
    ]

    /// Look up a water body by ID.
    static func waterBody(_ id: String) -> WaterBody? {
        all.first { $0.id == id }
    }
}
