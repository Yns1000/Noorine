import SwiftUI

struct MistakesReviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var currentMistake: MistakeItem?
    @State private var currentLetter: ArabicLetter?
    @State private var currentForm: LetterFormType = .isolated
    
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackColor = Color.green
    @State private var feedbackIcon = "checkmark.circle.fill"
    @State private var showExitAlert = false
    
    @State private var isProcessingSuccess = false
    
    @State private var stepId = UUID()
    
    private func resetPartialProgress() {
        for index in dataManager.mistakes.indices {
            if dataManager.mistakes[index].correctionCount == 1 {
                dataManager.mistakes[index].correctionCount = 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if dataManager.mistakes.isEmpty {
                    emptyStateView
                } else if let letter = currentLetter, let mistake = currentMistake {
                    
                    progressIndicatorView(mistake: mistake)
                        .padding(.bottom, 8)
                    
                    FreeDrawingStep(
                        letter: letter,
                        formType: currentForm,
                        onComplete: {
                            handleSuccess(for: mistake)
                        },
                        isChallengeMode: false
                    )
                    .id(stepId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(!isProcessingSuccess)
                    
                } else {
                    Spacer()
                    ProgressView().tint(.noorGold)
                    Spacer()
                }
            }
            
            if showExitAlert { exitAlertView }
            if showFeedback { feedbackOverlay }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { loadNextMistake() }
    }
    
    
    private var headerView: some View {
        HStack {
            Button(action: {
                let hasPartialProgress = dataManager.mistakes.contains { $0.correctionCount == 1 }
                if hasPartialProgress {
                    withAnimation(.spring()) { showExitAlert = true }
                } else {
                    dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text(t("Retour"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.noorSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                )
            }
            .disabled(isProcessingSuccess)
            
            Spacer()
            
            Text(t("Correction"))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noorText)
            
            Spacer()
            
            if !dataManager.mistakes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                    Text("\(dataManager.mistakes.count)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.red.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.red.opacity(0.1)))
            } else {
                Color.clear.frame(width: 44, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
    
    
    private func progressIndicatorView(mistake: MistakeItem) -> some View {
        let isValidationStep = mistake.correctionCount >= 1
        
        return HStack(spacing: 8) {
            Circle()
                .fill(isValidationStep ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Capsule()
                .fill(Color.noorSecondary.opacity(0.2))
                .frame(width: 20, height: 2)
            
            Circle()
                .stroke(isValidationStep ? Color.orange : Color.noorSecondary.opacity(0.3), lineWidth: 2)
                .background(Circle().fill(Color.clear))
                .frame(width: 8, height: 8)
            
            Text(isValidationStep ? t("Validation finale") : t("Correction"))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isValidationStep ? .orange : .noorSecondary)
                .padding(.leading, 6)
                .textCase(.uppercase)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Capsule().fill(Color.noorSecondary.opacity(0.05)))
    }
    
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            ZStack {
                Circle().fill(Color.green.opacity(0.1)).frame(width: 140, height: 140)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70)).foregroundColor(.green)
                    .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
            }
            VStack(spacing: 12) {
                Text(t("Tout est propre !"))
                    .font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(.noorText)
                Text(t("Aucune erreur à corriger pour le moment."))
                    .font(.system(size: 16, weight: .medium)).foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            Button(action: { dismiss() }) {
                Text(t("Continuer"))
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.noorGold).cornerRadius(18)
                    .shadow(color: .noorGold.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 40).padding(.top, 20)
            Spacer()
        }
    }
    
    private var exitAlertView: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { showExitAlert = false } }
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44)).foregroundColor(.orange).padding(.top, 8)
                    VStack(spacing: 8) {
                        Text(t("Déjà fatigué ?")).font(.title3).bold().foregroundColor(.noorText)
                        Text(t("Si tu quittes maintenant, la progression de l'erreur en cours sera perdue."))
                            .font(.subheadline).foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                }
                HStack(spacing: 16) {
                    Button(action: { resetPartialProgress(); dismiss() }) {
                        Text(t("Quitter")).font(.headline).foregroundColor(.red)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.red.opacity(0.1)).cornerRadius(16)
                    }
                    Button(action: { withAnimation(.spring()) { showExitAlert = false } }) {
                        Text(t("Continuer")).font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.noorGold).cornerRadius(16)
                    }
                }
            }
            .padding(24).background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
            .cornerRadius(32).shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            .padding(.horizontal, 30).transition(.scale.combined(with: .opacity))
        }
        .zIndex(100)
    }
    
    private var feedbackOverlay: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .allowsHitTesting(true)
            
            VStack {
                HStack(spacing: 16) {
                    Image(systemName: feedbackIcon).font(.title2).fontWeight(.bold)
                    Text(feedbackMessage).font(.headline).fontWeight(.bold)
                }
                .foregroundColor(.white).padding(.horizontal, 24).padding(.vertical, 16)
                .background(Capsule().fill(feedbackColor).shadow(color: feedbackColor.opacity(0.4), radius: 10, y: 5))
                .padding(.top, 70)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
        .zIndex(200)
    }
    
    
    private func loadNextMistake() {
        isProcessingSuccess = false
        
        guard !dataManager.mistakes.isEmpty else { currentMistake = nil; return }
        
        if let randomMistake = dataManager.mistakes.randomElement() {
            currentMistake = randomMistake
            
            if randomMistake.itemType == "letter", let id = Int(randomMistake.itemId) {
                currentLetter = ArabicLetter.letter(byId: id)
                currentForm = LetterFormType(rawValue: randomMistake.formType ?? "") ?? (LetterFormType.allCases.randomElement() ?? .isolated)
            }
            stepId = UUID()
        }
    }
    
    private func handleSuccess(for mistake: MistakeItem) {
        guard !isProcessingSuccess else { return }
        isProcessingSuccess = true
        
        let isFullyCorrected = dataManager.recordMistakeSuccess(item: mistake)
        HapticManager.shared.trigger(.success)
        
        withAnimation(.spring()) {
            showFeedback = true
            if isFullyCorrected {
                feedbackMessage = t("Confirmation réussie ! Erreur effacée.")
                feedbackColor = .green; feedbackIcon = "checkmark.seal.fill"
            } else {
                feedbackMessage = t("C'est noté ! À confirmer plus tard.")
                feedbackColor = .orange; feedbackIcon = "clock.arrow.circlepath"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showFeedback = false }
            loadNextMistake()
        }
    }
    
    private func t(_ key: String) -> String {
        if languageManager.currentLanguage == .french { return key }
        switch key {
        case "Retour": return "Back"
        case "Correction": return "Correction"
        case "Validation finale": return "Final Check"
        case "Erreur": return "Mistake"
        case "Entraînement": return "Practice"
        case "restant(s)": return "remaining"
        case "Tout est propre !": return "All Clean!"
        case "Aucune erreur à corriger pour le moment.": return "No mistakes to correct right now."
        case "Continuer": return "Continue"
        case "Déjà fatigué ?": return "Tired already?"
        case "Si tu quittes maintenant, la progression de l'erreur en cours sera perdue.": return "If you quit now, current progress will be lost."
        case "Quitter": return "Quit"
        case "Confirmation réussie ! Erreur effacée.": return "Confirmed! Mistake cleared."
        case "C'est noté ! À confirmer plus tard.": return "Good! To be confirmed later."
        default: return key
        }
    }
}
