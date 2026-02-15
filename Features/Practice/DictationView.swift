import SwiftUI

struct DictationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var words: [ArabicWord] = []
    @State private var currentIndex = 0
    @State private var showCelebration = false
    @State private var score = 0
    @State private var didLoad = false

    private let totalWords = 6

    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            if words.isEmpty && !didLoad {
                VStack {
                    Spacer()
                    ProgressView().tint(.noorGold)
                    Spacer()
                }
            } else if words.isEmpty && didLoad {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.noorSecondary)
                    Text(languageManager.currentLanguage == .english
                         ? "Continue lessons to unlock dictation!"
                         : "Continue les leçons pour débloquer la dictée !")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.noorSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button(action: {
                        dataManager.practiceUnlocked = true
                        loadWords()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(languageManager.currentLanguage == .english
                                 ? "I'm impatient" : "Je suis impatient")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.noorGold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color.noorGold.opacity(0.4), lineWidth: 1.5)
                                .background(Capsule().fill(Color.noorGold.opacity(0.08)))
                        )
                    }
                    Spacer()
                }
            } else if currentIndex < words.count {
                VStack(spacing: 0) {
                    dictationHeader
                    
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
        didLoad = true

        if !words.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playCurrentWord()
            }
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
    
    private var dictationHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    ForEach(0..<min(totalWords, words.count), id: \.self) { index in
                        Circle()
                            .fill(index < currentIndex ? Color.green : (index == currentIndex ? Color.noorGold : Color.gray.opacity(0.3)))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                Color.clear
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "ear.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.noorGold)
                        
                        Text(languageManager.currentLanguage == .english
                             ? "Listen & Build" : "Écoute & Construis")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.noorText)
                    }
                    
                    Text(languageManager.currentLanguage == .english
                         ? "Build the word you hear" : "Construis le mot que tu entends")
                        .font(.system(size: 12))
                        .foregroundColor(.noorSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.noorGold.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.noorGold.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

struct DictationCelebrationOverlay: View {
    let score: Int
    let total: Int
    let onDismiss: () -> Void
    @EnvironmentObject var languageManager: LanguageManager

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .dictation,
                title: score == total
                    ? LocalizedStringKey(isEnglish ? "Perfect!" : "Parfait !")
                    : LocalizedStringKey(isEnglish ? "Nice job!" : "Bien joué !"),
                subtitle: LocalizedStringKey(isEnglish ? "\(score) of \(total) words" : "\(score) mots sur \(total)"),
                score: score,
                total: total,
                xpEarned: score * 5,
                showStars: true
            ),
            onDismiss: onDismiss
        )
    }
}
