import SwiftUI

/// A monospace/pixel-styled text view for Pokedex entry numbers and data readouts.
///
/// Usage:
/// ```swift
/// PixelText("#034", size: 14, color: .screenGlow)
/// PixelText("SCANNING...", style: .readout)
/// ```
struct PixelText: View {
    let text: String

    init(_ text: String, size: CGFloat = 14, color: Color = .screenGlow, style: TextStyle = .entry) {
        self.text = text
        self.size = size
        self.color = color
        self.style = style
    }
    var size: CGFloat = 14
    var color: Color = .screenGlow
    var style: TextStyle = .entry

    enum TextStyle {
        case entry    // Bold monospace for entry numbers
        case readout  // Medium monospace for data readouts

        func font(size: CGFloat) -> Font {
            switch self {
            case .entry:   return .pixelFont(size: size)
            case .readout: return .dataReadout(size: size)
            }
        }
    }

    var body: some View {
        Text(text)
            .font(style.font(size: size))
            .foregroundStyle(color)
            .crtGlow(color: color, radius: 3, intensity: 0.4)
    }
}

// MARK: - Preview

#Preview("Pixel Text Styles") {
    VStack(spacing: 16) {
        PixelText("#001", size: 20)
        PixelText("Northern Pike", size: 16, color: .white, style: .readout)
        PixelText("SCANNING...", size: 14, style: .readout)
        PixelText("32 of 60 Discovered", size: 12, color: .screenGlow, style: .readout)
    }
    .padding()
    .background(Color.screenBackground)
}
