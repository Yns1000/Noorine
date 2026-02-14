import SwiftUI

struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    var onNext: (() -> Void)? = nil
    var formsCompleted: Int = 4
    var totalForms: Int = 4
    
    var body: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .letterMastery,
                title: formsCompleted == totalForms 
                    ? LocalizedStringKey("Bravo !")
                    : LocalizedStringKey("Bien joué !"),
                subtitle: formsCompleted == totalForms
                    ? LocalizedStringKey("Tu as maîtrisé cette lettre !")
                    : LocalizedStringKey("Tu as appris \(formsCompleted) formes sur \(totalForms)"),
                score: formsCompleted,
                total: totalForms,
                xpEarned: 10,
                showStars: true
            ),
            onDismiss: onDismiss,
            onNext: onNext,
            nextButtonTitle: LocalizedStringKey("Lettre Suivante")
        )
    }
}
