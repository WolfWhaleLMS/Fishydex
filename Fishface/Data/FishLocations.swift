import Foundation

// MARK: - Fish Location Mapping

/// Maps each fish ID to the Saskatchewan water bodies where it can be found.
/// Based on habitat data from species descriptions and Saskatchewan fisheries records.
enum FishLocations {

    /// Water body IDs for each fish, keyed by fish ID.
    static let locations: [Int: [String]] = [
        // #001 Chestnut Lamprey — Saskatchewan-Nelson drainage
        1: ["sask_river", "north_sask", "south_sask", "cumberland", "sturgeon"],

        // #002 Lake Sturgeon — Saskatchewan River, Cumberland, Tobin, Churchill
        2: ["sask_river", "cumberland", "tobin", "churchill", "north_sask", "codette", "sturgeon"],

        // #003 Quillback — Saskatchewan River system
        3: ["sask_river", "north_sask", "south_sask", "tobin"],

        // #004 Longnose Sucker — province-wide, especially northern
        4: ["lac_la_ronge", "reindeer", "churchill", "athabasca", "candle", "north_sask", "waskesiu", "nemeiben", "emma"],

        // #005 White Sucker — widespread
        5: ["sask_river", "quappelle", "last_mountain", "diefenbaker", "south_sask", "north_sask", "blackstrap", "wascana", "good_spirit", "crooked"],

        // #006 Plains Sucker — Frenchman River (extreme SW)
        6: ["frenchman"],

        // #007 Bigmouth Buffalo — Saskatchewan River, Qu'Appelle
        7: ["sask_river", "quappelle", "last_mountain", "tobin"],

        // #008 Silver Redhorse — Saskatchewan River system
        8: ["sask_river", "north_sask", "south_sask"],

        // #009 Shorthead Redhorse — North & South Saskatchewan rivers
        9: ["north_sask", "south_sask", "sask_river", "battle"],

        // #010 Northern Pike — virtually everywhere
        10: ["lac_la_ronge", "tobin", "reindeer", "athabasca", "diefenbaker", "last_mountain", "cumberland", "candle", "quappelle",
             "waskesiu", "emma", "anglin", "christopher", "blackstrap", "pike", "good_spirit", "crooked", "katepwa",
             "montreal", "dore", "jan", "codette", "nemeiben", "round", "gardiner"],

        // #011 Central Mudminnow — Carrot River drainage
        11: ["carrot"],

        // #012 Burbot — deep cold lakes and rivers
        12: ["lac_la_ronge", "reindeer", "athabasca", "wollaston", "cree", "churchill", "black", "nemeiben", "wapawekka"],

        // #013 Brook Stickleback — province-wide
        13: ["sask_river", "quappelle", "candle", "south_sask", "northern_boreal", "wascana", "moose_jaw"],

        // #014 Ninespine Stickleback — northern/boreal
        14: ["churchill", "lac_la_ronge", "reindeer", "northern_boreal"],

        // #015 Goldeye — Saskatchewan River system
        15: ["sask_river", "north_sask", "south_sask", "tobin", "cumberland", "codette"],

        // #016 Mooneye — Saskatchewan River system
        16: ["sask_river", "north_sask", "south_sask"],

        // #017 Rainbow Smelt — exotic, introduced to select lakes
        17: ["last_mountain"],

        // #018 Rock Bass — Saskatchewan River system
        18: ["sask_river", "north_sask", "tobin"],

        // #019 Bluegill — exotic, rare/not established
        19: ["southern_prairie"],

        // #020 Smallmouth Bass — eastern Saskatchewan
        20: ["lac_la_ronge", "montreal", "jan"],

        // #021 Largemouth Bass — Rafferty Reservoir
        21: ["rafferty"],

        // #022 White Crappie — exotic, rare
        22: ["southern_prairie"],

        // #023 Black Crappie — exotic, rare
        23: ["southern_prairie"],

        // #024 Iowa Darter — central and southern
        24: ["quappelle", "last_mountain", "south_sask", "assiniboine", "wascana", "good_spirit"],

        // #025 Johnny Darter — across Saskatchewan
        25: ["sask_river", "quappelle", "north_sask", "south_sask", "candle", "shell", "sturgeon"],

        // #026 Yellow Perch — province-wide
        26: ["lac_la_ronge", "tobin", "last_mountain", "diefenbaker", "candle", "quappelle", "reindeer",
             "emma", "anglin", "waskesiu", "blackstrap", "good_spirit", "crooked", "katepwa", "round", "pike"],

        // #027 Logperch — lakes and rivers throughout
        27: ["sask_river", "diefenbaker", "last_mountain", "quappelle"],

        // #028 Blackside Darter — eastern/central rivers
        28: ["sask_river", "assiniboine"],

        // #029 River Darter — major river systems
        29: ["sask_river", "north_sask", "south_sask"],

        // #030 Sauger — Saskatchewan River, Qu'Appelle
        30: ["sask_river", "tobin", "quappelle", "diefenbaker", "south_sask", "codette"],

        // #031 Walleye — lakes and rivers throughout
        31: ["tobin", "lac_la_ronge", "reindeer", "diefenbaker", "last_mountain", "candle", "cumberland", "quappelle",
             "montreal", "dore", "jan", "nemeiben", "waskesiu", "good_spirit", "crooked", "katepwa", "codette", "gardiner"],

        // #032 Trout-perch — lakes and rivers throughout
        32: ["lac_la_ronge", "last_mountain", "sask_river", "candle"],

        // #033 Cisco — cool deep lakes, boreal/shield
        33: ["lac_la_ronge", "reindeer", "wollaston", "athabasca", "cree", "candle", "black", "nemeiben", "wapawekka"],

        // #034 Lake Whitefish — northern lakes
        34: ["lac_la_ronge", "peter_pond", "churchill", "reindeer", "athabasca", "wollaston", "montreal", "dore", "nemeiben", "waskesiu"],

        // #035 Shortjaw Cisco — Reindeer Lake, Lake Athabasca only
        35: ["reindeer", "athabasca"],

        // #036 Cutthroat Trout — exotic, Cypress Hills
        36: ["cypress_hills"],

        // #037 Coho Salmon — exotic, limited
        37: ["lac_la_ronge"],

        // #038 Rainbow Trout — stocked cold-water lakes
        38: ["diefenbaker", "cypress_hills", "candle", "emma"],

        // #039 Kokanee — select reservoirs
        39: ["diefenbaker"],

        // #040 Round Whitefish — northern boreal/shield
        40: ["reindeer", "wollaston", "athabasca", "cree", "black"],

        // #041 Mountain Whitefish — western Saskatchewan
        41: ["north_sask", "cypress_hills", "clearwater"],

        // #042 Atlantic Salmon — exotic, not established
        42: ["lac_la_ronge"],

        // #043 Brown Trout — Cypress Hills
        43: ["cypress_hills"],

        // #044 Tiger Trout — select stocked lakes
        44: ["candle"],

        // #045 Arctic Char — exotic, limited
        45: ["northern_boreal"],

        // #046 Brook Trout — Cypress Hills, stocked elsewhere
        46: ["cypress_hills", "candle"],

        // #047 Splake — select cold deep lakes
        47: ["lac_la_ronge", "candle"],

        // #048 Lake Trout — deep northern lakes
        48: ["lac_la_ronge", "wollaston", "athabasca", "reindeer", "cree", "black", "nemeiben"],

        // #049 Arctic Grayling — Churchill River system
        49: ["churchill", "northern_boreal", "clearwater", "fond_du_lac"],

        // #050 Slimy Sculpin — boreal streams throughout
        50: ["churchill", "lac_la_ronge", "northern_boreal", "north_sask", "sturgeon"],

        // #051 Spoonhead Sculpin — northern shield lakes
        51: ["reindeer", "wollaston", "athabasca", "northern_boreal"],

        // #052 Deepwater Sculpin — very deep northern lakes
        52: ["reindeer", "athabasca", "wollaston"],

        // #053 Black Bullhead — southern Saskatchewan
        53: ["quappelle", "last_mountain", "southern_prairie", "wascana", "good_spirit"],

        // #054 Brown Bullhead — southern Saskatchewan
        54: ["quappelle", "assiniboine", "southern_prairie", "souris"],

        // #055 Channel Catfish — South Saskatchewan River system
        55: ["south_sask", "sask_river", "diefenbaker", "gardiner"],

        // #056 Stonecat — Saskatchewan River system
        56: ["sask_river", "north_sask", "south_sask"],

        // #057 Tadpole Madtom — southern Saskatchewan
        57: ["quappelle", "assiniboine", "southern_prairie"],

        // #058 Freshwater Drum — Swift Current Creek
        58: ["swift_current"],

        // #059 Grass Carp — exotic
        59: ["southern_prairie"],

        // #060 American Eel — vagrant, extremely rare
        60: ["sask_river"],
    ]

    /// Get the water bodies where a given fish can be found.
    static func waterBodies(forFishId id: Int) -> [WaterBody] {
        guard let ids = locations[id] else { return [] }
        return ids.compactMap { SaskatchewanWaterBodies.waterBody($0) }
    }

    /// Get all fish IDs found at a given water body.
    static func fishIds(atWaterBody waterBodyId: String) -> [Int] {
        locations.filter { $0.value.contains(waterBodyId) }
            .map(\.key)
            .sorted()
    }
}
