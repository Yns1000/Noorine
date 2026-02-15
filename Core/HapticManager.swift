import UIKit

class HapticManager {
    static let shared = HapticManager()

    var isEnabled: Bool = true

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func buttonTap() {
        impact(.light)
    }

    func cardFlip() {
        impact(.light)
    }

    func correctAnswer() {
        trigger(.success)
    }

    func wrongAnswer() {
        trigger(.error)
    }

    func letterDraw() {
        impact(.soft)
    }

    func levelUp() {
        guard isEnabled else { return }
        let light = UIImpactFeedbackGenerator(style: .light)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        light.prepare()
        medium.prepare()
        heavy.prepare()

        light.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            heavy.impactOccurred()
        }
    }

    func streakMilestone() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.notificationOccurred(.success)
        }
    }

    func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
