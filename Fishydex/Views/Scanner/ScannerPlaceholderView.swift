import SwiftUI

/// Placeholder for the Scanner tab, to be replaced by the scanner agent's implementation.
struct ScannerPlaceholderView: View {
    var body: some View {
        PokedexShellView {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.screenGlow.opacity(0.3))

                Text("SCANNER")
                    .font(.pixelFont(size: 20))
                    .foregroundStyle(Color.screenGlow.opacity(0.5))

                Text("Coming soon")
                    .font(.dataReadout(size: 14))
                    .foregroundStyle(Color.screenGlow.opacity(0.3))

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview("Scanner Placeholder") {
    ScannerPlaceholderView()
}
