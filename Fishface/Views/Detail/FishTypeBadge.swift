import SwiftUI

/// A larger category badge for the fish detail view, including a brief description
/// of what the category means.
struct FishTypeBadge: View {
    let category: FishCategory

    var body: some View {
        HStack(spacing: 10) {
            // Category icon in a circle
            ZStack {
                Circle()
                    .fill(category.swiftUIColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: category.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category.swiftUIColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)

                Text(categoryDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .fill(category.swiftUIColor.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                .strokeBorder(category.swiftUIColor.opacity(0.3), lineWidth: 1)
        )
    }

    /// Brief human-readable description of the fish category.
    private var categoryDescription: String {
        switch category {
        case .sportFish:
            return "Prized by anglers for recreational fishing"
        case .forageFish:
            return "Small species that form the food chain base"
        case .coarseFish:
            return "Bottom-feeding and rough fish species"
        case .invasive:
            return "Non-native species threatening local ecosystems"
        case .exotic:
            return "Introduced species, not naturally occurring"
        case .hybrid:
            return "Cross between two parent species"
        }
    }
}

// MARK: - Preview

#Preview("Fish Type Badges") {
    VStack(spacing: 12) {
        ForEach(FishCategory.allCases) { category in
            FishTypeBadge(category: category)
        }
    }
    .padding()
    .background(Color.screenBackground)
}
