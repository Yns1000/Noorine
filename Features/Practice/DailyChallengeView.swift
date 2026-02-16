import SwiftUI

struct DailyChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var currentStep = 0
    @State private var exercises: [PracticeExercise] = []
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

                if !exercises.isEmpty, currentStep < exercises.count {
                    let exercise = exercises[currentStep]
                    if exercise.type == .letter || exercise.type == .wordAssembly {
                        ZStack {
                            exerciseView(exercise)
                                .id(exercise.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                    } else {
                        ScrollView(showsIndicators: false) {
                            ZStack {
                                exerciseView(exercise)
                                    .id(exercise.id)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 40)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                    }
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
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)

        var availableTypes: [PracticeExerciseType] = []
        if !pool.letters.isEmpty { availableTypes.append(.letter) }
        if !pool.vowels.isEmpty { availableTypes.append(.vowel) }
        if !pool.words.isEmpty {
            availableTypes.append(.word)
            availableTypes.append(.wordAssembly)
            availableTypes.append(.listening)
        }
        if !pool.phrases.isEmpty {
            availableTypes.append(.phrase)
            let multiWord = pool.phrases.filter { $0.arabic.components(separatedBy: " ").count >= 2 }
            if !multiWord.isEmpty { availableTypes.append(.sentenceBuilder) }
        }

        if availableTypes.isEmpty {
            availableTypes = [.letter]
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let seed = formatter.string(from: Date()).hashValue
        var rng = SeededRandomGenerator(seed: UInt64(bitPattern: Int64(seed)))

        var selected: [PracticeExercise] = []
        var usedTypes: Set<String> = []

        for _ in 0..<totalSteps {
            var type = availableTypes.randomElement(using: &rng) ?? .letter
            if usedTypes.count < availableTypes.count {
                let unused = availableTypes.filter { !usedTypes.contains(String(describing: $0)) }
                if let preferred = unused.randomElement(using: &rng) {
                    type = preferred
                }
            }
            usedTypes.insert(String(describing: type))

            switch type {
            case .letter:
                let letter = pool.letters.randomElement(using: &rng) ?? ArabicLetter.alphabet[0]
                let form = LetterFormType.allCases.randomElement(using: &rng) ?? .isolated
                selected.append(PracticeExercise(letter: letter, formType: form))
            case .vowel:
                let base = pool.letters.randomElement(using: &rng) ?? ArabicLetter.alphabet[0]
                let vowel = pool.vowels.randomElement(using: &rng) ?? CourseContent.vowels[0]
                let options = makeVowelOptions(target: vowel, pool: pool.vowels)
                selected.append(PracticeExercise(baseLetter: base, vowel: vowel, vowelOptions: options))
            case .word:
                let word = pool.words.randomElement(using: &rng) ?? CourseContent.words[0]
                let options = makeWordOptions(target: word, pool: pool.words)
                selected.append(PracticeExercise(word: word, wordOptions: options))
            case .phrase:
                let phrase = pool.phrases.randomElement(using: &rng) ?? CourseContent.phrases[0]
                let options = makePhraseOptions(target: phrase, pool: pool.phrases)
                selected.append(PracticeExercise(phrase: phrase, phraseOptions: options))
            case .wordAssembly:
                let buildableWords = pool.words.filter { !$0.componentLetterIds.isEmpty }
                if let word = buildableWords.randomElement(using: &rng) {
                    selected.append(PracticeExercise(wordAssembly: word))
                } else {
                    let word = pool.words.randomElement(using: &rng) ?? CourseContent.words[0]
                    let options = makeWordOptions(target: word, pool: pool.words)
                    selected.append(PracticeExercise(word: word, wordOptions: options))
                }
            case .listening:
                let word = pool.words.randomElement(using: &rng) ?? CourseContent.words[0]
                let options = makeWordOptions(target: word, pool: pool.words)
                selected.append(PracticeExercise(listeningWord: word, wordOptions: options))
            case .sentenceBuilder:
                let multiWordPhrases = pool.phrases.filter { $0.arabic.components(separatedBy: " ").count >= 2 }
                if let phrase = multiWordPhrases.randomElement(using: &rng) {
                    selected.append(PracticeExercise(sentenceBuilder: phrase))
                } else {
                    let phrase = pool.phrases.randomElement(using: &rng) ?? CourseContent.phrases[0]
                    let options = makePhraseOptions(target: phrase, pool: pool.phrases)
                    selected.append(PracticeExercise(phrase: phrase, phraseOptions: options))
                }
            }
        }

        exercises = selected
    }

    @ViewBuilder
    private func exerciseView(_ exercise: PracticeExercise) -> some View {
        switch exercise.type {
        case .letter:
            if let letter = exercise.letter, let form = exercise.formType {
                FreeDrawingStep(
                    letter: letter,
                    formType: form,
                    onComplete: { },
                    isChallengeMode: true,
                    onChallengeComplete: { success in
                        if success { score += 1 }
                        nextStep()
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case .word:
            if let word = exercise.word {
                WordChoiceExercise(
                    prompt: languageManager.currentLanguage == .english ? word.translationEn : word.translationFr,
                    options: exercise.wordOptions,
                    correctId: word.id,
                    onAnswer: { correct in
                        if correct { score += 1 } else {
                            dataManager.addMistake(itemId: String(word.id), type: "word")
                        }
                        nextStep()
                    },
                    allowRetry: false
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case .phrase:
            if let phrase = exercise.phrase {
                PhraseChoiceExercise(
                    prompt: languageManager.currentLanguage == .english ? phrase.translationEn : phrase.translationFr,
                    options: exercise.phraseOptions,
                    correctId: phrase.id,
                    onAnswer: { correct in
                        if correct { score += 1 } else {
                            dataManager.addMistake(itemId: String(phrase.id), type: "phrase")
                        }
                        nextStep()
                    },
                    allowRetry: false
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case .vowel:
            if let base = exercise.baseLetter, let vowel = exercise.vowel {
                VowelChoiceExercise(
                    baseLetter: base,
                    targetVowel: vowel,
                    options: exercise.vowelOptions,
                    onAnswer: { correct in
                        if correct { score += 1 } else {
                            let mistakeId = "\(base.id):\(vowel.id)"
                            dataManager.addMistake(itemId: mistakeId, type: "vowel")
                        }
                        nextStep()
                    },
                    allowRetry: false
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case .wordAssembly:
            if let word = exercise.word {
                WordAssemblyView(
                    word: word,
                    onCompletion: {
                        score += 1
                        nextStep()
                    }
                )
                .environmentObject(dataManager)
            } else {
                ProgressView().tint(.noorGold)
            }
        case .listening:
            if let word = exercise.word {
                DailyChallengeListeningExercise(
                    word: word,
                    options: exercise.wordOptions,
                    onAnswer: { correct in
                        if correct { score += 1 } else {
                            dataManager.addMistake(itemId: String(word.id), type: "word")
                        }
                        nextStep()
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case .sentenceBuilder:
            if let phrase = exercise.phrase {
                DailyChallengeSentenceExercise(
                    phrase: phrase,
                    onAnswer: { correct in
                        if correct { score += 1 } else {
                            dataManager.addMistake(itemId: String(phrase.id), type: "phrase")
                        }
                        nextStep()
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        }
    }

    private func makeWordOptions(target: ArabicWord, pool: [ArabicWord]) -> [ArabicWord] {
        let source = pool.count >= 4 ? pool : CourseContent.words
        let others = source.filter { $0.id != target.id }.shuffled().prefix(3)
        var options = Array(others) + [target]
        options.shuffle()
        return options
    }

    private func makePhraseOptions(target: ArabicPhrase, pool: [ArabicPhrase]) -> [ArabicPhrase] {
        let source = pool.count >= 4 ? pool : CourseContent.phrases
        let others = source.filter { $0.id != target.id }.shuffled().prefix(3)
        var options = Array(others) + [target]
        options.shuffle()
        return options
    }

    private func makeVowelOptions(target: ArabicVowel, pool: [ArabicVowel]) -> [ArabicVowel] {
        let source = pool.count >= 3 ? pool : CourseContent.vowels
        let others = source.filter { $0.id != target.id }.shuffled().prefix(2)
        var options = Array(others) + [target]
        options.shuffle()
        return options
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
            FeedbackManager.shared.success()
        }
    }
}

enum PracticeExerciseType {
    case letter
    case vowel
    case word
    case phrase
    case wordAssembly
    case listening
    case sentenceBuilder
}

struct PracticeExercise: Identifiable {
    let id = UUID()
    let type: PracticeExerciseType

    let letter: ArabicLetter?
    let formType: LetterFormType?

    let baseLetter: ArabicLetter?
    let vowel: ArabicVowel?
    let vowelOptions: [ArabicVowel]

    let word: ArabicWord?
    let wordOptions: [ArabicWord]

    let phrase: ArabicPhrase?
    let phraseOptions: [ArabicPhrase]

    init(letter: ArabicLetter, formType: LetterFormType) {
        self.type = .letter
        self.letter = letter
        self.formType = formType
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = nil
        self.wordOptions = []
        self.phrase = nil
        self.phraseOptions = []
    }

    init(baseLetter: ArabicLetter, vowel: ArabicVowel, vowelOptions: [ArabicVowel]) {
        self.type = .vowel
        self.letter = nil
        self.formType = nil
        self.baseLetter = baseLetter
        self.vowel = vowel
        self.vowelOptions = vowelOptions
        self.word = nil
        self.wordOptions = []
        self.phrase = nil
        self.phraseOptions = []
    }

    init(word: ArabicWord, wordOptions: [ArabicWord]) {
        self.type = .word
        self.letter = nil
        self.formType = nil
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = word
        self.wordOptions = wordOptions
        self.phrase = nil
        self.phraseOptions = []
    }

    init(phrase: ArabicPhrase, phraseOptions: [ArabicPhrase]) {
        self.type = .phrase
        self.letter = nil
        self.formType = nil
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = nil
        self.wordOptions = []
        self.phrase = phrase
        self.phraseOptions = phraseOptions
    }

    init(wordAssembly word: ArabicWord) {
        self.type = .wordAssembly
        self.letter = nil
        self.formType = nil
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = word
        self.wordOptions = []
        self.phrase = nil
        self.phraseOptions = []
    }

    init(listeningWord word: ArabicWord, wordOptions: [ArabicWord]) {
        self.type = .listening
        self.letter = nil
        self.formType = nil
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = word
        self.wordOptions = wordOptions
        self.phrase = nil
        self.phraseOptions = []
    }

    init(sentenceBuilder phrase: ArabicPhrase) {
        self.type = .sentenceBuilder
        self.letter = nil
        self.formType = nil
        self.baseLetter = nil
        self.vowel = nil
        self.vowelOptions = []
        self.word = nil
        self.wordOptions = []
        self.phrase = phrase
        self.phraseOptions = []
    }
}

struct DailyChallengeListeningExercise: View {
    let word: ArabicWord
    let options: [ArabicWord]
    let onAnswer: (Bool) -> Void

    @State private var selectedId: Int? = nil
    @State private var locked = false
    @State private var isPlaying = false
    @EnvironmentObject var languageManager: LanguageManager

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(isEnglish ? "What do you hear?" : "Qu'entends-tu ?")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorText)

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.noorGold.opacity(isPlaying ? 0.3 - Double(i) * 0.1 : 0.1), lineWidth: 2)
                        .frame(width: 100 + CGFloat(i) * 40, height: 100 + CGFloat(i) * 40)
                        .scaleEffect(isPlaying ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                                .repeatCount(3, autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: isPlaying
                        )
                }

                Button(action: playWord) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.noorGold, .orange],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 90, height: 90)
                            .shadow(color: .noorGold.opacity(0.4), radius: 12, y: 6)

                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 180)

            Text(isEnglish ? "Tap the speaker, then choose" : "Appuie sur le haut-parleur, puis choisis")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.noorSecondary)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    let translation = isEnglish ? option.translationEn : option.translationFr
                    ChoiceOptionCard(
                        title: translation,
                        subtitle: option.transliteration,
                        isSelected: selectedId == option.id,
                        isCorrect: option.id == word.id
                    )
                    .onTapGesture {
                        handleSelection(optionId: option.id)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                playWord()
            }
        }
    }

    private func playWord() {
        isPlaying = true
        AudioManager.shared.playText(word.arabic, style: .word, useCache: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPlaying = false
        }
    }

    private func handleSelection(optionId: Int) {
        guard !locked else { return }
        selectedId = optionId
        let correct = optionId == word.id
        if correct {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                selectedId = nil
            }
        }
    }
}

struct DailyChallengeSentenceExercise: View {
    let phrase: ArabicPhrase
    let onAnswer: (Bool) -> Void

    @State private var correctWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var placedWords: [String?] = []
    @State private var nextSlotIndex = 0
    @State private var isCorrect: Bool? = nil
    @State private var locked = false
    @State private var shakeOffset: CGFloat = 0
    @State private var attempts = 0
    @EnvironmentObject var languageManager: LanguageManager

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isEnglish ? "Build the sentence" : "Construis la phrase")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.noorText)

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
                            .frame(width: 44, height: 44)
                            .shadow(color: .noorGold.opacity(0.3), radius: 6, y: 3)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            )
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
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
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.noorGold.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isCorrect == true ? Color.green.opacity(0.5) :
                                isCorrect == false ? Color.red.opacity(0.5) :
                                Color.noorGold.opacity(0.2),
                                lineWidth: 2
                            )
                    )
            )
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text(isEnglish ? "Available words:" : "Mots disponibles :")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
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
        .onAppear { setupPhrase() }
    }

    private func setupPhrase() {
        correctWords = phrase.arabic.components(separatedBy: " ")
        placedWords = Array(repeating: nil, count: correctWords.count)
        availableWords = correctWords.shuffled()
        nextSlotIndex = 0
        isCorrect = nil
        locked = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AudioManager.shared.playText(phrase.arabic, style: .phraseSlow, useCache: true)
        }
    }

    private func placeWord(_ word: String, fromIndex: Int) {
        guard isCorrect == nil, !locked else { return }
        guard nextSlotIndex < placedWords.count else { return }
        guard let actualIndex = availableWords.firstIndex(of: word) else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            placedWords[nextSlotIndex] = word
            availableWords.remove(at: actualIndex)
            nextSlotIndex += 1
        }
        HapticManager.shared.impact(.light)

        if nextSlotIndex >= correctWords.count {
            checkAnswer()
        }
    }

    private func removeWord(at slotIndex: Int) {
        guard isCorrect == nil, !locked else { return }
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
        locked = true

        if correct {
            FeedbackManager.shared.success()
            AudioManager.shared.playText(phrase.arabic, style: .phraseSlow, useCache: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onAnswer(true)
            }
        } else {
            FeedbackManager.shared.error()
            attempts += 1

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

            if attempts >= 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onAnswer(false)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring(response: 0.4)) {
                        setupPhrase()
                    }
                }
            }
        }
    }
}

struct DCSentenceWord: Identifiable {
    let id = UUID()
    let index: Int
    let text: String
}

struct DailyChallengeCelebrationOverlay: View {
    @EnvironmentObject var languageManager: LanguageManager
    let score: Int
    let onDismiss: () -> Void

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .dailyChallenge,
                title: score == 6
                    ? LocalizedStringKey(isEnglish ? "Perfect!" : "Parfait !")
                    : (score >= 3 ? LocalizedStringKey(isEnglish ? "Great job!" : "Belle performance !") : LocalizedStringKey(isEnglish ? "Nice try!" : "Bien essayé !")),
                subtitle: LocalizedStringKey(isEnglish ? "\(score) of 6 exercises" : "\(score) exercices sur 6"),
                score: score,
                total: 6,
                xpEarned: score * 10,
                showStars: true
            ),
            onDismiss: onDismiss
        )
    }
}

struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
