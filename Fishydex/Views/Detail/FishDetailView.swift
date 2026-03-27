import SwiftUI

/// Full Pokedex entry screen for a single fish species.
///
/// If discovered: shows the fish image, name, scientific name, type badges,
/// rarity glow, stats, habitat, fun fact, catch history, and a "Log a Catch" button.
/// If undiscovered: shows a silhouette with a "Catch this fish to unlock!" message.
struct FishDetailView: View {
    let fish: Fish
    let isDiscovered: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: FishDetailViewModel?
    @State private var showRevealAnimation = false

    var body: some View {
        PokedexShellView {
            if isDiscovered {
                discoveredContent
            } else {
                undiscoveredContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticsService.buttonTap()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showCatchSheet ?? false },
            set: { viewModel?.showCatchSheet = $0 }
        )) {
            CatchLogView(fish: fish)
        }
        .fullScreenCover(isPresented: $showRevealAnimation) {
            FishRevealAnimation(fish: fish) {
                showRevealAnimation = false
            }
        }
        .task {
            if viewModel == nil {
                let catchService = CatchService(modelContainer: modelContext.container)
                let locationService = LocationService()
                let vm = FishDetailViewModel(
                    fish: fish,
                    catchService: catchService,
                    locationService: locationService
                )
                viewModel = vm
                await vm.loadData()
            }
        }
    }

    // MARK: - Discovered Content

    private var discoveredContent: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Fish image with Pokedex frame
                    fishImageSection

                    // Name section
                    nameSection

                    // Type badge (large)
                    FishTypeBadge(category: fish.category)

                    // Rarity indicator
                    raritySection

                    // Stats
                    FishStatsView(fish: fish)

                    // Description
                    descriptionSection

                    // Habitat
                    FishHabitatView(habitat: fish.habitat)

                    // Fun fact
                    if let funFact = fish.funFact {
                        funFactSection(funFact)
                    }

                    // Catch history
                    if let viewModel, !viewModel.catches.isEmpty {
                        catchHistorySection(catches: viewModel.catches)
                    }

                    // Spacer for FAB
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, PokedexLayout.screenPadding)
                .padding(.top, 12)
            }

            // Log a Catch FAB
            PokedexButtonCompact(label: "Log Catch", icon: "plus.circle.fill") {
                HapticsService.buttonTap()
                viewModel?.showCatchSheet = true
            }
            .padding(16)
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
        }
    }

    // MARK: - Fish Image Section

    private var fishImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(Color.screenBackground)

            Image(fish.imageName)
                .resizable()
                .scaledToFit()
                .padding(20)

            // Entry number overlay
            VStack {
                HStack {
                    PixelText(fish.formattedId, size: 14, color: .screenGlow)
                        .padding(8)
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(height: 220)
        .metallicBorder(
            cornerRadius: PokedexLayout.cardCornerRadius,
            lineWidth: 3
        )
        .rarityGlow(fish.rarityTier)
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(fish.commonName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text(fish.scientificName)
                .font(.scientificName(size: 16))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Rarity Section

    private var raritySection: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(fish.rarityTier.swiftUIColor)
                .frame(width: 10, height: 10)
                .shadow(color: fish.rarityTier.swiftUIColor.opacity(0.6), radius: 4)

            Text(fish.rarityTier.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(fish.rarityTier.swiftUIColor)

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(Color.screenGlow.opacity(0.4))
                    .frame(width: 3, height: 14)

                Text("DESCRIPTION")
                    .font(.pixelFont(size: 11))
                    .foregroundStyle(Color.screenGlow.opacity(0.8))
            }

            Text(fish.description)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Fun Fact Section

    private func funFactSection(_ fact: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.rarityLegendary)

            VStack(alignment: .leading, spacing: 4) {
                Text("DID YOU KNOW?")
                    .font(.pixelFont(size: 10))
                    .foregroundStyle(Color.rarityLegendary.opacity(0.8))

                Text(fact)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(Color.rarityLegendary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .strokeBorder(Color.rarityLegendary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Catch History Section

    private func catchHistorySection(catches: [CatchRecord]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(Color.screenGlow.opacity(0.4))
                    .frame(width: 3, height: 14)

                Text("CATCH HISTORY")
                    .font(.pixelFont(size: 11))
                    .foregroundStyle(Color.screenGlow.opacity(0.8))

                Spacer()

                Text("\(catches.count) total")
                    .font(.dataReadout(size: 11))
                    .foregroundStyle(Color.screenGlow.opacity(0.5))
            }

            ForEach(catches.prefix(5), id: \.id) { record in
                HStack(spacing: 10) {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.pokedexBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.caughtDate.catchDateString)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))

                        if let location = record.locationName {
                            Text(location)
                                .font(.dataReadout(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }

            if catches.count > 5 {
                Text("+ \(catches.count - 5) more")
                    .font(.dataReadout(size: 11))
                    .foregroundStyle(Color.screenGlow.opacity(0.5))
            }
        }
    }

    // MARK: - Undiscovered Content

    private var undiscoveredContent: some View {
        VStack(spacing: 24) {
            Spacer()

            // Silhouette
            ZStack {
                RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                    .fill(Color.screenBackground)

                Image(systemName: "fish.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .foregroundStyle(Color.metalDark.opacity(0.25))
            }
            .frame(width: 220, height: 220)
            .metallicBorder(cornerRadius: PokedexLayout.cardCornerRadius, lineWidth: 3)

            // Entry number
            PixelText(fish.formattedId, size: 20, color: .screenGlow.opacity(0.5))

            // Mystery name
            Text("???")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))

            // Unlock message
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.metalSilver.opacity(0.5))

                Text("Catch this fish to unlock its entry!")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, PokedexLayout.screenPadding)
    }
}

// MARK: - Preview

#Preview("Fish Detail - Discovered") {
    NavigationStack {
        FishDetailView(
            fish: Fish(
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
                description: "A premier predatory sport fish found throughout Saskatchewan. Northern pike are ambush predators with elongated bodies, flat snouts, and numerous sharp teeth. They prefer weedy bays and slow-moving rivers where they can lurk and strike at prey with explosive speed.",
                habitat: "Lakes, rivers, and reservoirs across Saskatchewan. Prefers shallow, weedy bays for spawning and feeding. Found in nearly every major water body in the province.",
                funFact: "Also called 'jackfish' in Saskatchewan, northern pike can strike prey at speeds up to 10 body lengths per second.",
                isNative: true
            ),
            isDiscovered: true
        )
    }
    .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}

#Preview("Fish Detail - Undiscovered") {
    NavigationStack {
        FishDetailView(
            fish: Fish(
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
            ),
            isDiscovered: false
        )
    }
    .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
