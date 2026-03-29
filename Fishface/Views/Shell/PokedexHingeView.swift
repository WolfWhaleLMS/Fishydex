import SwiftUI

/// The Pokedex opening animation shown on app launch.
///
/// The device starts as a "closed" red Pokedex shell. After a brief pause,
/// the top half flips open with a hinge effect to reveal the content underneath.
/// This animation only plays once per app launch.
struct PokedexHingeView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State private var isOpen = false
    @State private var showContent = false
    @State private var hasAnimated = false

    /// Duration of the hinge-open animation in seconds.
    private let hingeDuration: Double = 0.8

    /// Delay before the hinge starts opening.
    private let openDelay: Double = 0.6

    var body: some View {
        ZStack {
            // Background: always the red shell color
            Color.pokedexRed
                .ignoresSafeArea()

            if showContent {
                // Revealed content fades in after the hinge opens
                content()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            if !hasAnimated {
                // Closed Pokedex lid that flips open
                closedLid
                    .rotation3DEffect(
                        .degrees(isOpen ? -90 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.5
                    )
                    .opacity(isOpen ? 0 : 1)
            }
        }
        .onAppear {
            guard !hasAnimated else { return }

            // Phase 1: Brief pause to show the closed Pokedex
            DispatchQueue.main.asyncAfter(deadline: .now() + openDelay) {
                // Phase 2: Hinge open
                withAnimation(.easeInOut(duration: hingeDuration)) {
                    isOpen = true
                }

                // Phase 3: Show content partway through the hinge animation
                DispatchQueue.main.asyncAfter(deadline: .now() + hingeDuration * 0.5) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        showContent = true
                    }
                }

                // Phase 4: Clean up — remove the lid overlay entirely
                DispatchQueue.main.asyncAfter(deadline: .now() + hingeDuration + 0.2) {
                    hasAnimated = true
                }
            }
        }
    }

    // MARK: - Closed Lid

    /// The "closed" Pokedex top half — a red panel with the blue lens and indicator lights.
    private var closedLid: some View {
        ZStack {
            // Red shell
            RoundedRectangle(cornerRadius: PokedexLayout.shellCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.pokedexRed, .pokedexDarkRed],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            // Metallic border
            RoundedRectangle(cornerRadius: PokedexLayout.shellCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [.metalSilver, .metalDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Indicator lights row (centered)
                HStack(spacing: 14) {
                    // Large blue lens
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 1.0),
                                        .pokedexBlue,
                                        Color(red: 0.1, green: 0.3, blue: 0.7)
                                    ],
                                    center: .init(x: 0.35, y: 0.35),
                                    startRadius: 0,
                                    endRadius: 24
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: .pokedexBlue.opacity(0.7), radius: 10)

                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: 14, height: 14)
                            .offset(x: -8, y: -8)

                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.metalSilver, .white.opacity(0.6), .metalDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 48, height: 48)
                    }

                    smallLight(Color(red: 0.9, green: 0.2, blue: 0.2))
                    smallLight(Color(red: 0.95, green: 0.85, blue: 0.1))
                    smallLight(Color(red: 0.2, green: 0.85, blue: 0.3))
                }

                // Diagonal hinge line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.metalDark.opacity(0.4), .metalSilver, .metalDark.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                    .rotationEffect(.degrees(-2))
            }
        }
        .pokedexShadow()
    }

    private func smallLight(_ color: Color) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.9), color.opacity(0.4)],
                    center: .init(x: 0.4, y: 0.4),
                    startRadius: 0,
                    endRadius: 8
                )
            )
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .fill(.white.opacity(0.35))
                    .frame(width: 5, height: 5)
                    .offset(x: -2, y: -2)
            )
            .shadow(color: color.opacity(0.5), radius: 4)
    }
}

// MARK: - Preview

#Preview("Hinge Animation") {
    PokedexHingeView {
        PokedexShellView {
            VStack {
                Spacer()
                Text("FISHFACE")
                    .font(.pixelFont(size: 24))
                    .foregroundStyle(Color.screenGlow)
                Spacer()
            }
        }
    }
}
