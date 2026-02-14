import SwiftUI

struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    var onNext: (() -> Void)? = nil
    var formsCompleted: Int = 4
    var totalForms: Int = 4
    @EnvironmentObject var languageManager: LanguageManager
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .letterMastery,
                title: formsCompleted == totalForms 
                    ? LocalizedStringKey(isEnglish ? "Well done!" : "Bravo !")
                    : LocalizedStringKey(isEnglish ? "Nice job!" : "Bien joué !"),
                subtitle: formsCompleted == totalForms
                    ? LocalizedStringKey(isEnglish ? "You've mastered this letter!" : "Tu as maîtrisé cette lettre !")
                    : LocalizedStringKey(isEnglish ? "You learned \(formsCompleted) of \(totalForms) forms" : "Tu as appris \(formsCompleted) formes sur \(totalForms)"),
                score: formsCompleted,
                total: totalForms,
                xpEarned: 10,
                showStars: true
            ),
            onDismiss: onDismiss,
            onNext: onNext,
            nextButtonTitle: LocalizedStringKey(isEnglish ? "Next Letter" : "Lettre Suivante")
        )
    }
}
