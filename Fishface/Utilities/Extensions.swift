import SwiftUI

// MARK: - Date Formatting

extension Date {

    /// Short date string for catch records: "Mar 27, 2026"
    var catchDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Full date+time string for detail views: "Mar 27, 2026 at 3:42 PM"
    var catchDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Relative time string: "2 hours ago", "Yesterday", etc.
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}

// MARK: - String Helpers

extension String {

    /// Converts a fish ID (1–60) to a zero-padded Pokedex entry number: "#001"
    static func entryNumber(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
}

extension Int {

    /// Returns this integer as a zero-padded Pokedex entry string: "#034"
    var entryNumber: String {
        String.entryNumber(self)
    }
}

// MARK: - View Modifiers

/// Applies a green CRT glow effect to any view.
struct CRTGlowModifier: ViewModifier {
    var color: Color = .screenGlow
    var radius: CGFloat = 6
    var intensity: Double = 0.6

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity), radius: radius)
            .shadow(color: color.opacity(intensity * 0.5), radius: radius * 2)
    }
}

/// Adds a pulsing animation to a view (scale-based).
struct PulseModifier: ViewModifier {
    var minScale: CGFloat = 0.97
    var duration: Double = 1.5

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.0 : minScale)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

/// Adds a metallic border (Pokedex bezel look).
struct MetallicBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = PokedexLayout.cardCornerRadius
    var lineWidth: CGFloat = PokedexLayout.bezelWidth

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.metalSilver, .metalDark, .metalSilver],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

/// Renders horizontal scan lines across a view (CRT monitor look).
struct ScanLineModifier: ViewModifier {
    var lineSpacing: CGFloat = 4
    var opacity: Double = 0.08

    func body(content: Content) -> some View {
        content
            .overlay(
                ScanLinePattern(spacing: lineSpacing)
                    .opacity(opacity)
                    .allowsHitTesting(false)
            )
    }
}

/// Shape that draws repeating horizontal lines.
private struct ScanLinePattern: Shape {
    var spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var y: CGFloat = 0
        while y < rect.height {
            path.addRect(CGRect(x: 0, y: y, width: rect.width, height: 1))
            y += spacing
        }
        return path
    }
}

// MARK: - View Extension Convenience

extension View {

    /// Applies a CRT green glow effect.
    func crtGlow(color: Color = .screenGlow, radius: CGFloat = 6, intensity: Double = 0.6) -> some View {
        modifier(CRTGlowModifier(color: color, radius: radius, intensity: intensity))
    }

    /// Adds a gentle pulse animation.
    func pulse(minScale: CGFloat = 0.97, duration: Double = 1.5) -> some View {
        modifier(PulseModifier(minScale: minScale, duration: duration))
    }

    /// Wraps the view in a metallic Pokedex-style border.
    func metallicBorder(cornerRadius: CGFloat = PokedexLayout.cardCornerRadius, lineWidth: CGFloat = PokedexLayout.bezelWidth) -> some View {
        modifier(MetallicBorderModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    /// Overlays CRT scan lines on the view.
    func scanLines(spacing: CGFloat = 4, opacity: Double = 0.08) -> some View {
        modifier(ScanLineModifier(lineSpacing: spacing, opacity: opacity))
    }

    /// Convenience: dark screen background + scan lines + green tint (full CRT screen look).
    func crtScreen() -> some View {
        self
            .background(Color.screenBackground)
            .scanLines()
    }
}
