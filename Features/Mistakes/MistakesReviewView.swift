import SwiftUI

struct MistakesReviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentMistake: MistakeItem?
    @State private var currentLetter: ArabicLetter?
    @State private var currentForm: LetterFormType = .isolated
    
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackColor = Color.green
    @State private var feedbackIcon = "checkmark.circle.fill"
    @State private var showExitAlert = false
    
    @State private var stepId = UUID()
    
    private func resetPartialProgress() {
        for mistake in dataManager.mistakes {
            if mistake.correctionCount == 1 {
                mistake.correctionCount = 0
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
                    contentView(letter: letter, mistake: mistake)
                } else {
                    Spacer()
                    ProgressView()
                        .tint(.noorGold)
                    Spacer()
                }
            }
            
            if showExitAlert {
                exitAlertView
            }
            
            if showFeedback {
                feedbackOverlay
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadNextMistake()
        }
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
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            if !dataManager.mistakes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Text("\(dataManager.mistakes.count) erreurs")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            Capsule().stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }
    
    private func contentView(letter: ArabicLetter, mistake: MistakeItem) -> some View {
        VStack(spacing: 24) {
            
            VStack(spacing: 8) {
                Text("Correction")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noorSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                HStack(spacing: 6) {
                    ForEach(0..<2) { index in
                        if index < mistake.correctionCount {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                                .shadow(color: .green.opacity(0.3), radius: 4)
                        } else {
                            Circle()
                                .fill(Color.noorSecondary.opacity(0.2))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(.top, 10)
            
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                    .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
                
                FreeDrawingStep(
                    letter: letter,
                    formType: currentForm,
                    onComplete: {
                        handleSuccess(for: mistake)
                    },
                    isChallengeMode: false
                )
                .id(stepId)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 2)
                    .frame(width: 170, height: 170)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
            }
            
            VStack(spacing: 12) {
                Text("Tout est propre !")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text("Tu as corrigé toutes tes erreurs.\nExcellent travail.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { dismiss() }) {
                Text("Continuer")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(18)
                    .shadow(color: .noorGold.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private var exitAlertView: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { showExitAlert = false }
                }
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                        .padding(.top, 8)
                    
                    VStack(spacing: 8) {
                        Text("Déjà fatigué ?")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.noorText)
                        
                        Text("Si tu quittes maintenant, la progression de l'erreur en cours sera perdue.")
                            .font(.subheadline)
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        resetPartialProgress()
                        dismiss()
                    }) {
                        Text("Quitter")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) { showExitAlert = false }
                    }) {
                        Text("Continuer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(24)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
        }
        .zIndex(100)
    }
    
    private var feedbackOverlay: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: feedbackIcon)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(feedbackMessage)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(feedbackColor)
                    .shadow(color: feedbackColor.opacity(0.4), radius: 10, y: 5)
            )
            .padding(.top, 60)
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(200)
    }
    
    private func loadNextMistake() {
        guard !dataManager.mistakes.isEmpty else {
            currentMistake = nil
            return
        }
        
        if let randomMistake = dataManager.mistakes.randomElement() {
            currentMistake = randomMistake
            
            if randomMistake.itemType == "letter", let id = Int(randomMistake.itemId) {
                currentLetter = ArabicLetter.letter(byId: id)
                
                if let savedForm = randomMistake.formType, let form = LetterFormType(rawValue: savedForm) {
                    currentForm = form
                } else {
                    currentForm = LetterFormType.allCases.randomElement() ?? .isolated
                }
            }
            stepId = UUID()
        }
    }
    
    private func handleSuccess(for mistake: MistakeItem) {
        let isFullyCorrected = dataManager.recordMistakeSuccess(item: mistake)
        HapticManager.shared.trigger(.success)
        
        withAnimation(.spring()) {
            showFeedback = true
            if isFullyCorrected {
                feedbackMessage = "Corrigé ! Plus d'erreur."
                feedbackColor = .green
                feedbackIcon = "checkmark.seal.fill"
            } else {
                feedbackMessage = "Bien joué ! Encore une fois."
                feedbackColor = .orange
                feedbackIcon = "arrow.triangle.2.circlepath"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showFeedback = false
            }
            loadNextMistake()
        }
    }
}
