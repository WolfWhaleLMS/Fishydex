import SwiftUI

/// A single grid cell in the Pokedex grid.
///
/// Shows either a discovered fish (image, name, type badge) or an
/// undiscovered silhouette with "???" placeholder text.
struct PokedexEntryCell: View {
    let fish: Fish
    let isDiscovered: Bool

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 6) {
            // MARK: - Image Area
            ZStack {
                // Dark background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.screenBackground)
                    .aspectRatio(1, contentMode: .fit)

                if isDiscovered {
                    // Discovered: show actual fish image
                    Image(fish.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .accessibilityLabel(fish.commonName)
                } else {
                    // Undiscovered: show silhouette or fish icon placeholder
                    Image(systemName: "fish.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .foregroundStyle(Color.metalDark.opacity(0.3))
                        .accessibilityLabel("Undiscovered fish")
                }

                // Entry number overlay (top-left)
                VStack {
                    HStack {
                        Text(fish.formattedId)
                            .font(.pixelFont(size: 9))
                            .foregroundStyle(
                                isDiscovered
                                    ? Color.screenGlow.opacity(0.8)
                                    : Color.metalDark.opacity(0.5)
                            )
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isDiscovered
                            ? Color.metalSilver.opacity(0.3)
                            : Color.metalDark.opacity(0.2),
                        lineWidth: 1
                    )
            )

            // MARK: - Name + Badge
            VStack(spacing: 3) {
                Text(isDiscovered ? fish.commonName : "???")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(
                        isDiscovered ? .white : .white.opacity(0.35)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if isDiscovered {
                    TypeBadge(category: fish.category, size: .compact)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.2).opacity(0.8))
        )
        .modifier(CellRarityGlow(tier: fish.rarityTier, isDiscovered: isDiscovered))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isDiscovered
                ? "\(fish.formattedId) \(fish.commonName), \(fish.category.rawValue)"
                : "\(fish.formattedId) Undiscovered fish"
        )
    }
}

// MARK: - Cell Rarity Glow

/// Applies a subtle rarity glow to discovered cells only.
private struct CellRarityGlow: ViewModifier {
    let tier: RarityTier
    let isDiscovered: Bool

    @State private var animating = false

    func body(content: Content) -> some View {
        if isDiscovered && tier.hasGlow {
            content
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.4 : 0.1),
                    radius: animating ? tier.glowRadius : tier.glowRadius * 0.4
                )
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animating
                )
                .onAppear { animating = true }
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview("Entry Cells") {
    let sampleFish = Fish(
        id: 34,
        commonName: "Northern Pike",
        scientificName: "Esox lucius",
        family: "Esocidae",
        familyCommonName: "Pikes",
        category: .sportFish,
        rarityTier: .common,
        conservationStatus: "S5 (secure)",
        cosewicStatus: nil,
        sizeRange: "50-120 cm",
        maxWeight: "19+ kg",
        description: "A premier sport fish.",
        habitat: "Lakes and rivers across Saskatchewan.",
        funFact: "Also called jackfish.",
        isNative: true
    )

    HStack(spacing: 12) {
        PokedexEntryCell(fish: sampleFish, isDiscovered: true)
            .frame(width: 110)
        PokedexEntryCell(fish: sampleFish, isDiscovered: false)
            .frame(width: 110)
    }
    .padding()
    .background(Color.screenBackground)
}
