import SwiftUI

/// Habitat information section for the fish detail view.
///
/// Displays a map pin icon, a "Where to Find" header, and the fish's
/// habitat description text.
struct FishHabitatView: View {
    let habitat: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.pokedexBlue)

                Text("WHERE TO FIND")
                    .font(.pixelFont(size: 12))
                    .foregroundStyle(Color.screenGlow.opacity(0.8))
            }

            // Habitat description
            Text(habitat)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(Color.pokedexBlue.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .strokeBorder(Color.pokedexBlue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Fish Habitat") {
    FishHabitatView(
        habitat: "Saskatchewan-Nelson River drainage. Found in clear streams and rivers with sandy or silty substrates during larval stage; adults parasitize fish in larger rivers and lakes."
    )
    .padding()
    .background(Color.screenBackground)
}
