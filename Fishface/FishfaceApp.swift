import SwiftUI
import SwiftData

// MARK: - FishfaceApp

/// Main entry point for Fishface — a Pokedex for every fish in Saskatchewan.
///
/// Sets up the SwiftData model container for `CatchRecord` and `DiscoveryState`
/// persistence, then hands off to the root `ContentView`.
@main
struct FishfaceApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self])
    }
}

