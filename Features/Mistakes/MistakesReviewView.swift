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
                HStack {
                    Button(action: {
                        let hasPartialProgress = dataManager.mistakes.contains { $0.correctionCount == 1 }
                        if hasPartialProgress {
                            withAnimation { showExitAlert = true }
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            )
                    }
                    
                    Spacer()
                    
                    if !dataManager.mistakes.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.slash.fill")
                                .foregroundColor(.red)
                            Text("\(dataManager.mistakes.count) à corriger")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                if dataManager.mistakes.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                        
                        Text("Tout est propre !")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                        
                        Text("Aucune erreur à corriger pour le moment.\nContinue comme ça !")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { dismiss() }) {
                            Text("Continuer")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(Color.noorGold)
                                .cornerRadius(30)
                        }
                        .padding(.top, 20)
                    }
                    Spacer()
                } else if let letter = currentLetter, let mistake = currentMistake {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Maîtrise :")
                                .font(.caption)
                                .foregroundColor(.noorSecondary)
                            
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(index < mistake.correctionCount ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                            
                            if mistake.correctionCount == 1 {
                                Text("• Validation finale")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 30)
                        
                        FreeDrawingStep(
                            letter: letter,
                            formType: currentForm,
                            onComplete: {
                                handleSuccess(for: mistake)
                            },
                            isChallengeMode: false
                        )
                        .id(stepId)
                        
                        Spacer()
                    }
                } else {
                    ProgressView()
                }
            }
            
            if showExitAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation { showExitAlert = false }
                    }
                
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding(.top, 10)
                    
                    VStack(spacing: 8) {
                        Text("Attention")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.noorText)
                        
                        Text("Si vous quittez maintenant, la progression des erreurs en cours (1/2) sera perdue.")
                            .font(.subheadline)
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation { showExitAlert = false }
                        }) {
                            Text("Continuer")
                                .font(.headline)
                                .foregroundColor(.noorText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.noorSecondary.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            resetPartialProgress()
                            dismiss()
                        }) {
                            Text("Quitter")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
            }
            
            if showFeedback {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: feedbackIcon)
                            .font(.title2)
                        Text(feedbackMessage)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(feedbackColor)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                    .padding(.top, 100)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(300)
            }
        }
        .onAppear {
            loadNextMistake()
        }
        .navigationBarHidden(true)
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
        
        withAnimation {
            showFeedback = true
            if isFullyCorrected {
                feedbackMessage = "Corrigé ! Plus d'erreur."
                feedbackColor = .green
                feedbackIcon = "checkmark.seal.fill"
            } else {
                feedbackMessage = "Bien ! À confirmer plus tard."
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