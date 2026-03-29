import SwiftUI

/// The reveal animation triggered when a user discovers a new fish species.
///
/// Sequence:
/// 1. Dark silhouette centered on screen
/// 2. Scanning lines animate across
/// 3. Silhouette dissolves into full-color image with a flash
/// 4. Confetti particles burst outward (matching rarity color)
/// 5. Haptic burst fires
/// 6. Entry number + name appear with typewriter effect
/// 7. "NEW SPECIES DISCOVERED!" banner
struct FishRevealAnimation: View {
    let fish: Fish
    var onComplete: (() -> Void)? = nil

    // MARK: - Animation State

    @State private var phase: RevealPhase = .silhouette
    @State private var scanLineOffset: CGFloat = 0
    @State private var flashOpacity: Double = 0
    @State private var nameText: String = ""
    @State private var showBanner = false
    @State private var confettiParticles: [ConfettiParticle] = []

    private enum RevealPhase {
        case silhouette
        case scanning
        case flash
        case revealed
    }

    /// Total reveal duration in seconds.
    private let totalDuration: Double = 3.5

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Fish image area
                ZStack {
                    // Silhouette (fades out when revealed)
                    Image(systemName: "fish.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .foregroundStyle(Color.metalDark.opacity(0.4))
                        .opacity(phase == .revealed ? 0 : 1)

                    // Revealed fish image (fades in)
                    Image(fish.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .opacity(phase == .revealed ? 1 : 0)
                        .scaleEffect(phase == .revealed ? 1.0 : 0.8)

                    // Scan line sweep
                    if phase == .scanning {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.screenGlow.opacity(0.6),
                                        Color.screenGlow.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 40)
                            .offset(y: scanLineOffset)
                            .transition(.opacity)
                    }

                    // Confetti particles
                    ForEach(confettiParticles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .offset(x: particle.x, y: particle.y)
                            .opacity(particle.opacity)
                    }

                    // Flash of light
                    Color.white
                        .opacity(flashOpacity)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .frame(width: 220, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Entry number
                PixelText(fish.formattedId, size: 20, color: .screenGlow)
                    .opacity(phase == .revealed ? 1 : 0)

                // Typewriter name
                if !nameText.isEmpty {
                    Text(nameText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.opacity)
                }

                // Scientific name
                if phase == .revealed {
                    Text(fish.scientificName)
                        .font(.scientificName(size: 16))
                        .foregroundStyle(.white.opacity(0.6))
                        .transition(.opacity)
                }

                // Banner
                if showBanner {
                    Text("NEW SPECIES DISCOVERED!")
                        .font(.pixelFont(size: 16))
                        .foregroundStyle(fish.rarityTier.swiftUIColor)
                        .crtGlow(color: fish.rarityTier.swiftUIColor, radius: 8, intensity: 0.7)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Dismiss hint
                if phase == .revealed {
                    Text("Tap to continue")
                        .font(.dataReadout(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }
        }
        .onTapGesture {
            if phase == .revealed {
                onComplete?()
            }
        }
        .onAppear {
            startRevealSequence()
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showBanner)
    }

    // MARK: - Animation Sequence

    private func startRevealSequence() {
        // Phase 1: Scanning (0.3s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            phase = .scanning

            // Animate scan line from top to bottom
            withAnimation(.linear(duration: 1.2)) {
                scanLineOffset = 200
            }
        }

        // Phase 2: Flash (1.5s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            phase = .flash

            // Bright flash
            withAnimation(.easeIn(duration: 0.1)) {
                flashOpacity = 0.9
            }

            // Haptic burst
            HapticsService.revealFeedback()
        }

        // Phase 3: Reveal (1.7s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.easeOut(duration: 0.15)) {
                flashOpacity = 0
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                phase = .revealed
            }

            // Spawn confetti
            spawnConfetti()
        }

        // Phase 4: Typewriter name (2.0s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            typewriterName(fish.commonName)
        }

        // Phase 5: Banner (2.8s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation {
                showBanner = true
            }
        }

        // Phase 6: Pokédex voice reads the discovery (3.5s in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            PokedexVoiceService.shared.speakDiscovery(fish)
        }
    }

    // MARK: - Typewriter Effect

    private func typewriterName(_ name: String) {
        nameText = ""
        let characters = Array(name)
        for (index, char) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.04) {
                nameText += String(char)
            }
        }
    }

    // MARK: - Confetti

    private func spawnConfetti() {
        let rarityColor = fish.rarityTier.swiftUIColor
        let colors: [Color] = [rarityColor, .white, rarityColor.opacity(0.7), .screenGlow]

        for _ in 0..<30 {
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? rarityColor,
                size: CGFloat.random(in: 3...8),
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -100...100),
                opacity: 1.0
            )
            confettiParticles.append(particle)
        }

        // Animate particles outward and fade
        withAnimation(.easeOut(duration: 1.5)) {
            confettiParticles = confettiParticles.map { particle in
                var p = particle
                p.x *= 2.5
                p.y *= 2.5
                p.opacity = 0
                return p
            }
        }

        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            confettiParticles = []
        }
    }
}

// MARK: - Confetti Particle

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

// MARK: - Preview

#Preview("Fish Reveal") {
    FishRevealAnimation(fish: Fish(
        id: 2,
        commonName: "Lake Sturgeon",
        scientificName: "Acipenser fulvescens",
        family: "Acipenseridae",
        familyCommonName: "Sturgeons",
        category: .sportFish,
        rarityTier: .mythic,
        conservationStatus: "S2 (imperiled)",
        cosewicStatus: "Endangered",
        sizeRange: "90-180 cm",
        maxWeight: "45+ kg",
        description: "An ancient armoured fish.",
        habitat: "Large rivers and lakes.",
        funFact: "Can live over 100 years.",
        isNative: true
    ))
}
