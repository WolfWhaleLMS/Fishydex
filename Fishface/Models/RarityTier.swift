import SwiftUI

enum RarityTier: String, Codable, CaseIterable, Identifiable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    case mythic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .common:    return "Common"
        case .uncommon:  return "Uncommon"
        case .rare:      return "Rare"
        case .epic:      return "Epic"
        case .legendary: return "Legendary"
        case .mythic:    return "Mythic"
        }
    }

    /// Fortnite-style RGB color tuple for the rarity tier.
    var color: (r: Double, g: Double, b: Double) {
        switch self {
        case .common:    return (0.549, 0.549, 0.549)   // Gray    #8C8C8C
        case .uncommon:  return (0.118, 1.000, 0.000)   // Green   #1EFF00
        case .rare:      return (0.298, 0.545, 1.000)   // Blue    #4C8BFF
        case .epic:      return (0.745, 0.047, 0.996)   // Purple  #BE0CFE
        case .legendary: return (1.000, 0.549, 0.000)   // Orange  #FF8C00
        case .mythic:    return (1.000, 0.843, 0.000)   // Gold    #FFD700
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
        case .uncommon:  return false
        case .rare:      return true
        case .epic:      return true
        case .legendary: return true
        case .mythic:    return true
        }
    }

    /// Glow radius for visual effects (points).
    var glowRadius: CGFloat {
        switch self {
        case .common:    return 0
        case .uncommon:  return 0
        case .rare:      return 6
        case .epic:      return 10
        case .legendary: return 14
        case .mythic:    return 20
        }
    }

    /// Glow animation style description.
    var glowStyle: String {
        switch self {
        case .common:    return "none"
        case .uncommon:  return "none"
        case .rare:      return "blue pulse"
        case .epic:      return "purple shimmer"
        case .legendary: return "orange flame glow"
        case .mythic:    return "gold particle aura"
        }
    }

    /// Sort order (0 = most common, 5 = rarest).
    var sortOrder: Int {
        switch self {
        case .common:    return 0
        case .uncommon:  return 1
        case .rare:      return 2
        case .epic:      return 3
        case .legendary: return 4
        case .mythic:    return 5
        }
    }
}
