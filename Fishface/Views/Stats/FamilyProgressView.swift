import SwiftUI

/// Per-family progress bars showing completion percentage for each of the 17
/// Saskatchewan fish families.
///
/// Each row displays the family common name, a progress bar, and "X/Y" count.
/// Rows are sorted by completion percentage (highest first).
struct FamilyProgressView: View {
    let discoveredFishIds: Set<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(sortedFamilies, id: \.family.id) { entry in
                familyRow(
                    name: entry.family.commonName,
                    discovered: entry.discovered,
                    total: entry.total,
                    color: colorForProgress(entry.discovered, total: entry.total)
                )
            }
        }
    }

    // MARK: - Data

    /// Families sorted by completion percentage (descending), then alphabetically.
    private var sortedFamilies: [FamilyEntry] {
        let allFish = FishDatabase.allFish
        let families = FishFamily.allFamilies

        return families.map { family in
            let fishInFamily = allFish.filter { $0.family == family.name }
            let discoveredInFamily = fishInFamily.filter { discoveredFishIds.contains($0.id) }
            return FamilyEntry(
                family: family,
                discovered: discoveredInFamily.count,
                total: fishInFamily.count
            )
        }
        .filter { $0.total > 0 }
        .sorted { lhs, rhs in
            let lhsPct = lhs.total > 0 ? Double(lhs.discovered) / Double(lhs.total) : 0
            let rhsPct = rhs.total > 0 ? Double(rhs.discovered) / Double(rhs.total) : 0
            if lhsPct != rhsPct { return lhsPct > rhsPct }
            return lhs.family.commonName < rhs.family.commonName
        }
    }

    // MARK: - Row

    private func familyRow(name: String, discovered: Int, total: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)

                Spacer()

                Text("\(discovered)/\(total)")
                    .font(.dataReadout(size: 11))
                    .foregroundStyle(color.opacity(0.8))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.screenBackground.opacity(0.5))

                    // Fill
                    let progress = total > 0 ? Double(discovered) / Double(total) : 0
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Helpers

    private func colorForProgress(_ discovered: Int, total: Int) -> Color {
        guard total > 0 else { return .metalDark }
        let pct = Double(discovered) / Double(total)
        if pct >= 1.0 { return .rarityLegendary }
        if pct >= 0.5 { return .screenGlow }
        if pct > 0 { return .pokedexBlue }
        return .metalDark.opacity(0.5)
    }
}

// MARK: - Private Types

private struct FamilyEntry {
    let family: FishFamily
    let discovered: Int
    let total: Int
}

// MARK: - Preview

#Preview("Family Progress") {
    ScrollView {
        FamilyProgressView(discoveredFishIds: [1, 2, 3, 34, 55, 72])
            .padding()
    }
    .background(Color.screenBackground)
}
