import SwiftUI

struct SentenceBuilderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var phrases: [ArabicPhrase] = []
    @State private var currentIndex = 0
    @State private var showCelebration = false
    @State private var score = 0

    @State private var correctWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var placedWords: [String?] = []
    @State private var nextSlotIndex = 0
    @State private var isCorrect: Bool? = nil
    @State private var shakeOffset: CGFloat = 0
    @State private var currentFact: String = ArabicFunFacts.randomPhraseFact()

    private let totalPhrases = 6
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.noorBackground, Color.noorBackground.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                
                if phrases.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.noorGold)
                        Text(isEnglish ? "Loading phrases..." : "Chargement...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.noorSecondary)
                    }
                    Spacer()
                } else if currentIndex < phrases.count {
                    exerciseContent
                }
            }

            if showCelebration {
                SentenceBuilderCelebrationOverlay(
                    score: score,
                    total: min(totalPhrases, phrases.count),
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            loadPhrases()
        }
    }
    
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.noorSecondary.opacity(0.15))
                    
                    Capsule()
                        .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(max(1, min(totalPhrases, phrases.count))))
                }
            }
            .frame(height: 8)
            
            Text("\(currentIndex + 1)/\(min(totalPhrases, phrases.count))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
                .frame(width: 36)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
        
    private var exerciseContent: some View {
        let phrase = phrases[currentIndex]
        
        return VStack(spacing: 0) {
            TipBanner(factKey: currentFact, onTap: {
                withAnimation(.spring(response: 0.3)) {
                    currentFact = ArabicFunFacts.randomPhraseFact()
                }
            })
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer().frame(height: 16)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEnglish ? phrase.translationEn : phrase.translationFr)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.noorText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text(phrase.transliteration)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.noorGold)
                }
                
                Spacer()
                
                Button(action: {
                    AudioManager.shared.playText(phrase.arabic, style: .phraseSlow, useCache: true)
                    HapticManager.shared.impact(.light)
                }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .shadow(color: .noorGold.opacity(0.3), radius: 8, y: 4)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 28)
            
            VStack(spacing: 10) {
                Text(isEnglish ? "Your sentence:" : "Ta phrase :")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(placedWords.enumerated()), id: \.offset) { index, word in
                            SBSlotView(
                                word: word,
                                index: index,
                                totalSlots: placedWords.count,
                                isCorrect: isCorrect,
                                onTap: { removeWord(at: index) }
                            )
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .frame(height: 60)
                .offset(x: shakeOffset)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.noorGold.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                isCorrect == true ? Color.green.opacity(0.5) :
                                isCorrect == false ? Color.red.opacity(0.5) :
                                Color.noorGold.opacity(0.2),
                                lineWidth: 2
                            )
                    )
            )
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 28)
            
            VStack(spacing: 10) {
                Text(isEnglish ? "Available words:" : "Mots disponibles :")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                if availableWords.isEmpty && isCorrect == nil {
                    Text(isEnglish ? "Checking..." : "Vérification...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.noorSecondary)
                        .padding(.vertical, 20)
                } else {
                    FlowLayout(spacing: 12) {
                        ForEach(Array(availableWords.enumerated()), id: \.offset) { index, word in
                            Button(action: {
                                placeWord(word, fromIndex: index)
                            }) {
                                Text(word)
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                    .foregroundColor(.noorText)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.tertiarySystemGroupedBackground))
                                            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.noorGold.opacity(0.3), lineWidth: 1.5)
                                    )
                            }
                            .disabled(isCorrect != nil)
                            .scaleEffect(isCorrect != nil ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3), value: isCorrect)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
    }

    private func loadPhrases() {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let multiWord = pool.phrases.filter {
            $0.arabic.components(separatedBy: " ").count >= 2
        }
        phrases = Array(multiWord.shuffled().prefix(totalPhrases))

        if !phrases.isEmpty {
            setupCurrentPhrase()
        }
    }

    private func setupCurrentPhrase() {
        guard currentIndex < phrases.count else { return }
        let phrase = phrases[currentIndex]
        correctWords = phrase.arabic.components(separatedBy: " ")
        placedWords = Array(repeating: nil, count: correctWords.count)
        availableWords = correctWords.shuffled()
        nextSlotIndex = 0
        isCorrect = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard currentIndex < phrases.count else { return }
            AudioManager.shared.playText(phrases[currentIndex].arabic, style: .phraseSlow, useCache: true)
        }
    }

    private func placeWord(_ word: String, fromIndex: Int) {
        guard isCorrect == nil else { return }
        guard nextSlotIndex < placedWords.count else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            placedWords[nextSlotIndex] = word
            availableWords.remove(at: fromIndex)
            nextSlotIndex += 1
        }
        HapticManager.shared.impact(.light)

        if nextSlotIndex >= correctWords.count {
            checkAnswer()
        }
    }

    private func removeWord(at slotIndex: Int) {
        guard isCorrect == nil else { return }
        guard let word = placedWords[slotIndex] else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            placedWords[slotIndex] = nil
            availableWords.append(word)

            var compacted: [String?] = []
            for w in placedWords where w != nil {
                compacted.append(w)
            }
            while compacted.count < correctWords.count {
                compacted.append(nil)
            }
            placedWords = compacted
            nextSlotIndex = compacted.firstIndex(where: { $0 == nil }) ?? correctWords.count
        }
        HapticManager.shared.impact(.light)
    }

    private func checkAnswer() {
        let placed = placedWords.compactMap { $0 }
        let correct = placed == correctWords

        withAnimation(.spring(response: 0.4)) {
            isCorrect = correct
        }

        if correct {
            FeedbackManager.shared.success()
            score += 1
            AudioManager.shared.playText(phrases[currentIndex].arabic, style: .phraseSlow, useCache: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                nextPhrase()
            }
        } else {
            FeedbackManager.shared.error()
            dataManager.addMistake(itemId: String(phrases[currentIndex].id), type: "phrase")

            withAnimation(.default) { shakeOffset = 12 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.default) { shakeOffset = -12 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.default) { shakeOffset = 8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                withAnimation(.default) { shakeOffset = 0 }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.4)) {
                    setupCurrentPhrase()
                }
            }
        }
    }

    private func nextPhrase() {
        withAnimation(.spring(response: 0.4)) {
            if currentIndex < phrases.count - 1 {
                currentIndex += 1
                setupCurrentPhrase()
            } else {
                showCelebration = true
                FeedbackManager.shared.success()
            }
        }
    }
}

struct SBSlotView: View {
    let word: String?
    let index: Int
    let totalSlots: Int
    let isCorrect: Bool?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                if let word = word {
                    Text(word)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(bgColor)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(borderColor, lineWidth: 2.5)
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                            .foregroundColor(.noorGold.opacity(0.4))
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.noorGold.opacity(0.5))
                    }
                    .frame(minWidth: 50, minHeight: 44)
                }
            }
        }
        .disabled(word == nil || isCorrect != nil)
        .scaleEffect(word != nil ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: word)
    }

    private var textColor: Color {
        guard let correct = isCorrect else { return .noorText }
        return correct ? .green : .red
    }

    private var bgColor: Color {
        guard let correct = isCorrect else { return Color(.tertiarySystemGroupedBackground) }
        return correct ? Color.green.opacity(0.12) : Color.red.opacity(0.12)
    }

    private var borderColor: Color {
        guard let correct = isCorrect else { return Color.noorGold.opacity(0.5) }
        return correct ? .green : .red
    }
}

struct SentenceBuilderCelebrationOverlay: View {
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
                type: .sentenceBuilder,
                title: score == total
                    ? LocalizedStringKey(isEnglish ? "Perfect!" : "Parfait !")
                    : LocalizedStringKey(isEnglish ? "Nice job!" : "Bien joué !"),
                subtitle: LocalizedStringKey(isEnglish ? "\(score) of \(total) phrases" : "\(score) phrases sur \(total)"),
                score: score,
                total: total,
                xpEarned: score * 5,
                showStars: true
            ),
            onDismiss: onDismiss
        )
    }
}
