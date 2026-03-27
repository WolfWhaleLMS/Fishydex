import UIKit

// MARK: - HapticsService

/// Lightweight haptic feedback for key interactions throughout the app.
/// Uses `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
/// for authentic Pokedex-style tactile responses.
enum HapticsService {

    // MARK: - Catch Feedback

    /// Medium impact — fired when the user logs a catch.
    static func catchFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Reveal Feedback

    /// Heavy impact followed by a success notification — fired when a new species is revealed.
    /// The double hit creates a satisfying "unlock" feel.
    static func revealFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred()

        // Slight delay before the success chime for a two-stage feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let notification = UINotificationFeedbackGenerator()
            notification.prepare()
            notification.notificationOccurred(.success)
        }
    }

    // MARK: - Scan Pulse

    /// Light impact — fired on each pulse of the scanner reticle.
    static func scanPulse() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Button Tap

    /// Soft impact — general button press feedback throughout the UI.
    static func buttonTap() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}
