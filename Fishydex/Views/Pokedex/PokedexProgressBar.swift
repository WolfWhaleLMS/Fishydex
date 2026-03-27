import SwiftUI

/// A progress indicator showing Pokedex completion status.
///
/// Displays "32 of 84 Discovered (38%)" with an animated fill bar
/// in Pokedex red and monospace text.
struct PokedexProgressBar: View {
    let discovered: Int
    let total: Int

    /// Progress as 0.0 to 1.0.
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(discovered) / Double(total)
    }

    /// Percentage integer for display.
    private var percentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        VStack(spacing: 6) {
            // Label row
            HStack {
                PixelText(
                    "\(discovered) of \(total) Discovered",
                    size: 11,
                    color: .screenGlow,
                    style: .readout
                )

                Spacer()

                PixelText(
                    "\(percentage)%",
                    size: 11,
                    color: .screenGlow,
                    style: .readout
                )
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: PokedexLayout.progressBarHeight / 2)
                        .fill(Color.screenBackground.opacity(0.6))

                    // Fill
                    RoundedRectangle(cornerRadius: PokedexLayout.progressBarHeight / 2)
                        .fill(
                            LinearGradient(
                                colors: [.pokedexRed, .pokedexDarkRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)

                    // Glow on the leading edge of the fill
                    if progress > 0 {
                        RoundedRectangle(cornerRadius: PokedexLayout.progressBarHeight / 2)
                            .fill(Color.pokedexRed.opacity(0.4))
                            .frame(width: geometry.size.width * progress)
                            .blur(radius: 4)
                    }
                }
            }
            .frame(height: PokedexLayout.progressBarHeight)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(discovered) of \(total) fish discovered, \(percentage) percent complete")
    }
}

// MARK: - Preview

#Preview("Progress Bars") {
    VStack(spacing: 24) {
        PokedexProgressBar(discovered: 0, total: 84)
        PokedexProgressBar(discovered: 32, total: 84)
        PokedexProgressBar(discovered: 84, total: 84)
    }
    .padding()
    .background(Color.screenBackground)
}
