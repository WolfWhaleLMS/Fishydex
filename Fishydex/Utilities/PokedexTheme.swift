import SwiftUI

// MARK: - Color Extensions

extension Color {

    // MARK: Shell Colors

    /// Primary Pokedex red (#DC0A2D)
    static let pokedexRed = Color(red: 0.863, green: 0.039, blue: 0.176)

    /// Darker red accent for shell depth (#A00020)
    static let pokedexDarkRed = Color(red: 0.627, green: 0.0, blue: 0.125)

    /// Pokedex blue accent (#3B82F6)
    static let pokedexBlue = Color(red: 0.231, green: 0.510, blue: 0.965)

    // MARK: Screen Colors

    /// Dark CRT screen background (#1a1a2e)
    static let screenBackground = Color(red: 0.102, green: 0.102, blue: 0.180)

    /// Green CRT glow text (#00ff41)
    static let screenGlow = Color(red: 0.0, green: 1.0, blue: 0.255)

    // MARK: Metal Colors

    /// Metallic silver for bezels (#C0C0C8)
    static let metalSilver = Color(red: 0.753, green: 0.753, blue: 0.784)

    /// Dark metal for borders and shadows (#6B7280)
    static let metalDark = Color(red: 0.420, green: 0.447, blue: 0.502)

    // MARK: Category / Type Badge Colors

    /// Sport Fish — ocean blue (#3B82F6)
    static let sportFish = Color(red: 0.231, green: 0.510, blue: 0.965)

    /// Forage Fish — forest green (#22C55E)
    static let forageFish = Color(red: 0.133, green: 0.773, blue: 0.369)

    /// Coarse Fish — amber (#F59E0B)
    static let coarseFish = Color(red: 0.961, green: 0.620, blue: 0.043)

    /// Invasive Species — red (#EF4444)
    static let invasiveSpecies = Color(red: 0.937, green: 0.267, blue: 0.267)

    /// Exotic / Introduced Species — purple (#A855F7)
    static let exoticSpecies = Color(red: 0.659, green: 0.333, blue: 0.969)

    /// Hybrid Species — teal (#14B8A6)
    static let hybridSpecies = Color(red: 0.078, green: 0.722, blue: 0.651)

    /// At-Risk Species — gold (#EAB308)
    static let atRisk = Color(red: 0.918, green: 0.702, blue: 0.031)

    // MARK: Rarity Colors

    /// Common rarity — standard text (primary label)
    static let rarityCommon = Color.primary

    /// Uncommon rarity — blue (#3B82F6)
    static let rarityUncommon = Color(red: 0.231, green: 0.510, blue: 0.965)

    /// Rare rarity — purple (#A855F7)
    static let rarityRare = Color(red: 0.659, green: 0.333, blue: 0.969)

    /// Legendary rarity — gold (#EAB308)
    static let rarityLegendary = Color(red: 0.918, green: 0.702, blue: 0.031)
}

// MARK: - Font Helpers

extension Font {

    /// Monospace font for Pokedex entry numbers (#001, #034, etc.)
    static func pixelFont(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }

    /// Monospace font for scanner data readout text.
    static func dataReadout(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    /// Italic font for scientific names (e.g., *Esox lucius*).
    static func scientificName(size: CGFloat = 14) -> Font {
        .system(size: size, design: .serif).italic()
    }
}

// MARK: - Spacing & Layout Constants

enum PokedexLayout {
    /// Corner radius for the shell frame
    static let shellCornerRadius: CGFloat = 20

    /// Corner radius for interior cards
    static let cardCornerRadius: CGFloat = 12

    /// Standard screen-edge padding
    static let screenPadding: CGFloat = 16

    /// Grid cell spacing
    static let gridSpacing: CGFloat = 12

    /// Grid column count on iPhone
    static let gridColumns = 3

    /// Shell bezel width
    static let bezelWidth: CGFloat = 4

    /// Standard icon size in badges
    static let badgeIconSize: CGFloat = 12

    /// Height of the progress bar
    static let progressBarHeight: CGFloat = 8
}

// MARK: - Shadow Presets

extension View {
    /// Applies a standard Pokedex shell shadow (outer depth).
    func pokedexShadow() -> some View {
        self.shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
    }

    /// Applies a subtle inner glow matching a given color.
    func innerGlow(color: Color = .screenGlow, radius: CGFloat = 4) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}
