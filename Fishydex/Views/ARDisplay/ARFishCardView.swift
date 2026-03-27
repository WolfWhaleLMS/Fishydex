import SwiftUI

// MARK: - ARFishCardView

/// Full-screen AR experience that places a floating fish info card on a detected surface.
///
/// - Shows the AR camera feed via `ARContainerView`
/// - Displays instructions until a surface is found
/// - Overlays a close button
struct ARFishCardView: View {

    let fish: Fish

    /// Dismiss action (e.g., presentation mode or binding toggle).
    var onDismiss: () -> Void

    // MARK: - State

    @State private var cardPlaced: Bool = false
    @State private var showInstructions: Bool = true
    @State private var instructionOpacity: Double = 1.0

    private let crtGreen = Color(red: 0, green: 1, blue: 0.255) // #00ff41

    // MARK: - Body

    var body: some View {
        ZStack {
            // Full-screen AR view
            ARContainerView(
                fish: fish,
                onCardPlaced: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        cardPlaced = true
                    }
                    // Fade out instructions after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.8)) {
                            showInstructions = false
                        }
                    }
                }
            )
            .ignoresSafeArea()

            // Instruction overlay
            if showInstructions {
                instructionOverlay
            }

            // Top overlay bar with close button and fish info
            VStack {
                topBar
                Spacer()
            }

            // Scan lines for CRT effect
            ScanLineOverlay(lineSpacing: 4, lineOpacity: 0.03)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .statusBarHidden()
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Fish identification label
            VStack(alignment: .leading, spacing: 2) {
                Text(fish.formattedId)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(crtGreen)

                Text(fish.commonName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Spacer()

            // Close button
            Button {
                HapticsService.buttonTap()
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.black.opacity(0.5))
            }
            .shadow(color: .black.opacity(0.3), radius: 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Instruction Overlay

    private var instructionOverlay: some View {
        VStack(spacing: 16) {
            Spacer()

            if !cardPlaced {
                // Searching for surface
                VStack(spacing: 12) {
                    // Animated scanning indicator
                    ZStack {
                        Circle()
                            .strokeBorder(crtGreen.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 60)

                        Image(systemName: "viewfinder")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(crtGreen)
                            .shadow(color: crtGreen.opacity(0.5), radius: 4)
                    }
                    .pulse(minScale: 0.92, duration: 1.2)

                    Text("Point at a flat surface to place the card")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(crtGreen)
                        .shadow(color: crtGreen.opacity(0.4), radius: 3)
                        .multilineTextAlignment(.center)

                    Text("Move your device slowly to scan the area")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                // Card placed confirmation
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(crtGreen)

                    Text("Card placed!")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(crtGreen)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()
                .frame(height: 100)
        }
        .opacity(instructionOpacity)
    }
}

// MARK: - Preview

#Preview("AR Fish Card") {
    // AR requires a physical device. Placeholder preview.
    ZStack {
        Color.screenBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            Image(systemName: "arkit")
                .font(.system(size: 48))
                .foregroundStyle(Color.screenGlow.opacity(0.5))

            Text("AR Fish Card — Run on Device")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
