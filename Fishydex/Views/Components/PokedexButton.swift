import SwiftUI

/// A Pokedex-styled button with a red background, metallic border, and press animation.
///
/// Usage:
/// ```swift
/// PokedexButton("Log Catch") {
///     viewModel.logCatch()
/// }
///
/// PokedexButton("View in AR", icon: "arkit") {
///     showAR = true
/// }
/// ```
struct PokedexButton: View {
    let label: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    let action: () -> Void

    init(_ label: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.style = style
        self.action = action
    }

    enum ButtonStyle {
        case primary   // Red Pokedex button
        case secondary // Dark metallic button
        case accent    // Blue accent button
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(borderGradient, lineWidth: 2)
            )
            .pokedexShadow()
        }
        .buttonStyle(PokedexPressStyle())
    }

    // MARK: - Computed Styles

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(
                colors: [.pokedexRed, .pokedexDarkRed],
                startPoint: .top,
                endPoint: .bottom
            )
        case .secondary:
            return LinearGradient(
                colors: [.metalDark, Color(red: 0.3, green: 0.33, blue: 0.38)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .accent:
            return LinearGradient(
                colors: [.pokedexBlue, Color(red: 0.16, green: 0.36, blue: 0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [.metalSilver.opacity(0.6), .metalDark.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Press Animation Style

/// Custom ButtonStyle that scales down on press and provides haptic-like feedback.
private struct PokedexPressStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Compact Variant

/// A smaller, inline Pokedex button (no full-width stretch).
struct PokedexButtonCompact: View {
    let label: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [.pokedexRed, .pokedexDarkRed],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.metalSilver.opacity(0.5), .metalDark.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PokedexPressStyle())
    }
}

// MARK: - Preview

#Preview("Pokedex Buttons") {
    VStack(spacing: 20) {
        PokedexButton("Log a Catch", icon: "camera.fill") { }
        PokedexButton("View in AR", icon: "arkit", style: .accent) { }
        PokedexButton("Delete Record", style: .secondary) { }

        HStack(spacing: 12) {
            PokedexButtonCompact(label: "Catch", icon: "plus.circle.fill") { }
            PokedexButtonCompact(label: "Share", icon: "square.and.arrow.up") { }
        }
    }
    .padding()
    .background(Color.screenBackground)
}
