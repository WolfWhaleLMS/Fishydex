import UIKit

// MARK: - HapticsService

/// Lightweight haptic feedback for key interactions throughout the app.
/// Uses `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
/// for authentic Pokedex-style tactile responses.
@MainActor
enum HapticsService {

    // MARK: - Catch Feedback

    /// Medium impact — fired when the user logs a catch.
    static func catchFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Reveal Feedback

    /// Heavy impact followed by a success notification — fired when a new species is revealed.
    /// The double hit creates a satisfying "unlock" feel.
    static func revealFeedback() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // Slight delay before the success chime for a two-stage feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    // MARK: - Scan Pulse

    /// Light impact — fired on each pulse of the scanner reticle.
    static func scanPulse() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Button Tap

    /// Soft impact — general button press feedback throughout the UI.
    static func buttonTap() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
