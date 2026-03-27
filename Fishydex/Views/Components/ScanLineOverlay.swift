import SwiftUI

/// A CRT scan-line effect overlay.
///
/// Usage:
/// ```swift
/// someView.overlay(ScanLineOverlay())
/// ```
///
/// The overlay draws semi-transparent horizontal lines across the view and
/// slowly scrolls them downward to simulate a cathode-ray tube monitor.
struct ScanLineOverlay: View {
    /// Spacing between each scan line (points).
    var lineSpacing: CGFloat = 4

    /// Opacity of the scan lines (0–1).
    var lineOpacity: Double = 0.08

    /// Whether the lines should animate (slow scroll).
    var animated: Bool = true

    /// Speed of the scroll animation in seconds per full cycle.
    var scrollDuration: Double = 8.0

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            // Draw a pattern that is 2x the height so we can scroll it seamlessly.
            let patternHeight = geometry.size.height + lineSpacing
            Canvas { context, size in
                var y: CGFloat = -lineSpacing + (offset.truncatingRemainder(dividingBy: lineSpacing))
                while y < size.height + lineSpacing {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                    context.fill(Path(rect), with: .color(.black))
                    y += lineSpacing
                }
            }
            .opacity(lineOpacity)
            .allowsHitTesting(false)
            .onAppear {
                guard animated else { return }
                withAnimation(
                    .linear(duration: scrollDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = patternHeight
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Flicker Variant

/// A more pronounced CRT effect that adds a subtle brightness flicker on top of scan lines.
struct CRTOverlay: View {
    @State private var flickerOpacity: Double = 0.03

    var body: some View {
        ZStack {
            ScanLineOverlay()

            // Subtle brightness flicker
            Color.white
                .opacity(flickerOpacity)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.15)
                        .repeatForever(autoreverses: true)
                    ) {
                        flickerOpacity = 0.01
                    }
                }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview("Scan Lines on Dark Background") {
    ZStack {
        Color.screenBackground
            .ignoresSafeArea()

        VStack(spacing: 16) {
            Text("SCANNING...")
                .font(.dataReadout(size: 18))
                .foregroundStyle(Color.screenGlow)

            Text("#034 — Northern Pike")
                .font(.pixelFont(size: 16))
                .foregroundStyle(Color.screenGlow)
        }
    }
    .overlay(ScanLineOverlay())
}
