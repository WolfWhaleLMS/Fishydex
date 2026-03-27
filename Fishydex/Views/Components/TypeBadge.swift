import SwiftUI

/// A colored pill badge that displays a fish category with its icon.
///
/// Usage:
/// ```swift
/// TypeBadge(category: .sportFish)                // Compact (default)
/// TypeBadge(category: .invasive, size: .full)     // Full-size with label
/// ```
struct TypeBadge: View {
    let category: FishCategory
    var size: BadgeSize = .compact

    enum BadgeSize {
        case compact  // Icon + short label, small pill
        case full     // Icon + full label, larger pill
    }

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: category.iconName)
                .font(.system(size: iconSize, weight: .semibold))

            Text(category.rawValue)
                .font(.system(size: textSize, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(category.swiftUIColor.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(category.swiftUIColor.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Sizing

    private var iconSize: CGFloat {
        switch size {
        case .compact: return PokedexLayout.badgeIconSize
        case .full:    return 14
        }
    }

    private var textSize: CGFloat {
        switch size {
        case .compact: return 10
        case .full:    return 13
        }
    }

    private var spacing: CGFloat {
        switch size {
        case .compact: return 4
        case .full:    return 6
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .compact: return 8
        case .full:    return 12
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .compact: return 4
        case .full:    return 6
        }
    }
}

// MARK: - At-Risk Badge

/// A separate badge specifically for conservation / at-risk status.
struct AtRiskBadge: View {
    var label: String = "At Risk"
    var size: TypeBadge.BadgeSize = .compact

    var body: some View {
        let isCompact = size == .compact
        HStack(spacing: isCompact ? 4 : 6) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: isCompact ? 10 : 13, weight: .semibold))

            Text(label)
                .font(.system(size: isCompact ? 10 : 13, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, isCompact ? 8 : 12)
        .padding(.vertical, isCompact ? 4 : 6)
        .background(Color.atRisk.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.atRisk.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Type Badges") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Compact").font(.caption).foregroundStyle(.secondary)
        FlowLayout(spacing: 8) {
            ForEach(FishCategory.allCases) { category in
                TypeBadge(category: category, size: .compact)
            }
            AtRiskBadge()
        }

        Divider()

        Text("Full Size").font(.caption).foregroundStyle(.secondary)
        VStack(alignment: .leading, spacing: 8) {
            ForEach(FishCategory.allCases) { category in
                TypeBadge(category: category, size: .full)
            }
            AtRiskBadge(label: "Species at Risk", size: .full)
        }
    }
    .padding()
    .background(Color.screenBackground)
}

// MARK: - Simple Flow Layout (for preview)

/// A basic horizontal flow layout for wrapping badges.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
