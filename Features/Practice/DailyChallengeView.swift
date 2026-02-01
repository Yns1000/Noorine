import SwiftUI

struct DailyChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentStep = 0
    @State private var exercises: [DailyExercise] = []
    @State private var showCelebration = false
    @State private var score = 0
    
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                LessonHeader(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    onClose: { dismiss() }
                )
                
                if !exercises.isEmpty {
                    ZStack {
                        let exercise = exercises[currentStep]
                        FreeDrawingStep(
                            letter: exercise.letter,
                            formType: exercise.formType,
                            onComplete: { },
                            isChallengeMode: true,
                            onChallengeComplete: { success in
                                if success {
                                    score += 1
                                    HapticManager.shared.trigger(.success)
                                }
                                nextStep()
                            }
                        )
                        .id("\(currentStep)-\(exercise.letter.id)-\(exercise.formType.rawValue)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if showCelebration {
                DailyChallengeCelebrationOverlay(
                    score: score,
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            generateExercises()
        }
        .navigationBarHidden(true)
    }
    
    private func generateExercises() {
        let masteredLetters = dataManager.getMasteredLetters()
        let sourcePool = masteredLetters.isEmpty ? ArabicLetter.alphabet : masteredLetters
        
        var selectedExercises: [DailyExercise] = []
        
        for _ in 0..<totalSteps {
            let letter = sourcePool.randomElement() ?? ArabicLetter.alphabet[0]
            let randomForm = LetterFormType.allCases.randomElement() ?? .isolated
            selectedExercises.append(DailyExercise(letter: letter, formType: randomForm))
        }
        
        self.exercises = selectedExercises
    }
    
    private func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeChallenge()
        }
    }
    
    private func completeChallenge() {
        let finalXP = score * 10
        dataManager.addDailyChallengeXP(amount: finalXP)
        withAnimation {
            showCelebration = true
        }
        if score > 0 {
            HapticManager.shared.trigger(.success)
        }
    }
}

struct DailyExercise: Identifiable {
    let id = UUID()
    let letter: ArabicLetter
    let formType: LetterFormType
}

struct DailyChallengeCelebrationOverlay: View {
    let score: Int
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(score >= 3 ? Color.noorGold.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: score >= 3 ? "trophy.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 60))
                        .foregroundColor(score >= 3 ? .noorGold : .noorSecondary)
                }
                
                VStack(spacing: 12) {
                    Text(LocalizedStringKey(score == 6 ? "Parfait !" : (score >= 3 ? "Belle performance !" : "Bien essayé !")))
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(LocalizedStringKey("Tu as réussi \(score) exercices sur 6."))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.noorGold)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("+\(score * 10) XP")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.noorGold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                
                Button(action: onDismiss) {
                    Text(LocalizedStringKey("Continuer"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.noorDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.noorGold)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
