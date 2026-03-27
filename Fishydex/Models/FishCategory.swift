import SwiftUI

enum FishCategory: String, Codable, CaseIterable, Identifiable {
    case sportFish = "Sport Fish"
    case forageFish = "Forage Fish"
    case coarseFish = "Coarse Fish"
    case invasive = "Invasive"
    case exotic = "Exotic"
    case hybrid = "Hybrid"

    var id: String { rawValue }

    /// RGB color tuple matching the design spec hex values.
    var color: (r: Double, g: Double, b: Double) {
        switch self {
        case .sportFish:  return (0.231, 0.510, 0.965)  // #3B82F6
        case .forageFish: return (0.133, 0.773, 0.369)   // #22C55E
        case .coarseFish: return (0.961, 0.620, 0.043)   // #F59E0B
        case .invasive:   return (0.937, 0.267, 0.267)   // #EF4444
        case .exotic:     return (0.659, 0.333, 0.969)    // #A855F7
        case .hybrid:     return (0.078, 0.722, 0.651)    // #14B8A6
        }
    }

    var swiftUIColor: Color {
        let c = color
        return Color(red: c.r, green: c.g, blue: c.b)
    }

    var iconName: String {
        switch self {
        case .sportFish:  return "figure.fishing"
        case .forageFish: return "leaf.fill"
        case .coarseFish: return "water.waves"
        case .invasive:   return "exclamationmark.triangle.fill"
        case .exotic:     return "star.fill"
        case .hybrid:     return "arrow.triangle.merge"
        }
    }
}
