import SwiftUI

/// Data-readout display for a fish's physical and conservation stats.
///
/// Shows size range bar, max weight, conservation status badge,
/// COSEWIC status, and native/exotic indicator in monospace styling.
struct FishStatsView: View {
    let fish: Fish

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            sectionHeader("SPECIES DATA")

            // Size range
            statRow(icon: "ruler", label: "SIZE", value: fish.sizeRange)

            // Max weight
            if let weight = fish.maxWeight {
                statRow(icon: "scalemass", label: "MAX WEIGHT", value: weight)
            }

            // Conservation status
            if let status = fish.conservationStatus {
                statRow(icon: "leaf.fill", label: "CONSERVATION", value: status)
            }

            // COSEWIC status
            if let cosewic = fish.cosewicStatus {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.atRisk)
                        .frame(width: 20)

                    Text("COSEWIC")
                        .font(.dataReadout(size: 10))
                        .foregroundStyle(Color.screenGlow.opacity(0.6))

                    Text(cosewic)
                        .font(.dataReadout(size: 11))
                        .foregroundStyle(Color.atRisk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.atRisk.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            // Native / Exotic indicator
            HStack(spacing: 8) {
                Image(systemName: fish.isNative ? "mappin.circle.fill" : "airplane")
                    .font(.system(size: 12))
                    .foregroundStyle(fish.isNative ? Color.forageFish : Color.exoticSpecies)
                    .frame(width: 20)

                Text("ORIGIN")
                    .font(.dataReadout(size: 10))
                    .foregroundStyle(Color.screenGlow.opacity(0.6))

                Text(fish.isNative ? "Native to Saskatchewan" : "Introduced / Exotic")
                    .font(.dataReadout(size: 11))
                    .foregroundStyle(fish.isNative ? Color.forageFish : Color.exoticSpecies)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(Color.screenBackground.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .strokeBorder(Color.screenGlow.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private func sectionHeader(_ text: String) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(Color.screenGlow.opacity(0.4))
                .frame(width: 3, height: 14)

            Text(text)
                .font(.pixelFont(size: 11))
                .foregroundStyle(Color.screenGlow.opacity(0.8))
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Color.screenGlow.opacity(0.6))
                .frame(width: 20)

            Text(label)
                .font(.dataReadout(size: 10))
                .foregroundStyle(Color.screenGlow.opacity(0.6))

            Spacer()

            Text(value)
                .font(.dataReadout(size: 11))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview

#Preview("Fish Stats") {
    FishStatsView(fish: Fish(
        id: 2,
        commonName: "Lake Sturgeon",
        scientificName: "Acipenser fulvescens",
        family: "Acipenseridae",
        familyCommonName: "Sturgeons",
        category: .sportFish,
        rarityTier: .legendary,
        conservationStatus: "S2 (imperiled)",
        cosewicStatus: "Endangered",
        sizeRange: "90-180 cm",
        maxWeight: "45+ kg",
        description: "An ancient armoured fish.",
        habitat: "Large rivers and lakes.",
        funFact: "Can live over 100 years.",
        isNative: true
    ))
    .padding()
    .background(Color.screenBackground)
}
