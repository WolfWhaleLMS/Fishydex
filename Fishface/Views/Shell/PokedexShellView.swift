import SwiftUI

/// The red Pokedex outer frame that wraps all screen content.
///
/// Provides the iconic red shell with metallic silver border, decorative indicator
/// lights (blue lens, red/yellow/green dots), a hinge line, and a dark CRT screen
/// area with scan-line overlay.
///
/// Usage:
/// ```swift
/// PokedexShellView {
///     PokedexGridView()
/// }
/// ```
struct PokedexShellView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            // Full-screen red shell background
            Color.pokedexRed
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Indicator Row
                topIndicatorRow
                    .padding(.horizontal, PokedexLayout.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                // MARK: - Hinge Line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .metalDark.opacity(0.6),
                                .metalSilver,
                                .metalDark.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .padding(.horizontal, 4)

                // MARK: - Screen Area
                ZStack {
                    // Dark CRT background
                    RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                        .fill(Color.screenBackground)

                    // Content
                    content()

                    // CRT scan line overlay
                    RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                        .fill(.clear)
                        .overlay(
                            ScanLineOverlay(lineOpacity: 0.05)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: PokedexLayout.cardCornerRadius)
                                )
                        )
                        .allowsHitTesting(false)
                }
                .metallicBorder(
                    cornerRadius: PokedexLayout.cardCornerRadius,
                    lineWidth: PokedexLayout.bezelWidth
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Top Indicator Row

    /// The decorative circles at the top of the Pokedex: a large blue lens
    /// followed by small red, yellow, and green indicator lights.
    private var topIndicatorRow: some View {
        HStack(spacing: 10) {
            // Large blue lens
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.7, blue: 1.0),
                                Color.pokedexBlue,
                                Color(red: 0.1, green: 0.3, blue: 0.7)
                            ],
                            center: .init(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)

                // Highlight spot
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .offset(x: -6, y: -6)

                // Silver ring
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.metalSilver, .white.opacity(0.7), .metalDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 36, height: 36)
            }
            .shadow(color: .pokedexBlue.opacity(0.6), radius: 6)

            // Small indicator lights
            indicatorLight(color: Color(red: 0.9, green: 0.2, blue: 0.2))
            indicatorLight(color: Color(red: 0.95, green: 0.85, blue: 0.1))
            indicatorLight(color: Color(red: 0.2, green: 0.85, blue: 0.3))

            Spacer()
        }
    }

    /// A small circular indicator light with a subtle glow.
    private func indicatorLight(color: Color) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.9), color.opacity(0.5)],
                        center: .init(x: 0.4, y: 0.4),
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 12, height: 12)

            Circle()
                .fill(.white.opacity(0.4))
                .frame(width: 4, height: 4)
                .offset(x: -1.5, y: -1.5)

            Circle()
                .strokeBorder(color.opacity(0.6), lineWidth: 1)
                .frame(width: 12, height: 12)
        }
        .shadow(color: color.opacity(0.4), radius: 3)
    }
}

// MARK: - Preview

#Preview("Pokedex Shell") {
    PokedexShellView {
        VStack {
            Spacer()
            Text("FISHFACE")
                .font(.pixelFont(size: 24))
                .foregroundStyle(Color.screenGlow)
            Text("60 species to discover")
                .font(.dataReadout(size: 14))
                .foregroundStyle(Color.screenGlow.opacity(0.7))
            Spacer()
        }
    }
}
