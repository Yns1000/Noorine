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
                
                if !exercises.isEmpty {
                    let exercise = exercises[currentStep]
                    if exercise.type == .letter {
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
        if !pool.words.isEmpty { availableTypes.append(.word) }
        if !pool.phrases.isEmpty { availableTypes.append(.phrase) }
        
        if availableTypes.isEmpty {
            availableTypes = [.letter]
        }
        
        var selected: [PracticeExercise] = []
        
        for _ in 0..<totalSteps {
            let type = availableTypes.randomElement() ?? .letter
            switch type {
            case .letter:
                let letter = pool.letters.randomElement() ?? ArabicLetter.alphabet[0]
                let form = LetterFormType.allCases.randomElement() ?? .isolated
                selected.append(PracticeExercise(letter: letter, formType: form))
            case .vowel:
                let base = (pool.letters.randomElement() ?? ArabicLetter.alphabet[0])
                let vowel = (pool.vowels.randomElement() ?? CourseContent.vowels[0])
                let options = makeVowelOptions(target: vowel, pool: pool.vowels)
                selected.append(PracticeExercise(baseLetter: base, vowel: vowel, vowelOptions: options))
            case .word:
                let word = pool.words.randomElement() ?? CourseContent.words[0]
                let options = makeWordOptions(target: word, pool: pool.words)
                selected.append(PracticeExercise(word: word, wordOptions: options))
            case .phrase:
                let phrase = pool.phrases.randomElement() ?? CourseContent.phrases[0]
                let options = makePhraseOptions(target: phrase, pool: pool.phrases)
                selected.append(PracticeExercise(phrase: phrase, phraseOptions: options))
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
