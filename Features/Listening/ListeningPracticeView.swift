import SwiftUI

struct ListeningPracticeView: View {
    enum Mode {
        case word
        case phrase
    }
    
    let mode: Mode
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var exercises: [ListeningExercise] = []
    @State private var showCompletion = false
    
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                LessonHeader(currentStep: min(currentIndex, totalSteps - 1), totalSteps: totalSteps) {
                    dismiss()
                }
                
                if showCompletion {
                    ListeningCompletionView(score: score, total: totalSteps) {
                        dismiss()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            if exercises.indices.contains(currentIndex) {
                                let exercise = exercises[currentIndex]
                                listeningExerciseView(exercise)
                                    .id(exercise.id)
                            } else {
                                ProgressView().tint(.noorGold)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            generateExercises()
        }
    }
    
    @ViewBuilder
    private func listeningExerciseView(_ exercise: ListeningExercise) -> some View {
        switch exercise.mode {
        case .word:
            if let word = exercise.word {
                ListeningWordExercise(
                    word: word,
                    options: exercise.wordOptions,
                    prompt: languageManager.currentLanguage == .english
                        ? "Listen and choose the correct translation"
                        : "Écoute et choisis la bonne traduction",
                    onAnswer: handleAnswer(correct:),
                    play: {
                        audioManager.playText(word.arabic, style: .word, useCache: true)
                        FeedbackManager.shared.tapLight()
                    }
                )
            }
        case .phrase:
            if let phrase = exercise.phrase {
                ListeningPhraseExercise(
                    phrase: phrase,
                    options: exercise.phraseOptions,
                    prompt: languageManager.currentLanguage == .english
                        ? "Listen and choose the correct meaning"
                        : "Écoute et choisis le bon sens",
                    onAnswer: handleAnswer(correct:),
                    play: {
                        audioManager.playText(phrase.arabic, style: .phraseNormal, useCache: true)
                        FeedbackManager.shared.tapLight()
                    }
                )
            }
        }
    }
    
    private func handleAnswer(correct: Bool) {
        guard correct else { return }
        score += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if currentIndex < totalSteps - 1 {
                withAnimation(.spring()) {
                    currentIndex += 1
                }
            } else {
                showCompletion = true
                FeedbackManager.shared.success()
            }
        }
    }
    
    private func generateExercises() {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        
        var built: [ListeningExercise] = []
        
        switch mode {
        case .word:
            var candidates = pool.words
            if candidates.count < totalSteps {
                let extras = CourseContent.words.filter { w in !candidates.contains(where: { $0.id == w.id }) }
                candidates.append(contentsOf: extras)
            }
            candidates.shuffle()
            
            var usedIds = Set<Int>()
            for _ in 0..<totalSteps {
                let available = candidates.filter { !usedIds.contains($0.id) }
                let word = available.first ?? candidates.randomElement() ?? CourseContent.words.first!
                usedIds.insert(word.id)
                let options = makeWordOptions(target: word, pool: candidates)
                built.append(ListeningExercise(word: word, options: options))
            }
            
        case .phrase:
            var candidates = pool.phrases
            if candidates.count < totalSteps {
                let extras = CourseContent.phrases.filter { p in !candidates.contains(where: { $0.id == p.id }) }
                candidates.append(contentsOf: extras)
            }
            candidates.shuffle()
            
            var usedIds = Set<Int>()
            for _ in 0..<totalSteps {
                let available = candidates.filter { !usedIds.contains($0.id) }
                let phrase = available.first ?? candidates.randomElement() ?? CourseContent.phrases.first!
                usedIds.insert(phrase.id)
                let options = makePhraseOptions(target: phrase, pool: candidates)
                built.append(ListeningExercise(phrase: phrase, options: options))
            }
        }
        
        exercises = built
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
}

private struct ListeningExercise: Identifiable {
    enum Kind {
        case word
        case phrase
    }
    
    let id = UUID()
    let mode: Kind
    let word: ArabicWord?
    let phrase: ArabicPhrase?
    let wordOptions: [ArabicWord]
    let phraseOptions: [ArabicPhrase]
    
    init(word: ArabicWord, options: [ArabicWord]) {
        self.mode = .word
        self.word = word
        self.phrase = nil
        self.wordOptions = options
        self.phraseOptions = []
    }
    
    init(phrase: ArabicPhrase, options: [ArabicPhrase]) {
        self.mode = .phrase
        self.word = nil
        self.phrase = phrase
        self.wordOptions = []
        self.phraseOptions = options
    }
}

private struct ListeningWordExercise: View {
    let word: ArabicWord
    let options: [ArabicWord]
    let prompt: String
    let onAnswer: (Bool) -> Void
    let play: () -> Void

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedId: Int? = nil
    @State private var locked = false
    @State private var funFact = ArabicFunFacts.randomWordFact()

    var body: some View {
        VStack(spacing: 20) {
            Text(prompt)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)

            Button(action: play) {
                HStack(spacing: 10) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(languageManager.currentLanguage == .english ? "Play audio" : "Écouter")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.noorGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.noorGold.opacity(0.12)))
            }

            VStack(spacing: 12) {
                ForEach(options) { option in
                    let title = languageManager.currentLanguage == .english ? option.translationEn : option.translationFr
                    ChoiceOptionCard(
                        title: title,
                        subtitle: option.transliteration,
                        isSelected: selectedId == option.id,
                        isCorrect: option.id == word.id
                    )
                    .onTapGesture {
                        handleSelection(optionId: option.id)
                    }
                }
            }

            TipBanner(factKey: funFact, onTap: {
                HapticManager.shared.impact(.light)
                withAnimation(.spring()) {
                    funFact = ArabicFunFacts.randomWordFact()
                }
            })
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { play() }
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
            dataManager.addMistake(itemId: String(word.id), type: "word")
            onAnswer(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                selectedId = nil
            }
        }
    }
}

private struct ListeningPhraseExercise: View {
    let phrase: ArabicPhrase
    let options: [ArabicPhrase]
    let prompt: String
    let onAnswer: (Bool) -> Void
    let play: () -> Void

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedId: Int? = nil
    @State private var locked = false
    @State private var funFact = ArabicFunFacts.randomPhraseFact()

    var body: some View {
        VStack(spacing: 20) {
            Text(prompt)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)

            Button(action: play) {
                HStack(spacing: 10) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(languageManager.currentLanguage == .english ? "Play audio" : "Écouter")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.noorGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.noorGold.opacity(0.12)))
            }

            VStack(spacing: 12) {
                ForEach(options) { option in
                    let title = languageManager.currentLanguage == .english ? option.translationEn : option.translationFr
                    ChoiceOptionCard(
                        title: title,
                        subtitle: option.transliteration,
                        isSelected: selectedId == option.id,
                        isCorrect: option.id == phrase.id
                    )
                    .onTapGesture {
                        handleSelection(optionId: option.id)
                    }
                }
            }

            TipBanner(factKey: funFact, onTap: {
                HapticManager.shared.impact(.light)
                withAnimation(.spring()) {
                    funFact = ArabicFunFacts.randomPhraseFact()
                }
            })
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { play() }
        }
    }

    private func handleSelection(optionId: Int) {
        guard !locked else { return }
        selectedId = optionId
        let correct = optionId == phrase.id
        if correct {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            dataManager.addMistake(itemId: String(phrase.id), type: "phrase")
            onAnswer(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                selectedId = nil
            }
        }
    }
}

private struct ListeningCompletionView: View {
    let score: Int
    let total: Int
    let onClose: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        let isEnglish = languageManager.currentLanguage == .english
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.noorGold.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.noorGold)
            }
            
            Text(isEnglish ? "Great job!" : "Bien joué !")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
            
            Text(isEnglish
                 ? "You got \(score) out of \(total) correct."
                 : "Tu as réussi \(score) exercices sur \(total).")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            Button(action: onClose) {
                Text(isEnglish ? "Continue" : "Continuer")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.noorGold)
                    .cornerRadius(24)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}
