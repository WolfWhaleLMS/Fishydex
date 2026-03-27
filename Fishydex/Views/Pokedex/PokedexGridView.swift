import SwiftUI

/// The main Pokedex grid screen showing all 84 Saskatchewan fish species.
///
/// Features a search bar, category filter chips, a 3-column LazyVGrid of
/// fish entries (discovered or silhouetted), and a progress bar at the bottom.
struct PokedexGridView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PokedexViewModel?

    var body: some View {
        NavigationStack {
            PokedexShellView {
                if let viewModel {
                    gridContent(viewModel: viewModel)
                } else {
                    ProgressView()
                        .tint(Color.screenGlow)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if viewModel == nil {
                let service = CatchService(modelContainer: modelContext.container)
                let vm = PokedexViewModel(catchService: service)
                viewModel = vm
                await vm.loadDiscoveries()
            }
        }
    }

    // MARK: - Grid Content

    @ViewBuilder
    private func gridContent(viewModel: PokedexViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar
            PokedexSearchBar(text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ))
            .padding(.horizontal, PokedexLayout.screenPadding)
            .padding(.top, 12)

            // Filter chips
            filterChips(viewModel: viewModel)
                .padding(.top, 10)

            // Fish grid
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: PokedexLayout.gridSpacing),
                        count: PokedexLayout.gridColumns
                    ),
                    spacing: PokedexLayout.gridSpacing
                ) {
                    ForEach(viewModel.filteredFish) { fish in
                        NavigationLink(value: fish) {
                            PokedexEntryCell(
                                fish: fish,
                                isDiscovered: viewModel.discoveredFishIds.contains(fish.id)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PokedexLayout.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .refreshable {
                await viewModel.refresh()
            }

            // Progress bar
            PokedexProgressBar(
                discovered: viewModel.discoveredCount,
                total: viewModel.allFish.count
            )
            .padding(.horizontal, PokedexLayout.screenPadding)
            .padding(.vertical, 10)
        }
        .navigationDestination(for: Fish.self) { fish in
            FishDetailView(
                fish: fish,
                isDiscovered: viewModel.discoveredFishIds.contains(fish.id)
            )
        }
    }

    // MARK: - Filter Chips

    private func filterChips(viewModel: PokedexViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All
                filterChip("All", isSelected: viewModel.selectedCategory == nil && !viewModel.showCaughtOnly && !viewModel.showUncaughtOnly) {
                    viewModel.selectedCategory = nil
                    viewModel.showCaughtOnly = false
                    viewModel.showUncaughtOnly = false
                }

                // Category chips
                ForEach(FishCategory.allCases) { category in
                    filterChip(category.rawValue, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = (viewModel.selectedCategory == category) ? nil : category
                        viewModel.showCaughtOnly = false
                        viewModel.showUncaughtOnly = false
                    }
                }

                // Caught / Uncaught
                filterChip("Caught", isSelected: viewModel.showCaughtOnly) {
                    viewModel.showCaughtOnly.toggle()
                    viewModel.showUncaughtOnly = false
                    viewModel.selectedCategory = nil
                }

                filterChip("Uncaught", isSelected: viewModel.showUncaughtOnly) {
                    viewModel.showUncaughtOnly.toggle()
                    viewModel.showCaughtOnly = false
                    viewModel.selectedCategory = nil
                }
            }
            .padding(.horizontal, PokedexLayout.screenPadding)
        }
    }

    private func filterChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticsService.buttonTap()
            action()
        } label: {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.screenGlow.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.pokedexRed : Color.screenBackground.opacity(0.5))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.pokedexRed.opacity(0.8) : Color.screenGlow.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview

#Preview("Pokedex Grid") {
    PokedexGridView()
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
