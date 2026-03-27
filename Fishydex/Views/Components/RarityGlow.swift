import SwiftUI

// MARK: - Rarity Glow Modifier

/// Applies a glow effect to any view based on rarity tier.
/// Uses the existing `RarityTier` enum from Models/RarityTier.swift.
///
/// Usage:
/// ```swift
/// fishImage
///     .rarityGlow(.legendary)
/// ```
struct RarityGlowModifier: ViewModifier {
    let tier: RarityTier

    @State private var animating = false

    func body(content: Content) -> some View {
        switch tier {
        case .common:
            content
        case .uncommon:
            content
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.5 : 0.15),
                    radius: animating ? 10 : 4
                )
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animating
                )
                .onAppear { animating = true }
        case .rare:
            content
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.6 : 0.1),
                    radius: animating ? 14 : 4
                )
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.3 : 0.05),
                    radius: animating ? 24 : 8
                )
                .hueRotation(.degrees(animating ? 15 : -15))
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: animating
                )
                .onAppear { animating = true }
        case .legendary:
            content
                .overlay(
                    LegendaryGlowEffect(animating: $animating)
                        .allowsHitTesting(false)
                )
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.7 : 0.2),
                    radius: animating ? 16 : 6
                )
                .shadow(
                    color: tier.swiftUIColor.opacity(animating ? 0.4 : 0.05),
                    radius: animating ? 30 : 10
                )
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animating
                )
                .onAppear { animating = true }
        }
    }
}

// MARK: - Legendary Particle Glow

/// A dedicated overlay for legendary-tier items that simulates gold particles radiating outward.
private struct LegendaryGlowEffect: View {
    @Binding var animating: Bool

    /// Number of particle "dots" in the ring.
    private let particleCount = 12

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let baseRadius = min(geometry.size.width, geometry.size.height) / 2

            ZStack {
                ForEach(0..<particleCount, id: \.self) { index in
                    let angle = Angle.degrees(Double(index) / Double(particleCount) * 360)
                    let particleRadius = animating
                        ? baseRadius * 1.15
                        : baseRadius * 0.85

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.rarityLegendary.opacity(animating ? 0.8 : 0.2),
                                    Color.rarityLegendary.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 6
                            )
                        )
                        .frame(width: 10, height: 10)
                        .position(
                            x: center.x + particleRadius * CGFloat(cos(angle.radians)),
                            y: center.y + particleRadius * CGFloat(sin(angle.radians))
                        )
                        .opacity(animating ? 1.0 : 0.3)
                }
            }
            .animation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...0.3)),
                value: animating
            )
            .onAppear { animating = true }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a glow effect matching the given rarity tier.
    func rarityGlow(_ tier: RarityTier) -> some View {
        modifier(RarityGlowModifier(tier: tier))
    }
}

// MARK: - Preview

#Preview("Rarity Glow Effects") {
    ScrollView {
        VStack(spacing: 40) {
            ForEach(RarityTier.allCases) { tier in
                VStack(spacing: 8) {
                    Text(tier.displayName)
                        .font(.caption)
                        .foregroundStyle(tier.swiftUIColor)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.screenBackground)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "fish.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(tier.swiftUIColor)
                        )
                        .rarityGlow(tier)
                }
            }
        }
        .padding(40)
    }
    .background(Color.screenBackground)
}
