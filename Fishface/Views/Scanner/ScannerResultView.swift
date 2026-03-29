import SwiftUI

// MARK: - ScannerResultView

/// Shows after a photo is captured — displays auto-identification results
/// with a Pokédex-style "SPECIES IDENTIFIED" animation.
struct ScannerResultView: View {
    let viewModel: ScannerViewModel
    let onDismiss: () -> Void

    @State private var showResult = false
    @State private var confidenceAnimated: Double = 0

    var body: some View {
        ZStack {
            // Background: captured photo, dimmed
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.7))
            }

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                // Content based on state
                switch viewModel.identificationState {
                case .analyzing:
                    analyzingView

                case .identified:
                    if let topMatch = viewModel.identifiedMatches.first {
                        identifiedView(topMatch)
                    }

                case .noMatch:
                    noMatchView

                case .failed(let message):
                    failedView(message)

                case .idle:
                    EmptyView()
                }

                Spacer()
            }
        }
        .overlay(ScanLineOverlay().opacity(0.3))
    }

    // MARK: - Analyzing State

    private var analyzingView: some View {
        VStack(spacing: 24) {
            // Spinning reticle
            Image(systemName: "viewfinder")
                .font(.system(size: 60))
                .foregroundStyle(Color.screenGlow)
                .rotationEffect(.degrees(viewModel.scanAnimationPhase * 360))
                .animation(
                    .linear(duration: 2).repeatForever(autoreverses: false),
                    value: viewModel.scanAnimationPhase
                )
                .onAppear {
                    viewModel.scanAnimationPhase = 1
                }

            VStack(spacing: 8) {
                PixelText("ANALYZING SPECIMEN...", size: 18, style: .readout)

                // Fake data stream
                PixelText("CROSS-REFERENCING DATABASE", size: 12, color: .screenGlow.opacity(0.6), style: .readout)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.screenBackground.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.screenGlow.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Identified State

    private func identifiedView(_ match: FishIdentificationService.Match) -> some View {
        VStack(spacing: 20) {
            // "SPECIES IDENTIFIED" header
            PixelText("SPECIES IDENTIFIED", size: 20, color: .screenGlow)
                .opacity(showResult ? 1 : 0)
                .scaleEffect(showResult ? 1 : 0.5)

            // Fish info card
            VStack(spacing: 16) {
                // Entry number
                PixelText(match.fish.formattedId, size: 28, color: .screenGlow)

                // Fish name
                Text(match.fish.commonName)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(match.fish.scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.white.opacity(0.7))

                // Confidence bar
                VStack(spacing: 4) {
                    PixelText("CONFIDENCE", size: 10, color: .screenGlow.opacity(0.6), style: .readout)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(confidenceColor(match.confidence))
                                .frame(width: geo.size.width * confidenceAnimated)
                        }
                    }
                    .frame(height: 8)

                    PixelText(
                        "\(Int(match.confidence * 100))% MATCH",
                        size: 12,
                        color: confidenceColor(match.confidence),
                        style: .readout
                    )
                }

                // Type badge
                TypeBadge(category: match.fish.category)

                // Other matches
                if viewModel.identifiedMatches.count > 1 {
                    otherMatchesSection
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.screenBackground.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.screenGlow.opacity(0.3), lineWidth: 1)
                    )
            )

            // Action buttons
            VStack(spacing: 12) {
                PokedexButton("Confirm — It's a \(match.fish.commonName)!", icon: "checkmark.circle.fill") {
                    Task {
                        await viewModel.confirmIdentification(fishId: match.fish.id)
                    }
                }

                PokedexButton("Not right — Pick manually", icon: "list.bullet", style: .secondary) {
                    viewModel.rejectIdentification()
                }
            }
        }
        .padding(20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                showResult = true
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                confidenceAnimated = match.confidence
            }
            HapticsService.scanPulse()

            // Pokédex voice reads the scan result
            PokedexVoiceService.shared.speakScanResult(match.fish, confidence: match.confidence)
        }
    }

    // MARK: - Other Matches

    private var otherMatches: [FishIdentificationService.Match] {
        Array(viewModel.identifiedMatches.dropFirst().prefix(3))
    }

    private var otherMatchesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            PixelText("OTHER POSSIBILITIES", size: 10, color: .screenGlow.opacity(0.5), style: .readout)

            ForEach(otherMatches, id: \.fish.id) { match in
                Button {
                    Task {
                        await viewModel.confirmIdentification(fishId: match.fish.id)
                    }
                } label: {
                    otherMatchRow(match)
                }
            }
        }
    }

    private func otherMatchRow(_ match: FishIdentificationService.Match) -> some View {
        HStack {
            PixelText(match.fish.formattedId, size: 11, color: .screenGlow.opacity(0.6), style: .readout)

            Text(match.fish.commonName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text("\(Int(match.confidence * 100))%")
                .font(.caption.monospaced())
                .foregroundStyle(Color.screenGlow.opacity(0.5))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - No Match / Failed States

    private var noMatchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 50))
                .foregroundStyle(Color.yellow)

            PixelText("NO MATCH FOUND", size: 18, color: .yellow)

            Text("Couldn't identify the species automatically.\nPick it from the list instead.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            PokedexButton("Pick Species Manually", icon: "list.bullet") {
                viewModel.rejectIdentification()
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.screenBackground.opacity(0.9))
        )
    }

    private func failedView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 50))
                .foregroundStyle(Color.orange)

            PixelText("SCAN FAILED", size: 18, color: .orange)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            PokedexButton("Pick Species Manually", icon: "list.bullet") {
                viewModel.rejectIdentification()
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.screenBackground.opacity(0.9))
        )
    }

    // MARK: - Helpers

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        if confidence >= 0.6 { return .yellow }
        return .orange
    }
}
