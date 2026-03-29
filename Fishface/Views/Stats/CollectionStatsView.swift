import SwiftUI

/// Overall collection progress and statistics screen.
///
/// Wrapped in PokedexShellView, shows:
/// - Circular progress ring (X/60 discovered)
/// - Per-category completion bars
/// - Per-family completion bars
/// - Rarity breakdown
/// - Achievements section
struct CollectionStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var discoveredFishIds: Set<Int> = []
    @State private var isLoading = true

    private var allFish: [Fish] { FishDatabase.allFish }
    private var totalCount: Int { allFish.count }
    private var discoveredCount: Int { discoveredFishIds.count }
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(discoveredCount) / Double(totalCount)
    }

    var body: some View {
        NavigationStack {
            PokedexShellView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Circular progress ring
                        progressRing
                            .padding(.top, 16)

                        // Category bars
                        categorySection

                        // Rarity breakdown
                        raritySection

                        // Family progress
                        familySection

                        // Achievements
                        achievementsSection

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, PokedexLayout.screenPadding)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await loadDiscoveries()
        }
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.screenBackground.opacity(0.5), lineWidth: 12)
                    .frame(width: 140, height: 140)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.pokedexRed, .pokedexDarkRed],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)

                // Center text
                VStack(spacing: 2) {
                    Text("\(discoveredCount)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text("of \(totalCount)")
                        .font(.dataReadout(size: 12))
                        .foregroundStyle(Color.screenGlow.opacity(0.6))
                }
            }

            PixelText(
                "COLLECTION PROGRESS",
                size: 12,
                color: .screenGlow.opacity(0.7),
                style: .readout
            )

            Text("\(Int(progress * 100))% Complete")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.screenGlow)
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("BY CATEGORY")

            ForEach(FishCategory.allCases) { category in
                let fishInCategory = allFish.filter { $0.category == category }
                let discoveredInCategory = fishInCategory.filter { discoveredFishIds.contains($0.id) }

                categoryBar(
                    label: category.rawValue,
                    icon: category.iconName,
                    discovered: discoveredInCategory.count,
                    total: fishInCategory.count,
                    color: category.swiftUIColor
                )
            }
        }
    }

    private func categoryBar(label: String, icon: String, discovered: Int, total: Int, color: Color) -> some View {
        let pct = total > 0 ? Double(discovered) / Double(total) : 0

        return HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.screenBackground.opacity(0.5))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.7))
                        .frame(width: geometry.size.width * pct)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: pct)
                }
            }
            .frame(height: 6)

            Text("\(discovered)/\(total)")
                .font(.dataReadout(size: 10))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 30, alignment: .trailing)
        }
    }

    // MARK: - Rarity Section

    private var raritySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("BY RARITY")

            ForEach(RarityTier.allCases) { tier in
                let fishInTier = allFish.filter { $0.rarityTier == tier }
                let discoveredInTier = fishInTier.filter { discoveredFishIds.contains($0.id) }
                let pct = fishInTier.isEmpty ? 0 : Double(discoveredInTier.count) / Double(fishInTier.count)

                HStack(spacing: 10) {
                    Circle()
                        .fill(tier.swiftUIColor)
                        .frame(width: 8, height: 8)

                    Text(tier.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(tier.swiftUIColor)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.screenBackground.opacity(0.5))

                            RoundedRectangle(cornerRadius: 3)
                                .fill(tier.swiftUIColor.opacity(0.7))
                                .frame(width: geometry.size.width * pct)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: pct)
                        }
                    }
                    .frame(height: 6)

                    Text("\(discoveredInTier.count)/\(fishInTier.count)")
                        .font(.dataReadout(size: 10))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
    }

    // MARK: - Family Section

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("BY FAMILY")

            FamilyProgressView(discoveredFishIds: discoveredFishIds)
        }
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("ACHIEVEMENTS")

            ForEach(achievements, id: \.title) { achievement in
                achievementRow(achievement)
            }
        }
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.rarityLegendary.opacity(0.2) : Color.screenBackground.opacity(0.3))
                    .frame(width: 36, height: 36)

                Image(systemName: achievement.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        achievement.isUnlocked
                            ? Color.rarityLegendary
                            : Color.metalDark.opacity(0.4)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(
                        achievement.isUnlocked ? .white : .white.opacity(0.4)
                    )

                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.rarityLegendary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    achievement.isUnlocked
                        ? Color.rarityLegendary.opacity(0.06)
                        : Color.screenBackground.opacity(0.3)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    achievement.isUnlocked
                        ? Color.rarityLegendary.opacity(0.2)
                        : Color.metalDark.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Achievement Data

    private var achievements: [Achievement] {
        [
            Achievement(
                title: "First Catch",
                description: "Log your first fish",
                icon: "1.circle.fill",
                isUnlocked: discoveredCount >= 1
            ),
            Achievement(
                title: "Pike Master",
                description: "Catch a Northern Pike",
                icon: "bolt.fill",
                isUnlocked: discoveredFishIds.contains(10)
            ),
            Achievement(
                title: "Deep Diver",
                description: "Discover a sculpin",
                icon: "arrow.down.circle.fill",
                isUnlocked: discoveredFishIds.contains(50) || discoveredFishIds.contains(51) || discoveredFishIds.contains(52)
            ),
            Achievement(
                title: "Living Fossil",
                description: "Discover the Lake Sturgeon",
                icon: "fossil.shell.fill",
                isUnlocked: discoveredFishIds.contains(2)
            ),
            Achievement(
                title: "Invasive Hunter",
                description: "Discover all invasive species",
                icon: "shield.fill",
                isUnlocked: {
                    let invasiveIds = Set(allFish.filter { $0.category == .invasive }.map(\.id))
                    return !invasiveIds.isEmpty && invasiveIds.isSubset(of: discoveredFishIds)
                }()
            ),
            Achievement(
                title: "Saskatchewan Angler",
                description: "Discover 50% of all fish",
                icon: "star.fill",
                isUnlocked: progress >= 0.5
            ),
            Achievement(
                title: "Pokedex Complete",
                description: "Discover all \(totalCount) species",
                icon: "crown.fill",
                isUnlocked: discoveredCount == totalCount
            ),
        ]
    }

    // MARK: - Helpers

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

    private func loadDiscoveries() async {
        let catchService = CatchService(modelContainer: modelContext.container)
        do {
            discoveredFishIds = try await catchService.discoveredFishIds()
        } catch {
            // Silently fail — show 0 progress
        }
        isLoading = false
    }
}

// MARK: - Achievement Model

private struct Achievement {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}

// MARK: - Preview

#Preview("Collection Stats") {
    CollectionStatsView()
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
