import SwiftUI

struct DictationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var words: [ArabicWord] = []
    @State private var currentIndex = 0
    @State private var showCelebration = false
    @State private var score = 0

    private let totalWords = 6

    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            if words.isEmpty {
                VStack {
                    Spacer()
                    ProgressView().tint(.noorGold)
                    Spacer()
                }
            } else if currentIndex < words.count {
                VStack(spacing: 0) {
                    LessonHeader(
                        currentStep: currentIndex,
                        totalSteps: min(totalWords, words.count),
                        onClose: { dismiss() }
                    )

                    HStack(spacing: 10) {
                        Button(action: { playCurrentWord() }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 38, height: 38)
                                .background(Color.noorGold)
                                .clipShape(Circle())
                        }

                        Text(languageManager.currentLanguage == .english
                             ? "Listen & build" : "Ecoute & construis")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.noorSecondary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)

                    WordAssemblyView(
                        word: words[currentIndex],
                        onCompletion: {
                            score += 1
                            nextWord()
                        }
                    )
                    .id(words[currentIndex].id)
                    .environmentObject(dataManager)
                }
            }

            if showCelebration {
                DictationCelebrationOverlay(
                    score: score,
                    total: min(totalWords, words.count),
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            loadWords()
        }
    }

    private func loadWords() {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let buildableWords = pool.words.filter { !$0.componentLetterIds.isEmpty }
        words = Array(buildableWords.shuffled().prefix(totalWords))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            playCurrentWord()
        }
    }

    private func playCurrentWord() {
        guard currentIndex < words.count else { return }
        AudioManager.shared.playText(words[currentIndex].arabic, style: .word, useCache: true)
    }

    private func nextWord() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                if currentIndex < words.count - 1 {
                    currentIndex += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        playCurrentWord()
                    }
                } else {
                    completeSession()
                }
            }
        }
    }

    private func completeSession() {
        withAnimation {
            showCelebration = true
        }
        FeedbackManager.shared.success()
    }
}

struct DictationCelebrationOverlay: View {
    let score: Int
    let total: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.noorGold.opacity(0.2))
                        .frame(width: 100, height: 100)
                    Image(systemName: "headphones")
                        .font(.system(size: 44))
                        .foregroundColor(.noorGold)
                }

                VStack(spacing: 8) {
                    Text(LocalizedStringKey(score == total ? "Parfait !" : "Bien joué !"))
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .foregroundColor(.white)

                    Text(LocalizedStringKey("\(score) mots construits sur \(total)"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

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
