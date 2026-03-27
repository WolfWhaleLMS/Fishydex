import SwiftUI

enum RarityTier: String, Codable, CaseIterable, Identifiable {
    case common
    case uncommon
    case rare
    case legendary

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .common:    return "Common"
        case .uncommon:  return "Uncommon"
        case .rare:      return "Rare"
        case .legendary: return "Legendary"
        }
    }

    /// RGB color tuple for the rarity tier.
    var color: (r: Double, g: Double, b: Double) {
        switch self {
        case .common:    return (0.133, 0.773, 0.369)   // Green  #22C55E
        case .uncommon:  return (0.231, 0.510, 0.965)   // Blue   #3B82F6
        case .rare:      return (0.659, 0.333, 0.969)    // Purple #A855F7
        case .legendary: return (0.918, 0.702, 0.031)    // Gold   #EAB308
        }
    }

    var swiftUIColor: Color {
        let c = color
        return Color(red: c.r, green: c.g, blue: c.b)
    }

    /// Whether this tier should render a glow effect around the entry.
    var hasGlow: Bool {
        switch self {
        case .common:    return false
        case .uncommon:  return true
        case .rare:      return true
        case .legendary: return true
        }
    }

    /// Glow radius for visual effects (points).
    var glowRadius: CGFloat {
        switch self {
        case .common:    return 0
        case .uncommon:  return 4
        case .rare:      return 8
        case .legendary: return 14
        }
    }

    /// Glow animation style description.
    var glowStyle: String {
        switch self {
        case .common:    return "none"
        case .uncommon:  return "subtle blue pulse"
        case .rare:      return "purple shimmer"
        case .legendary: return "gold particle glow"
        }
    }

    /// Sort order (0 = most common, 3 = rarest).
    var sortOrder: Int {
        switch self {
        case .common:    return 0
        case .uncommon:  return 1
        case .rare:      return 2
        case .legendary: return 3
        }
    }
}
