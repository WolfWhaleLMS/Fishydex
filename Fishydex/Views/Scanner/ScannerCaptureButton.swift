import SwiftUI

// MARK: - ScannerCaptureButton

/// A large circular capture button with a metallic outer ring and Pokedex-red inner circle.
/// Pulses with a green glow when the camera is active. Scales down on press with haptic feedback.
struct ScannerCaptureButton: View {

    /// Whether the camera is currently active (controls pulsing glow).
    var isActive: Bool = true

    /// Action fired when the button is pressed.
    let action: () -> Void

    // MARK: - Animation State

    @State private var glowRadius: CGFloat = 0
    @State private var isPressed: Bool = false

    // MARK: - Constants

    private let outerSize: CGFloat = 80
    private let innerSize: CGFloat = 62
    private let centerIconSize: CGFloat = 24

    // MARK: - Body

    var body: some View {
        Button {
            HapticsService.catchFeedback()
            action()
        } label: {
            ZStack {
                // Pulsing glow (behind everything)
                if isActive {
                    Circle()
                        .fill(Color.screenGlow.opacity(0.15))
                        .frame(width: outerSize + glowRadius * 2, height: outerSize + glowRadius * 2)
                        .blur(radius: glowRadius)
                }

                // Outer metallic ring
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.metalSilver, .metalDark, .metalSilver],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: outerSize, height: outerSize)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

                // Inner red circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.pokedexRed, .pokedexDarkRed],
                            center: .center,
                            startRadius: 0,
                            endRadius: innerSize / 2
                        )
                    )
                    .frame(width: innerSize, height: innerSize)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear,
                                        Color.black.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                // Center icon — Pokeball-style horizontal line + circle
                pokeBallDesign
            }
        }
        .buttonStyle(CaptureButtonPressStyle())
        .onAppear {
            guard isActive else { return }
            startGlowAnimation()
        }
        .onChange(of: isActive) { _, active in
            if active {
                startGlowAnimation()
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    glowRadius = 0
                }
            }
        }
    }

    // MARK: - Pokeball Design

    private var pokeBallDesign: some View {
        ZStack {
            // Horizontal divider line
            Rectangle()
                .fill(Color.white.opacity(0.5))
                .frame(width: innerSize * 0.6, height: 2)

            // Center circle (button)
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                )
                .shadow(color: Color.white.opacity(0.3), radius: 2)
        }
    }

    // MARK: - Glow Animation

    private func startGlowAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            glowRadius = 12
        }
    }
}

// MARK: - Press Style

/// Scales the button down on press for a tactile feel.
private struct CaptureButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Capture Button") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            ScannerCaptureButton(isActive: true) {
                print("Captured!")
            }

            ScannerCaptureButton(isActive: false) {
                print("Captured!")
            }
        }
    }
}
