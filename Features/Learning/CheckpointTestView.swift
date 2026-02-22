import SwiftUI

struct CheckpointQuestion: Identifiable {
    let id = UUID()
    let type: QuestionType
    let prompt: String
    let arabicDisplay: String?
    let options: [String]
    let correctIndex: Int

    enum QuestionType {
        case letterRecognition
        case contextualForm
        case vowelIdentify
        case wordTranslation
        case drawingFree
    }
}

struct CheckpointTestView: View {
    let afterLevel: Int
    var onCompletion: (() -> Void)? = nil

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [CheckpointQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var isAnswerRevealed = false
    @State private var showCelebration = false
    @State private var showFailure = false
    @State private var shakeWrong = false
    @State private var progressValue: CGFloat = 0

    // Drawing question state
    @StateObject private var drawingModel = DrawingCanvasModel()
    @State private var drawingLetterTarget: ArabicLetter? = nil
    @State private var drawingValidated = false
    @State private var drawingCorrect = false

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    private var currentQuestion: CheckpointQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            if questions.isEmpty {
                ProgressView()
                    .onAppear { buildQuestions() }
            } else if showCelebration {
                celebrationView
            } else if showFailure {
                failureView
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    headerBar
                    progressBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            questionCounter

                            if question.type == .drawingFree {
                                drawingQuestionView(question)
                            } else {
                                multipleChoiceView(question)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.noorSecondary.opacity(0.1)))
            }

            Spacer()

            Text(isEnglish ? "Checkpoint" : "Checkpoint")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorGold)
                Text("\(score)/\(questions.count)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.noorGold)
            }
            .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.noorSecondary.opacity(0.15))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.noorGold, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progressValue, height: 6)
                    .animation(.spring(response: 0.4), value: progressValue)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var questionCounter: some View {
        Text(isEnglish
             ? "Question \(currentIndex + 1) of \(questions.count)"
             : "Question \(currentIndex + 1) sur \(questions.count)")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.noorSecondary)
    }

    // MARK: - Multiple Choice View

    @ViewBuilder
    private func multipleChoiceView(_ question: CheckpointQuestion) -> some View {
        VStack(spacing: 24) {
            // Prompt
            Text(question.prompt)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)

            // Arabic display
            if let arabic = question.arabicDisplay {
                Text(arabic)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.noorText)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.noorSecondary.opacity(0.08))
                    )
            }

            // Options
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        guard !isAnswerRevealed else { return }
                        selectAnswer(index, question: question)
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(optionTextColor(index, question: question))
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if isAnswerRevealed {
                                if index == question.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 22))
                                } else if index == selectedAnswer {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                        .padding(16)
                        .background(optionBackground(index, question: question))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(optionBorderColor(index, question: question), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .offset(x: shakeWrong && index == selectedAnswer && index != question.correctIndex ? -10 : 0)
                }
            }
        }
    }

    // MARK: - Drawing Question View

    @ViewBuilder
    private func drawingQuestionView(_ question: CheckpointQuestion) -> some View {
        VStack(spacing: 20) {
            Text(question.prompt)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)

            if let letter = drawingLetterTarget {
                Text(letter.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorGold)

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(
                                    drawingValidated
                                        ? (drawingCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                                        : Color.noorSecondary.opacity(0.2),
                                    lineWidth: 2
                                )
                        )

                    FreeDrawingCanvas(
                        model: drawingModel,
                        referenceText: letter.isolated,
                        canvasSize: CGSize(width: 260, height: 260)
                    )
                }
                .frame(width: 280, height: 280)

                HStack(spacing: 16) {
                    Button(action: {
                        drawingModel.clearAll()
                        drawingValidated = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text(isEnglish ? "Clear" : "Effacer")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.noorSecondary.opacity(0.1)))
                    }

                    if !drawingValidated {
                        Button(action: validateDrawing) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                Text(isEnglish ? "Validate" : "Valider")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.noorGold))
                        }
                        .disabled(drawingModel.strokes.isEmpty)
                        .opacity(drawingModel.strokes.isEmpty ? 0.5 : 1)
                    }
                }

                if drawingValidated {
                    VStack(spacing: 8) {
                        Image(systemName: drawingCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(drawingCorrect ? .green : .red)

                        Text(drawingCorrect
                             ? (isEnglish ? "Well done!" : "Bravo !")
                             : (isEnglish ? "Keep practicing!" : "Continue de t'entraîner !"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.noorSecondary)

                        Button(action: advanceToNextQuestion) {
                            Text(isEnglish ? "Next" : "Suivant")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    // MARK: - Option Styling

    private func optionTextColor(_ index: Int, question: CheckpointQuestion) -> Color {
        if !isAnswerRevealed { return .noorText }
        if index == question.correctIndex { return .green }
        if index == selectedAnswer { return .red }
        return .noorSecondary
    }

    private func optionBackground(_ index: Int, question: CheckpointQuestion) -> Color {
        if !isAnswerRevealed {
            return index == selectedAnswer ? Color.noorGold.opacity(0.08) : Color.noorSecondary.opacity(0.06)
        }
        if index == question.correctIndex { return Color.green.opacity(0.1) }
        if index == selectedAnswer { return Color.red.opacity(0.1) }
        return Color.noorSecondary.opacity(0.04)
    }

    private func optionBorderColor(_ index: Int, question: CheckpointQuestion) -> Color {
        if !isAnswerRevealed {
            return index == selectedAnswer ? Color.noorGold.opacity(0.4) : Color.clear
        }
        if index == question.correctIndex { return Color.green.opacity(0.6) }
        if index == selectedAnswer { return Color.red.opacity(0.6) }
        return Color.clear
    }

    // MARK: - Actions

    private func selectAnswer(_ index: Int, question: CheckpointQuestion) {
        selectedAnswer = index
        isAnswerRevealed = true

        let correct = index == question.correctIndex
        if correct {
            score += 1
            HapticManager.shared.impact(.medium)
        } else {
            HapticManager.shared.notification(.error)
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) {
                shakeWrong = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shakeWrong = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            advanceToNextQuestion()
        }
    }

    private func validateDrawing() {
        // Simplified drawing validation: we always give the point if they drew something
        // A more advanced version could use RecognitionEngine
        let hasDrawn = drawingModel.strokes.count >= 1 && drawingModel.strokes.contains(where: { $0.count >= 3 })
        drawingCorrect = hasDrawn
        drawingValidated = true

        if drawingCorrect {
            score += 1
            HapticManager.shared.impact(.medium)
        } else {
            HapticManager.shared.notification(.error)
        }
    }

    private func advanceToNextQuestion() {
        let nextIndex = currentIndex + 1
        if nextIndex >= questions.count {
            finishTest()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex = nextIndex
                selectedAnswer = nil
                isAnswerRevealed = false
                drawingValidated = false
                drawingCorrect = false
                drawingModel.clearAll()
                progressValue = CGFloat(nextIndex) / CGFloat(questions.count)
            }
        }
    }

    private func finishTest() {
        withAnimation(.easeInOut(duration: 0.3)) {
            progressValue = 1.0
        }
        let passed = score >= GameConstants.Checkpoint.passThreshold
        if passed {
            dataManager.completeCheckpoint(afterLevel: afterLevel)
            HapticManager.shared.notification(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showCelebration = true
            }
        } else {
            HapticManager.shared.notification(.warning)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showFailure = true
            }
        }
    }

    // MARK: - Celebration / Failure Views

    private var celebrationView: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .checkpoint,
                title: LocalizedStringKey(isEnglish ? "Checkpoint Passed!" : "Checkpoint Réussi !"),
                subtitle: LocalizedStringKey(isEnglish
                    ? "\(score)/\(questions.count) correct answers"
                    : "\(score)/\(questions.count) bonnes réponses"),
                score: score,
                total: questions.count,
                xpEarned: GameConstants.Checkpoint.xpReward,
                showStars: true
            ),
            onDismiss: {
                onCompletion?()
                dismiss()
            }
        )
    }

    private var failureView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.14, blue: 0.18), Color(red: 0.08, green: 0.09, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                EmotionalMascot(mood: .encouraging, size: 120, showAura: true)

                Text(isEnglish ? "Almost there!" : "Presque !")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text(isEnglish
                     ? "You got \(score)/\(questions.count). You need \(GameConstants.Checkpoint.passThreshold) to pass."
                     : "Tu as eu \(score)/\(questions.count). Il faut \(GameConstants.Checkpoint.passThreshold) pour valider.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Stars showing score
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { i in
                        let starThreshold = i == 0 ? 1 : (i == 1 ? GameConstants.Checkpoint.passThreshold : questions.count)
                        Image(systemName: score >= starThreshold ? "star.fill" : "star")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(
                                score >= starThreshold
                                    ? LinearGradient(colors: [.noorGold, .orange], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                            )
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: retryTest) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                            Text(isEnglish ? "Try Again" : "Réessayer")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.noorDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .shadow(color: .noorGold.opacity(0.5), radius: 16, y: 8)
                    }

                    Button(action: { dismiss() }) {
                        Text(isEnglish ? "Go Back" : "Retour")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }

    private func retryTest() {
        withAnimation {
            score = 0
            currentIndex = 0
            selectedAnswer = nil
            isAnswerRevealed = false
            showCelebration = false
            showFailure = false
            progressValue = 0
            drawingValidated = false
            drawingCorrect = false
            drawingModel.clearAll()
            buildQuestions()
        }
    }

    // MARK: - Question Builder

    private func buildQuestions() {
        var result: [CheckpointQuestion] = []
        let lang = languageManager.currentLanguage

        // Gather content from levels 1..afterLevel
        let levelDefs = CourseContent.getLevels(language: lang).filter { $0.id <= afterLevel }
        var letterIds = Set<Int>()
        var wordIds = Set<Int>()
        var vowelIds = Set<Int>()

        for def in levelDefs {
            switch def.type {
            case .alphabet, .quiz, .speaking:
                letterIds.formUnion(def.contentIds)
            case .wordBuild:
                wordIds.formUnion(def.contentIds)
            case .vowels:
                vowelIds.formUnion(def.contentIds)
            default:
                break
            }
        }

        let letters = ArabicLetter.alphabet.filter { letterIds.contains($0.id) }
        let words = CourseContent.words.filter { wordIds.contains($0.id) }
        let vowels = CourseContent.vowels.filter { vowelIds.contains($0.id) }

        // Q1 & Q2: Letter Recognition (2 questions)
        let shuffledLetters = letters.shuffled()
        for i in 0..<min(2, shuffledLetters.count) {
            let target = shuffledLetters[i]
            var options = [target.transliteration]
            let distractors = letters.filter { $0.id != target.id }.shuffled().prefix(3).map { $0.transliteration }
            options.append(contentsOf: distractors)

            // Ensure we have 4 options
            while options.count < 4 {
                options.append("—")
            }

            let shuffledOptions = options.enumerated().sorted { _, _ in Bool.random() }
            let correctIdx = shuffledOptions.firstIndex(where: { $0.offset == 0 })!

            result.append(CheckpointQuestion(
                type: .letterRecognition,
                prompt: isEnglish
                    ? "What is this letter?"
                    : "Quelle est cette lettre ?",
                arabicDisplay: target.isolated,
                options: shuffledOptions.map { $0.element },
                correctIndex: correctIdx
            ))
        }

        // Q3: Contextual Form
        if letters.count >= 2 {
            let target = letters.randomElement()!
            let forms = ["initial", "medial", "final"]
            let formName = forms.randomElement()!
            let correctForm: String
            switch formName {
            case "initial": correctForm = target.initial
            case "medial": correctForm = target.medial
            case "final": correctForm = target.final
            default: correctForm = target.isolated
            }

            let formLabel: String
            if isEnglish {
                formLabel = formName
            } else {
                switch formName {
                case "initial": formLabel = "initiale"
                case "medial": formLabel = "médiane"
                case "final": formLabel = "finale"
                default: formLabel = "isolée"
                }
            }

            var options = [correctForm]
            // Add incorrect forms from same letter + different letters
            let otherForms = [target.isolated, target.initial, target.medial, target.final]
                .filter { $0 != correctForm }
            options.append(contentsOf: otherForms.shuffled().prefix(2))

            if options.count < 4, let extra = letters.filter({ $0.id != target.id }).randomElement() {
                options.append(extra.isolated)
            }
            while options.count < 4 { options.append("—") }

            let shuffledOpts = options.enumerated().sorted { _, _ in Bool.random() }
            let correctIdx = shuffledOpts.firstIndex(where: { $0.offset == 0 })!

            result.append(CheckpointQuestion(
                type: .contextualForm,
                prompt: isEnglish
                    ? "Find the \(formLabel) form of \(target.transliteration)"
                    : "Trouve la forme \(formLabel) de \(target.transliteration)",
                arabicDisplay: target.isolated,
                options: shuffledOpts.map { $0.element },
                correctIndex: correctIdx
            ))
        }

        // Q4: Vowel Identification
        if vowels.count >= 2 {
            let target = vowels.randomElement()!
            var options = [target.name]
            let distractors = vowels.filter { $0.id != target.id }.shuffled().prefix(3).map { $0.name }
            options.append(contentsOf: distractors)
            while options.count < 4 { options.append("—") }

            let shuffledOpts = options.enumerated().sorted { _, _ in Bool.random() }
            let correctIdx = shuffledOpts.firstIndex(where: { $0.offset == 0 })!

            // Show the vowel on a letter example
            let exampleDisplay = target.examples.first?.combination ?? target.symbol

            result.append(CheckpointQuestion(
                type: .vowelIdentify,
                prompt: isEnglish
                    ? "Which vowel is this?"
                    : "Quelle est cette voyelle ?",
                arabicDisplay: exampleDisplay,
                options: shuffledOpts.map { $0.element },
                correctIndex: correctIdx
            ))
        } else {
            // Fallback: extra letter recognition if no vowels
            if let target = shuffledLetters.dropFirst(2).first {
                var options = [target.transliteration]
                let distractors = letters.filter { $0.id != target.id }.shuffled().prefix(3).map { $0.transliteration }
                options.append(contentsOf: distractors)
                while options.count < 4 { options.append("—") }
                let shuffledOpts = options.enumerated().sorted { _, _ in Bool.random() }
                let correctIdx = shuffledOpts.firstIndex(where: { $0.offset == 0 })!
                result.append(CheckpointQuestion(
                    type: .letterRecognition,
                    prompt: isEnglish ? "What is this letter?" : "Quelle est cette lettre ?",
                    arabicDisplay: target.isolated,
                    options: shuffledOpts.map { $0.element },
                    correctIndex: correctIdx
                ))
            }
        }

        // Q5: Word Translation
        if words.count >= 2 {
            let target = words.randomElement()!
            let translation = isEnglish ? target.translationEn : target.translationFr
            var options = [translation]
            let distractors = words.filter { $0.id != target.id }.shuffled().prefix(3)
                .map { isEnglish ? $0.translationEn : $0.translationFr }
            options.append(contentsOf: distractors)
            while options.count < 4 { options.append("—") }

            let shuffledOpts = options.enumerated().sorted { _, _ in Bool.random() }
            let correctIdx = shuffledOpts.firstIndex(where: { $0.offset == 0 })!

            result.append(CheckpointQuestion(
                type: .wordTranslation,
                prompt: isEnglish
                    ? "What does this word mean?"
                    : "Que signifie ce mot ?",
                arabicDisplay: target.arabic,
                options: shuffledOpts.map { $0.element },
                correctIndex: correctIdx
            ))
        } else {
            // Fallback: extra letter recognition
            if let target = letters.shuffled().first {
                var options = [target.transliteration]
                let distractors = letters.filter { $0.id != target.id }.shuffled().prefix(3).map { $0.transliteration }
                options.append(contentsOf: distractors)
                while options.count < 4 { options.append("—") }
                let shuffledOpts = options.enumerated().sorted { _, _ in Bool.random() }
                let correctIdx = shuffledOpts.firstIndex(where: { $0.offset == 0 })!
                result.append(CheckpointQuestion(
                    type: .letterRecognition,
                    prompt: isEnglish ? "What is this letter?" : "Quelle est cette lettre ?",
                    arabicDisplay: target.isolated,
                    options: shuffledOpts.map { $0.element },
                    correctIndex: correctIdx
                ))
            }
        }

        // Q6: Drawing Free
        if let drawTarget = letters.shuffled().first {
            drawingLetterTarget = drawTarget
            result.append(CheckpointQuestion(
                type: .drawingFree,
                prompt: isEnglish
                    ? "Draw the letter \(drawTarget.transliteration)"
                    : "Dessine la lettre \(drawTarget.transliteration)",
                arabicDisplay: nil,
                options: [],
                correctIndex: 0
            ))
        }

        // Ensure exactly 6 questions (trim or pad)
        while result.count > GameConstants.Checkpoint.questionsCount {
            result.removeLast()
        }

        questions = result
        progressValue = 0
    }
}

#Preview {
    CheckpointTestView(afterLevel: 4)
        .environmentObject(DataManager.shared)
        .environmentObject(LanguageManager())
}
