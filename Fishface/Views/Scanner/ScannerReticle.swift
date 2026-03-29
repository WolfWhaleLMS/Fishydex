import SwiftUI

// MARK: - ScannerReticle

/// Targeting reticle with four animated corner brackets that rotate, pulse, and breathe.
/// Green (#00ff41) CRT aesthetic.
struct ScannerReticle: View {

    /// Whether the camera is actively scanning (brackets expand/contract).
    var isScanning: Bool = true

    // MARK: - Animation State

    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    @State private var bracketScale: CGFloat = 1.0

    // MARK: - Constants

    private let crtGreen = Color(red: 0, green: 1, blue: 0.255) // #00ff41
    private let bracketLength: CGFloat = 40
    private let bracketThickness: CGFloat = 3
    private let squareSize: CGFloat = 180

    // MARK: - Body

    var body: some View {
        ZStack {
            // Four corner brackets forming a square
            cornersGroup
                .frame(width: squareSize, height: squareSize)
                .scaleEffect(bracketScale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
        }
        .onAppear {
            startRotation()
            startPulse()
            if isScanning {
                startBreathing()
            }
        }
        .onChange(of: isScanning) { _, scanning in
            if scanning {
                startBreathing()
            } else {
                stopBreathing()
            }
        }
    }

    // MARK: - Corner Brackets

    private var cornersGroup: some View {
        ZStack {
            // Top-left corner
            cornerBracket(rotation: 0)
                .position(x: 0, y: 0)

            // Top-right corner
            cornerBracket(rotation: 90)
                .position(x: squareSize, y: 0)

            // Bottom-right corner
            cornerBracket(rotation: 180)
                .position(x: squareSize, y: squareSize)

            // Bottom-left corner
            cornerBracket(rotation: 270)
                .position(x: 0, y: squareSize)
        }
    }

    /// A single L-shaped corner bracket.
    private func cornerBracket(rotation angle: Double) -> some View {
        Canvas { context, size in
            // Horizontal arm
            let hRect = CGRect(
                x: 0,
                y: 0,
                width: bracketLength,
                height: bracketThickness
            )
            context.fill(Path(hRect), with: .color(crtGreen))

            // Vertical arm
            let vRect = CGRect(
                x: 0,
                y: 0,
                width: bracketThickness,
                height: bracketLength
            )
            context.fill(Path(vRect), with: .color(crtGreen))
        }
        .frame(width: bracketLength, height: bracketLength)
        .rotationEffect(.degrees(angle))
        .shadow(color: crtGreen.opacity(0.6), radius: 4)
        .shadow(color: crtGreen.opacity(0.3), radius: 8)
    }

    // MARK: - Animations

    /// Slow rotation: 0.5 RPM = 120 seconds per full revolution.
    private func startRotation() {
        withAnimation(
            .linear(duration: 120)
            .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }

    /// Pulsing opacity between 0.5 and 1.0.
    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            opacity = 0.5
        }
    }

    /// When scanning: brackets slowly expand and contract (1.0 to 1.08).
    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
        ) {
            bracketScale = 1.08
        }
    }

    /// Stop the breathing animation and reset scale.
    private func stopBreathing() {
        withAnimation(.easeOut(duration: 0.5)) {
            bracketScale = 1.0
        }
    }
}

// MARK: - Crosshair

/// A subtle center crosshair rendered as two thin intersecting lines.
struct ScannerCrosshair: View {

    private let crtGreen = Color(red: 0, green: 1, blue: 0.255)
    private let lineLength: CGFloat = 24
    private let lineThickness: CGFloat = 1

    var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(crtGreen.opacity(0.4))
                .frame(width: lineLength, height: lineThickness)

            // Vertical line
            Rectangle()
                .fill(crtGreen.opacity(0.4))
                .frame(width: lineThickness, height: lineLength)

            // Center dot
            Circle()
                .fill(crtGreen.opacity(0.6))
                .frame(width: 4, height: 4)
        }
        .shadow(color: crtGreen.opacity(0.3), radius: 2)
    }
}

// MARK: - Preview

#Preview("Scanner Reticle") {
    ZStack {
        Color.black.ignoresSafeArea()

        ScannerCrosshair()

        ScannerReticle(isScanning: true)
    }
}
