import AVFoundation
import Foundation

// MARK: - PokedexVoiceService

/// Text-to-speech service that reads fish entries in a robotic Pokédex-style voice.
/// Uses AVSpeechSynthesizer with tuned pitch, rate, and voice selection.
@MainActor
final class PokedexVoiceService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    // MARK: - Singleton

    static let shared = PokedexVoiceService()

    // MARK: - State

    @Published var isSpeaking: Bool = false
    @Published var currentText: String = ""

    // MARK: - Properties

    private let synthesizer = AVSpeechSynthesizer()
    private var selectedVoice: AVSpeechSynthesisVoice?

    // Voice tuning for Pokédex feel
    private let speakingRate: Float = 0.42       // Slightly slower than normal (default ~0.5)
    private let pitchMultiplier: Float = 0.85    // Lower pitch for robotic feel
    private let preUtteranceDelay: TimeInterval = 0.3
    private let postUtteranceDelay: TimeInterval = 0.2

    // MARK: - Init

    private override init() {
        super.init()
        synthesizer.delegate = self
        selectedVoice = selectBestVoice()
        configureAudioSession()
    }

    // MARK: - Voice Selection

    /// Pick the most Pokédex-sounding voice available.
    /// Prefers enhanced/premium voices, falls back to compact.
    private func selectBestVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: "en") }

        // Prefer these voices for a robotic/digital feel (ranked)
        let preferredIdentifiers = [
            "com.apple.voice.enhanced.en-US.Zoe",       // Clear, slightly digital
            "com.apple.voice.enhanced.en-US.Samantha",   // Classic Siri-like
            "com.apple.voice.enhanced.en-GB.Daniel",     // British = more formal/robotic
            "com.apple.voice.enhanced.en-AU.Karen",      // Clear enunciation
            "com.apple.voice.compact.en-US.Samantha",    // Compact fallback
            "com.apple.voice.compact.en-GB.Daniel",      // Compact British
        ]

        for id in preferredIdentifiers {
            if let voice = voices.first(where: { $0.identifier == id }) {
                return voice
            }
        }

        // Last resort: any enhanced English voice, then any English voice
        return voices.first(where: { $0.quality == .enhanced })
            ?? voices.first(where: { $0.quality == .default })
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Audio session configuration is best-effort
        }
    }

    // MARK: - Speaking

    /// Speak a fish entry in Pokédex style.
    func speakFishEntry(_ fish: Fish) {
        let script = buildEntryScript(fish)
        speak(script)
    }

    /// Speak the discovery announcement for a newly caught fish.
    func speakDiscovery(_ fish: Fish) {
        let script = buildDiscoveryScript(fish)
        speak(script)
    }

    /// Speak the scan result when a fish is identified.
    func speakScanResult(_ fish: Fish, confidence: Double) {
        let script = buildScanScript(fish, confidence: confidence)
        speak(script)
    }

    /// Speak arbitrary text in Pokédex voice.
    func speak(_ text: String) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        currentText = text

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice
        utterance.rate = speakingRate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.preUtteranceDelay = preUtteranceDelay
        utterance.postUtteranceDelay = postUtteranceDelay
        utterance.volume = 0.9

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Stop speaking immediately.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentText = ""
    }

    // MARK: - Script Building

    /// Build the full Pokédex-style entry narration for a fish.
    private func buildEntryScript(_ fish: Fish) -> String {
        var parts: [String] = []

        // Opening: "Northern Pike. Number 34. The Pike species."
        parts.append("\(fish.commonName).")
        parts.append("Number \(fish.id).")
        parts.append("\(fish.familyCommonName) family.")

        // Category
        parts.append("Classification: \(fish.category.rawValue).")

        // Size
        parts.append("Size range: \(fish.sizeRange).")

        // Weight if available
        if let weight = fish.maxWeight {
            parts.append("Maximum weight: \(weight).")
        }

        // Description (trimmed to first 2 sentences for brevity)
        let description = truncateToSentences(fish.description, count: 2)
        parts.append(description)

        // Habitat (first sentence)
        let habitat = truncateToSentences(fish.habitat, count: 1)
        parts.append("Habitat: \(habitat)")

        // Conservation status
        if let status = fish.cosewicStatus {
            parts.append("Conservation status: \(status).")
        }

        // Fun fact
        if let fact = fish.funFact {
            parts.append(fact)
        }

        // Rarity
        parts.append("Rarity: \(fish.rarityTier.rawValue).")

        return parts.joined(separator: " ")
    }

    /// Build the discovery announcement script.
    private func buildDiscoveryScript(_ fish: Fish) -> String {
        var parts: [String] = []

        parts.append("New species discovered!")
        parts.append("\(fish.commonName).")
        parts.append("\(fish.scientificName).")
        parts.append("Entry number \(fish.id) has been added to your Fishface.")

        // Quick fact
        let description = truncateToSentences(fish.description, count: 1)
        parts.append(description)

        if fish.rarityTier == .legendary {
            parts.append("This is a legendary species. Remarkable find!")
        } else if fish.rarityTier == .rare {
            parts.append("This is a rare species. Excellent catch!")
        }

        return parts.joined(separator: " ")
    }

    /// Build the scan identification script.
    private func buildScanScript(_ fish: Fish, confidence: Double) -> String {
        let pct = Int(confidence * 100)
        var parts: [String] = []

        parts.append("Species identified.")
        parts.append("\(fish.commonName).")
        parts.append("\(fish.scientificName).")
        parts.append("Confidence: \(pct) percent.")
        parts.append("Classification: \(fish.category.rawValue).")

        let description = truncateToSentences(fish.description, count: 1)
        parts.append(description)

        return parts.joined(separator: " ")
    }

    // MARK: - Helpers

    /// Truncate text to the first N sentences.
    private func truncateToSentences(_ text: String, count: Int) -> String {
        let sentences = text.components(separatedBy: ". ")
        let selected = sentences.prefix(count)
        var result = selected.joined(separator: ". ")
        if !result.hasSuffix(".") {
            result += "."
        }
        return result
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentText = ""
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentText = ""
        }
    }
}
