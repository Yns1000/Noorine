import SwiftUI


struct SpeedQuizView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var words: [ArabicWord] = []
    @State private var currentIndex = 0
    @State private var options: [String] = []
    @State private var selectedOption: String? = nil
    @State private var isCorrect: Bool? = nil
    @State private var score = 0
    @State private var combo = 0
    @State private var maxCombo = 0
    @State private var showCelebration = false
    @State private var timeRemaining: Double = 5.0
    @State private var timer: Timer? = nil
    @State private var shakeOffset: CGFloat = 0
    @State private var comboScale: CGFloat = 1.0

    private let totalQuestions = 10
    private let timePerQuestion: Double = 5.0

    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                LessonHeader(
                    currentStep: currentIndex,
                    totalSteps: min(totalQuestions, words.count),
                    onClose: {
                        timer?.invalidate()
                        dismiss()
                    }
                )

                if words.isEmpty {
                    Spacer()
                    ProgressView().tint(.noorGold)
                    Spacer()
                } else if currentIndex < words.count {
                    let word = words[currentIndex]

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.noorSecondary.opacity(0.15))
                                .frame(height: 4)
                            Rectangle()
                                .fill(timerColor)
                                .frame(width: geo.size.width * (timeRemaining / timePerQuestion), height: 4)
                                .animation(.linear(duration: 0.1), value: timeRemaining)
                        }
                    }
                    .frame(height: 4)

                    Spacer().frame(height: 20)

                    if combo >= 2 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("x\(combo)")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        .scaleEffect(comboScale)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    VStack(spacing: 14) {
                        Text(word.arabic)
                            .font(.system(size: 52, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                            .environment(\.layoutDirection, .rightToLeft)
                            .offset(x: shakeOffset)

                        Text(word.transliteration)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.noorSecondary)

                        Button(action: {
                            AudioManager.shared.playText(word.arabic, style: .word, useCache: true)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.noorGold)
                                .frame(width: 40, height: 40)
                                .background(Color.noorGold.opacity(0.12))
                                .clipShape(Circle())
                        }
                    }

                    Spacer()

                    Text("\(score)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.noorGold)
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                guard selectedOption == nil else { return }
                                selectOption(option)
                            }) {
                                Text(option)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(optionTextColor(option))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(optionBackground(option))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(optionBorderColor(option), lineWidth: 2)
                                    )
                            }
                            .disabled(selectedOption != nil)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }

            if showCelebration {
                SpeedQuizCelebrationOverlay(
                    score: score,
                    maxCombo: maxCombo,
                    total: min(totalQuestions, words.count),
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear { loadQuestions() }
        .onDisappear { timer?.invalidate() }
    }

    private var timerColor: Color {
        if timeRemaining > 3 { return .noorGold }
        if timeRemaining > 1.5 { return .orange }
        return .red
    }

    private func optionTextColor(_ option: String) -> Color {
        guard let selected = selectedOption else { return .noorText }
        let correctAnswer = languageManager.currentLanguage == .english
            ? words[currentIndex].translationEn : words[currentIndex].translationFr
        if option == correctAnswer { return .white }
        if option == selected { return .white }
        return .noorSecondary
    }

    private func optionBackground(_ option: String) -> Color {
        guard let selected = selectedOption else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
        let correctAnswer = languageManager.currentLanguage == .english
            ? words[currentIndex].translationEn : words[currentIndex].translationFr
        if option == correctAnswer { return .noorSuccess }
        if option == selected && option != correctAnswer { return .noorError }
        return Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
    }

    private func optionBorderColor(_ option: String) -> Color {
        guard selectedOption != nil else { return .clear }
        let correctAnswer = languageManager.currentLanguage == .english
            ? words[currentIndex].translationEn : words[currentIndex].translationFr
        if option == correctAnswer { return .noorSuccess }
        if option == selectedOption && option != correctAnswer { return .noorError }
        return .clear
    }


    private func loadQuestions() {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let allWords = pool.words.filter { !$0.translationEn.isEmpty }
        words = Array(allWords.shuffled().prefix(totalQuestions))

        if !words.isEmpty {
            setupQuestion()
        }
    }

    private func setupQuestion() {
        guard currentIndex < words.count else { return }
        let word = words[currentIndex]
        selectedOption = nil
        isCorrect = nil

        let correctAnswer = languageManager.currentLanguage == .english
            ? word.translationEn : word.translationFr

        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let wrongAnswers = pool.words
            .filter { $0.id != word.id }
            .shuffled()
            .prefix(3)
            .map { languageManager.currentLanguage == .english ? $0.translationEn : $0.translationFr }

        options = (Array(wrongAnswers) + [correctAnswer]).shuffled()

        timeRemaining = timePerQuestion
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                t.invalidate()
                if selectedOption == nil {
                    timeOut()
                }
            }
        }

        AudioManager.shared.playText(word.arabic, style: .word, useCache: true)
    }

    private func selectOption(_ option: String) {
        timer?.invalidate()
        selectedOption = option

        let correctAnswer = languageManager.currentLanguage == .english
            ? words[currentIndex].translationEn : words[currentIndex].translationFr

        let correct = option == correctAnswer
        isCorrect = correct

        if correct {
            FeedbackManager.shared.success()
            let speedBonus = Int(timeRemaining * 2)
            let comboBonus = min(combo, 5)
            score += 10 + speedBonus + comboBonus
            combo += 1
            maxCombo = max(maxCombo, combo)

            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                comboScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    comboScale = 1.0
                }
            }
        } else {
            FeedbackManager.shared.error()
            combo = 0
            dataManager.addMistake(itemId: String(words[currentIndex].id), type: "word")

            withAnimation(.default) { shakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.default) { shakeOffset = -10 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.default) { shakeOffset = 0 }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextQuestion()
        }
    }

    private func timeOut() {
        let correctAnswer = languageManager.currentLanguage == .english
            ? words[currentIndex].translationEn : words[currentIndex].translationFr
        selectedOption = correctAnswer
        isCorrect = false
        combo = 0
        FeedbackManager.shared.error()
        dataManager.addMistake(itemId: String(words[currentIndex].id), type: "word")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            nextQuestion()
        }
    }

    private func nextQuestion() {
        withAnimation {
            if currentIndex < words.count - 1 {
                currentIndex += 1
                setupQuestion()
            } else {
                timer?.invalidate()
                showCelebration = true
                FeedbackManager.shared.success()
            }
        }
    }
}


struct SpeedQuizCelebrationOverlay: View {
    let score: Int
    let maxCombo: Int
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
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.noorGold)
                }

                VStack(spacing: 8) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.noorGold)

                    Text(LocalizedStringKey("points"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                if maxCombo >= 3 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Max combo: x\(maxCombo)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < starCount ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundColor(.noorGold)
                    }
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

    private var starCount: Int {
        let maxPossible = total * 20
        let ratio = Double(score) / Double(max(maxPossible, 1))
        if ratio > 0.7 { return 3 }
        if ratio > 0.4 { return 2 }
        return 1
    }
}
