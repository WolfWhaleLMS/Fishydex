import SwiftUI
import SwiftData

/// Timeline of all catches across all species, sorted newest first.
///
/// Each row shows the fish image, name, date, and location.
/// Tapping a row navigates to the fish detail. Shows an empty state
/// when no catches exist.
struct CatchHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CatchRecord.caughtDate, order: .reverse) private var catches: [CatchRecord]

    var body: some View {
        NavigationStack {
            PokedexShellView {
                if catches.isEmpty {
                    emptyState
                } else {
                    catchList
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Int.self) { fishId in
                if let navigatedFish = FishDatabase.fish(byId: fishId) {
                    FishDetailView(fish: navigatedFish, isDiscovered: true)
                }
            }
        }
    }

    // MARK: - Catch List

    private var catchList: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                PixelText("CATCH LOG", size: 14, color: .screenGlow)

                Spacer()

                PixelText(
                    "\(catches.count) catches",
                    size: 11,
                    color: .screenGlow.opacity(0.6),
                    style: .readout
                )
            }
            .padding(.horizontal, PokedexLayout.screenPadding)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(catches, id: \.id) { record in
                        catchRow(record)
                    }
                }
                .padding(.horizontal, PokedexLayout.screenPadding)
                .padding(.bottom, 16)
            }
        }
    }

    private func catchRow(_ record: CatchRecord) -> some View {
        let fish = FishDatabase.fish(byId: record.fishId)

        return NavigationLink(value: record.fishId) {
            HStack(spacing: 12) {
                // Fish image
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.screenBackground)

                    if let fish {
                        Image(fish.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    } else {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.metalDark.opacity(0.4))
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.metalSilver.opacity(0.2), lineWidth: 1)
                )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(fish?.commonName ?? "Unknown Fish")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Text(record.caughtDate.catchDateString)
                            .font(.dataReadout(size: 11))
                            .foregroundStyle(.white.opacity(0.6))

                        if let location = record.locationName, !location.isEmpty {
                            Text("--")
                                .font(.dataReadout(size: 11))
                                .foregroundStyle(.white.opacity(0.3))

                            Text(location)
                                .font(.dataReadout(size: 11))
                                .foregroundStyle(.white.opacity(0.5))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.screenGlow.opacity(0.3))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.2).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                    .strokeBorder(Color.metalSilver.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "fish.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.metalDark.opacity(0.3))

            Text("No catches yet!")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            Text("Use the Scanner to start\nyour collection.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Catch History - Empty") {
    CatchHistoryView()
        .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
