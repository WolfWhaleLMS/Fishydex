import SwiftUI

// MARK: - FishSpeciesPickerView

/// Bottom sheet presented after the user captures a photo.
/// Displays all 84 fish species in a searchable list so the user can identify their catch.
///
/// - Discovered fish show their image and full name.
/// - Undiscovered fish show a silhouette and "???".
struct FishSpeciesPickerView: View {

    /// Set of fish IDs that have been previously discovered.
    var discoveredFishIds: Set<Int>

    /// Callback when the user selects a fish.
    var onSelect: (Int) -> Void

    /// Callback when the user cancels.
    var onCancel: () -> Void

    // MARK: - State

    @State private var searchText: String = ""

    // MARK: - Computed

    private var allFish: [Fish] {
        FishDatabase.allFish
    }

    private var filteredFish: [Fish] {
        guard !searchText.isEmpty else { return allFish }

        let query = searchText.lowercased()
        return allFish.filter { fish in
            fish.commonName.lowercased().contains(query)
                || fish.scientificName.lowercased().contains(query)
                || fish.family.lowercased().contains(query)
                || fish.familyCommonName.lowercased().contains(query)
                || fish.formattedId.lowercased().contains(query)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Fish list
                fishList
            }
            .background(Color.screenBackground)
            .navigationTitle("What did you catch?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticsService.buttonTap()
                        onCancel()
                    }
                    .foregroundStyle(Color.screenGlow)
                }
            }
            .toolbarBackground(Color.screenBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.screenGlow.opacity(0.6))
                .font(.system(size: 14))

            TextField("Search species...", text: $searchText)
                .font(.system(size: 15, design: .monospaced))
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.screenGlow.opacity(0.5))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.screenGlow.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Fish List

    private var fishList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(filteredFish) { fish in
                    fishRow(fish)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Fish Row

    @ViewBuilder
    private func fishRow(_ fish: Fish) -> some View {
        let isDiscovered = discoveredFishIds.contains(fish.id)

        Button {
            HapticsService.catchFeedback()
            onSelect(fish.id)
        } label: {
            HStack(spacing: 12) {
                // Fish image or silhouette
                fishThumbnail(fish, isDiscovered: isDiscovered)

                // Entry number
                Text(fish.formattedId)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.screenGlow.opacity(0.7))
                    .frame(width: 44, alignment: .leading)

                // Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(isDiscovered ? fish.commonName : "???")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if isDiscovered {
                        Text(fish.scientificName)
                            .font(.scientificName(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Category badge
                TypeBadge(category: fish.category, size: .compact)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.screenGlow.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Fish Thumbnail

    @ViewBuilder
    private func fishThumbnail(_ fish: Fish, isDiscovered: Bool) -> some View {
        let imageName = isDiscovered ? fish.imageName : fish.silhouetteImageName

        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        isDiscovered
                            ? fish.rarityTier.swiftUIColor.opacity(0.5)
                            : Color.metalDark.opacity(0.4),
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - Preview

#Preview("Species Picker") {
    FishSpeciesPickerView(
        discoveredFishIds: [1, 2, 5, 10, 15],
        onSelect: { id in print("Selected fish: \(id)") },
        onCancel: { print("Cancelled") }
    )
}
