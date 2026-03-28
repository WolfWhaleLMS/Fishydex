import SwiftUI
import SwiftData

// MARK: - FishydexApp

/// Main entry point for Fishface — a Pokedex for every fish in Saskatchewan.
///
/// Sets up the SwiftData model container for `CatchRecord` and `DiscoveryState`
/// persistence, then hands off to the root `ContentView`.
@main
struct FishydexApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self])
    }
}

