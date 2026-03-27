import SwiftUI
import CoreLocation

// MARK: - ScannerHUDView

/// Full-screen Pokedex HUD overlay rendered on top of the camera preview.
///
/// Includes:
/// - Red border frame (Pokedex shell edges)
/// - Targeting reticle with crosshair (center)
/// - CRT-green monospace data readouts (corners)
/// - Animated scan lines
/// - Data stream effect (edge column of scrolling hex)
struct ScannerHUDView: View {

    /// Live GPS location (nil if unavailable).
    var currentLocation: CLLocation?

    /// Whether the scanner is actively running.
    var isScanning: Bool = true

    // MARK: - Animation State

    @State private var blinkVisible: Bool = true
    @State private var dataStreamOffset: CGFloat = 0
    @State private var currentTime: String = ""

    private let crtGreen = Color(red: 0, green: 1, blue: 0.255) // #00ff41
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Red border frame (Pokedex shell edges)
                shellBorder

                // Scan lines overlay
                ScanLineOverlay(lineSpacing: 3, lineOpacity: 0.06, scrollDuration: 6)

                // Data stream column (right edge)
                dataStreamColumn
                    .frame(width: 60)
                    .position(x: geometry.size.width - 36, y: geometry.size.height / 2)

                // Center targeting reticle + crosshair
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        ScannerCrosshair()
                        ScannerReticle(isScanning: isScanning)
                    }
                    Spacer()
                }

                // Corner data readouts
                VStack {
                    // Top row
                    HStack(alignment: .top) {
                        topLeftReadout
                        Spacer()
                        topRightReadout
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer()

                    // Bottom row
                    HStack(alignment: .bottom) {
                        bottomLeftReadout
                        Spacer()
                        bottomRightReadout
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            updateTime()
            startBlinkAnimation()
            startDataStream()
        }
        .onReceive(timer) { _ in
            updateTime()
        }
    }

    // MARK: - Shell Border

    /// Red border around the entire view simulating Pokedex shell edges.
    private var shellBorder: some View {
        RoundedRectangle(cornerRadius: 4)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.pokedexRed.opacity(0.6),
                        Color.pokedexDarkRed.opacity(0.4),
                        Color.pokedexRed.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .padding(2)
    }

    // MARK: - Top-Left: Title

    private var topLeftReadout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FISHYDEX SCANNER v1.0")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(crtGreen)
                .shadow(color: crtGreen.opacity(0.5), radius: 3)

            Text("SK FRESHWATER SPECIES DB")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(crtGreen.opacity(0.6))
        }
    }

    // MARK: - Top-Right: Date/Time

    private var topRightReadout: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(currentTime)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(crtGreen)
                .shadow(color: crtGreen.opacity(0.5), radius: 3)

            Text(dateString)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(crtGreen.opacity(0.6))
        }
    }

    // MARK: - Bottom-Left: GPS Coordinates

    private var bottomLeftReadout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("GPS")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(crtGreen.opacity(0.6))

            if let location = currentLocation {
                Text(formatCoordinate(location.coordinate.latitude, isLatitude: true))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(crtGreen)
                    .shadow(color: crtGreen.opacity(0.4), radius: 2)

                Text(formatCoordinate(location.coordinate.longitude, isLatitude: false))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(crtGreen)
                    .shadow(color: crtGreen.opacity(0.4), radius: 2)
            } else {
                Text("ACQUIRING...")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(crtGreen.opacity(0.5))
            }
        }
    }

    // MARK: - Bottom-Right: Scanning Status

    private var bottomRightReadout: some View {
        HStack(spacing: 6) {
            if isScanning {
                Text("SCANNING")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(crtGreen)
                    .shadow(color: crtGreen.opacity(0.5), radius: 3)

                Circle()
                    .fill(crtGreen)
                    .frame(width: 6, height: 6)
                    .opacity(blinkVisible ? 1.0 : 0.0)
                    .shadow(color: crtGreen.opacity(0.6), radius: 3)
            } else {
                Text("READY")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(crtGreen.opacity(0.6))
            }
        }
    }

    // MARK: - Data Stream Column

    /// Scrolling column of random hex/numbers on the right edge for a sci-fi data feed effect.
    private var dataStreamColumn: some View {
        GeometryReader { geometry in
            let lineCount = Int(geometry.size.height / 14) + 4
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(0..<lineCount, id: \.self) { index in
                    Text(randomHexString(seed: index, offset: dataStreamOffset))
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .foregroundStyle(crtGreen.opacity(Double.random(in: 0.08...0.25)))
                }
            }
            .offset(y: -dataStreamOffset.truncatingRemainder(dividingBy: 14))
        }
        .clipped()
    }

    // MARK: - Helpers

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        currentTime = formatter.string(from: Date())
    }

    private func formatCoordinate(_ value: Double, isLatitude: Bool) -> String {
        let direction = isLatitude
            ? (value >= 0 ? "N" : "S")
            : (value >= 0 ? "E" : "W")
        return String(format: "%@ %08.4f\u{00B0}", direction, abs(value))
    }

    /// Generates a deterministic-looking hex string that changes with the offset.
    private func randomHexString(seed: Int, offset: CGFloat) -> String {
        let hash = abs(seed &* 2654435761 &+ Int(offset / 14))
        return String(format: "%06X", hash % 0xFFFFFF)
    }

    // MARK: - Animations

    private func startBlinkAnimation() {
        withAnimation(
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)
        ) {
            blinkVisible = false
        }
    }

    private func startDataStream() {
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            dataStreamOffset = 2000
        }
    }
}

// MARK: - Preview

#Preview("Scanner HUD") {
    ZStack {
        Color.black.ignoresSafeArea()

        ScannerHUDView(
            currentLocation: CLLocation(latitude: 52.1332, longitude: -106.6700),
            isScanning: true
        )
    }
}
