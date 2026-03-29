import SwiftUI

/// Main content view with tab navigation and Pokedex hinge opening animation.
///
/// Houses four tabs: Pokedex grid, Scanner, Catches, and Stats.
/// On first launch, wraps everything in the hinge-open animation.
struct ContentView: View {
    @State private var selectedTab: Tab = .pokedex

    enum Tab: Hashable {
        case pokedex
        case map
        case scanner
        case catches
        case stats
    }

    var body: some View {
        PokedexHingeView {
            TabView(selection: $selectedTab) {
                PokedexGridView()
                    .tabItem {
                        Label("Pokedex", systemImage: "book.closed.fill")
                    }
                    .tag(Tab.pokedex)

                FishMapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(Tab.map)

                ScannerPlaceholderView()
                    .tabItem {
                        Label("Scanner", systemImage: "camera.viewfinder")
                    }
                    .tag(Tab.scanner)

                CatchHistoryView()
                    .tabItem {
                        Label("Catches", systemImage: "fish.fill")
                    }
                    .tag(Tab.catches)

                CollectionStatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    .tag(Tab.stats)
            }
            .tint(Color.pokedexRed)
            .onAppear {
                configureTabBarAppearance()
            }
        }
        .preferredColorScheme(.dark)
    }

    /// Configures the tab bar with Pokedex-themed dark styling.
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.pokedexDarkRed)

        // Unselected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]

        // Selected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview

#Preview("Fishface") {
    ContentView()
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
