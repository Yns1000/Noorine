import SwiftUI

struct PhraseLessonView: View {
    let levelNumber: Int
    let onCompletion: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentPhraseIndex = 0
    @State private var phase: LessonPhase = .presentation
    
    @State private var userAnswer: [PhraseWord] = []
    @State private var availableWords: [PhraseWord] = []
    
    @State private var wordsToConstruct: [ArabicWord] = []
    @State private var currentWordIndex = 0
    
    @State private var showSuccess = false
    @State private var showError = false
    @State private var completedPhrases = 0
    @State private var loggedMistakeIds: Set<Int> = []
    
    private var phrases: [PhraseData] {
        let levelPhrases = phrasesForLevel()
        if !levelPhrases.isEmpty {
            return levelPhrases.map { PhraseData.from($0) }
        }
        
        let all = CourseContent.phrases
        if !all.isEmpty {
            return all.map { PhraseData.from($0) }
        }
        
        return PhraseData.samplePhrases
    }
    
    private var currentPhrase: PhraseData? {
        phrases.indices.contains(currentPhraseIndex) ? phrases[currentPhraseIndex] : nil
    }
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    private var currentWordToConstruct: ArabicWord? {
        wordsToConstruct.indices.contains(currentWordIndex) ? wordsToConstruct[currentWordIndex] : nil
    }
    
    enum LessonPhase {
        case presentation
        case listening
        case wordBuilding
        case building
        case complete
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if let phrase = currentPhrase {
                    switch phase {
                    case .presentation:
                        presentationView(phrase)
                    case .listening:
                        listeningView(phrase)
                    case .wordBuilding:
                        if let word = currentWordToConstruct {
                            wordBuildingView(phrase, targetWord: word)
                                .id("word-\(word.id)-\(currentWordIndex)")
                        } else {
                            buildingView(phrase)
                                .onAppear {
                                    withAnimation(.spring(response: 0.4)) {
                                        phase = .building
                                        setupBuildingPhase(phrase)
                                    }
                                }
                        }
                    case .building:
                        buildingView(phrase)
                    case .complete:
                        completionView
                    }
                }
            }
        }
        .onAppear { setupPhrase() }
        .onDisappear { logCurrentPhraseMistakeOnQuit() }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                logCurrentPhraseMistakeOnQuit()
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
            }

            Spacer()

            VStack(spacing: 4) {
                Text("\(currentPhraseIndex + 1)/\(phrases.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.noorText)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(currentPhraseIndex) / CGFloat(max(1, phrases.count)))
                    }
                }
                .frame(width: 100, height: 6)
            }
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func presentationView(_ phrase: PhraseData) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.noorGold.opacity(0.8))
                
                Text(isEnglish ? "New Phrase" : "Nouvelle Phrase")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            VStack(spacing: 16) {
                Text(phrase.arabic)
                    .font(.system(size: 42))
                    .foregroundColor(.noorText)
                    .multilineTextAlignment(.center)
                
                Text(phrase.transliteration)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.noorGold)
                
                Text(isEnglish ? phrase.translationEn : phrase.translationFr)
                    .font(.system(size: 18))
                    .foregroundColor(.noorSecondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 24)
            
            Button(action: {
                AudioManager.shared.playSound(named: phrase.audioName)
                HapticManager.shared.impact(.light)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 18))
                    Text(isEnglish ? "Listen" : "Écouter")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.noorGold)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(Color.noorGold.opacity(0.12))
                )
            }
            
            Spacer()
            
            ActionButton(title: isEnglish ? "Continue" : "Continuer") {
                withAnimation(.spring(response: 0.4)) {
                    phase = .listening
                }
            }
        }
    }
    
        
    private func wordBuildingView(_ phrase: PhraseData, targetWord: ArabicWord) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(0..<wordsToConstruct.count, id: \.self) { index in
                    Circle()
                        .fill(index < currentWordIndex ? Color.green : (index == currentWordIndex ? Color.noorGold : Color.gray.opacity(0.3)))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            Text(isEnglish ? "Build word \(currentWordIndex + 1) of \(wordsToConstruct.count)" : "Construis le mot \(currentWordIndex + 1) sur \(wordsToConstruct.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.noorSecondary)
                .padding(.bottom, 8)
            
            WordAssemblyView(word: targetWord, onCompletion: {
                if currentWordIndex < wordsToConstruct.count - 1 {
                    withAnimation(.spring(response: 0.4)) {
                        currentWordIndex += 1
                    }
                } else {
                    withAnimation(.spring(response: 0.4)) {
                        phase = .building
                        setupBuildingPhase(phrase)
                    }
                }
            })
        }
    }
    
    private func setupWordBuilding(_ phrase: PhraseData) {
        guard let originalPhrase = phrasesForLevel().first(where: { $0.id == phrase.id }) ?? 
              CourseContent.phrases.first(where: { $0.id == phrase.id }) else {
            phase = .building
            setupBuildingPhase(phrase)
            return
        }
        
        var orderedWords: [ArabicWord] = []
        var seenIds: Set<Int> = []
        
        for wordId in originalPhrase.wordIds {
            guard !seenIds.contains(wordId) else { continue }
            if let matchedWord = CourseContent.words.first(where: { $0.id == wordId }) {
                orderedWords.append(matchedWord)
                seenIds.insert(wordId)
            }
        }
        
        guard !orderedWords.isEmpty else {
            phase = .building
            setupBuildingPhase(phrase)
            return
        }
        
        wordsToConstruct = orderedWords
        currentWordIndex = 0
    }
    
    private func listeningView(_ phrase: PhraseData) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(isEnglish ? "Listen and repeat" : "Écoute et répète")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            Button(action: {
                AudioManager.shared.playSound(named: phrase.audioName)
                HapticManager.shared.impact(.medium)
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.noorGold, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .noorGold.opacity(0.4), radius: 20, y: 8)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
            }
            
            Text(phrase.arabic)
                .font(.system(size: 36))
                .foregroundColor(.noorText)
                .opacity(0.6)
            
            Spacer()
            
            ActionButton(title: isEnglish ? "I understand" : "J'ai compris") {
                withAnimation(.spring(response: 0.4)) {
                    phase = .wordBuilding
                    setupWordBuilding(phrase)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AudioManager.shared.playSound(named: phrase.audioName)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AudioManager.shared.playSound(named: phrase.audioName)
            }
        }
    }
    
    private func buildingView(_ phrase: PhraseData) -> some View {
        VStack(spacing: 24) {
            Spacer()

            HStack(spacing: 10) {
                Text(isEnglish ? "Build the phrase" : "Construis la phrase")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorSecondary)

                Button(action: {
                    AudioManager.shared.playSound(named: phrase.audioName)
                    HapticManager.shared.impact(.light)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.noorGold)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.noorGold.opacity(0.12)))
                }
            }

            Text(isEnglish ? phrase.translationEn : phrase.translationFr)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(phrase.transliteration)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.noorGold)
                .padding(.bottom, 8)

            answerSlots(phrase)
            
            Spacer().frame(height: 20)
            
            wordBank
            
            Spacer()
            
            if showSuccess {
                ActionButton(title: isEnglish ? "Next" : "Suivant") {
                    nextPhrase()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .modifier(ShakeModifier(shakes: showError ? 2 : 0))
        .animation(.default, value: showError)
    }
    
    private func answerSlots(_ phrase: PhraseData) -> some View {
        HStack(spacing: 12) {
            ForEach(0..<phrase.words.count, id: \.self) { index in
                if index < userAnswer.count {
                    WordSlot(
                        word: userAnswer[index],
                        isCorrect: showSuccess,
                        onTap: { removeWord(at: index) }
                    )
                } else {
                    EmptySlot(isHighlighted: index == userAnswer.count)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding(.horizontal, 16)
    }
    
    private var wordBank: some View {
        PhraseFlowLayout(spacing: 12) {
            ForEach(availableWords) { word in
                WordChip(word: word) {
                    addWord(word)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var completionView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text(isEnglish ? "Lesson Complete!" : "Leçon terminée !")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(isEnglish ? "\(phrases.count) phrases learned" : "\(phrases.count) phrases apprises")
                    .font(.subheadline)
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            ActionButton(title: isEnglish ? "Finish" : "Terminer") {
                onCompletion()
                dismiss()
            }
        }
    }
    
    private func phrasesForLevel() -> [ArabicPhrase] {
        let levels = CourseContent.getLevels(language: languageManager.currentLanguage)
        guard let level = levels.first(where: { $0.id == levelNumber && $0.type == .phrases }) else {
            return []
        }
        
        let ids = Set(level.contentIds)
        guard !ids.isEmpty else { return [] }
        
        return CourseContent.phrases.filter { ids.contains($0.id) }
    }
    
    private func logCurrentPhraseMistakeOnQuit() {
        guard phase != .complete, let phrase = currentPhrase else { return }
        if !loggedMistakeIds.contains(phrase.id) {
            loggedMistakeIds.insert(phrase.id)
            dataManager.addMistake(itemId: String(phrase.id), type: "phrase")
        }
    }

    private func setupPhrase() {
        guard let phrase = currentPhrase else { return }
        userAnswer = []
        showSuccess = false
        showError = false
        setupBuildingPhase(phrase)
    }
    
    private func setupBuildingPhase(_ phrase: PhraseData) {
        let correctWords = phrase.words.enumerated().map { index, word in
            PhraseWord(id: index, arabic: word.arabic, isDistractor: false)
        }

        let phraseArabicSet = Set(phrase.words.map { $0.arabic })
        let validDistractors = PhraseData.distractorWords.filter { !phraseArabicSet.contains($0) }

        let distractors = validDistractors.shuffled().prefix(2).enumerated().map { index, word in
            PhraseWord(id: 100 + index, arabic: word, isDistractor: true)
        }

        availableWords = (correctWords + distractors).shuffled()
        userAnswer = []
    }
    
    private func addWord(_ word: PhraseWord) {
        guard let phrase = currentPhrase else { return }
        guard userAnswer.count < phrase.words.count else { return }
        
        withAnimation(.spring(response: 0.3)) {
            userAnswer.append(word)
            availableWords.removeAll { $0.id == word.id }
        }
        
        HapticManager.shared.impact(.light)
        
        if userAnswer.count == phrase.words.count {
            checkAnswer(phrase)
        }
    }
    
    private func removeWord(at index: Int) {
        guard !showSuccess else { return }
        
        let word = userAnswer[index]
        withAnimation(.spring(response: 0.3)) {
            userAnswer.remove(at: index)
            availableWords.append(word)
            availableWords.shuffle()
        }
        
        HapticManager.shared.impact(.light)
    }
    
    private func checkAnswer(_ phrase: PhraseData) {
        let isCorrect = userAnswer.enumerated().allSatisfy { index, word in
            !word.isDistractor && word.arabic == phrase.words[index].arabic
        }
        
        if isCorrect {
            withAnimation(.spring(response: 0.4)) {
                showSuccess = true
            }
            FeedbackManager.shared.success()
            completedPhrases += 1
        } else {
            showError = true
            FeedbackManager.shared.error()
            
            if !loggedMistakeIds.contains(phrase.id) {
                loggedMistakeIds.insert(phrase.id)
                dataManager.addMistake(itemId: String(phrase.id), type: "phrase")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4)) {
                    showError = false
                    setupBuildingPhase(phrase)
                }
            }
        }
    }
    
    private func nextPhrase() {
        withAnimation(.spring(response: 0.4)) {
            if currentPhraseIndex < phrases.count - 1 {
                currentPhraseIndex += 1
                phase = .presentation
                setupPhrase()
            } else {
                phase = .complete
            }
        }
    }
}

struct PhraseWord: Identifiable, Equatable {
    let id: Int
    let arabic: String
    let isDistractor: Bool
}

struct PhraseData {
    let id: Int
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationFr: String
    let words: [WordPart]
    let audioName: String
    
    struct WordPart {
        let arabic: String
        let transliteration: String
    }
    
    static let distractorWords = ["هُوَ", "هِيَ", "مِن", "إلى", "عَلى"]
    
    static func from(_ phrase: ArabicPhrase) -> PhraseData {
        let wordParts = makeWordParts(from: phrase)
        return PhraseData(
            id: phrase.id,
            arabic: phrase.arabic,
            transliteration: phrase.transliteration,
            translationEn: phrase.translationEn,
            translationFr: phrase.translationFr,
            words: wordParts,
            audioName: phrase.audioName ?? phrase.arabic
        )
    }
    
    private static func makeWordParts(from phrase: ArabicPhrase) -> [WordPart] {
        let tokens = phrase.arabic.split(separator: " ").map { String($0) }

        let wordsById = CourseContent.words.reduce(into: [Int: ArabicWord]()) { $0[$1.id] = $1 }
        let knownWords = phrase.wordIds.compactMap { wordsById[$0] }

        return tokens.map { token in
            let clean = token.replacingOccurrences(of: "؟", with: "")
            if let match = knownWords.first(where: { $0.arabic == token || $0.arabic == clean }) {
                return WordPart(arabic: token, transliteration: match.transliteration)
            }
            return WordPart(arabic: token, transliteration: "")
        }
    }
    
    static let samplePhrases: [PhraseData] = [
        PhraseData(
            id: 1,
            arabic: "أَنَا طَالِب",
            transliteration: "ana talib",
            translationEn: "I am a student",
            translationFr: "Je suis étudiant",
            words: [
                WordPart(arabic: "أَنَا", transliteration: "ana"),
                WordPart(arabic: "طَالِب", transliteration: "talib")
            ],
            audioName: "phrase_ana_talib"
        ),
        PhraseData(
            id: 2,
            arabic: "هٰذَا كِتَاب",
            transliteration: "hatha kitab",
            translationEn: "This is a book",
            translationFr: "C'est un livre",
            words: [
                WordPart(arabic: "هٰذَا", transliteration: "hatha"),
                WordPart(arabic: "كِتَاب", transliteration: "kitab")
            ],
            audioName: "phrase_hatha_kitab"
        ),
        PhraseData(
            id: 3,
            arabic: "السَّلَامُ عَلَيْكُم",
            transliteration: "as-salamu alaykum",
            translationEn: "Peace be upon you",
            translationFr: "La paix soit sur vous",
            words: [
                WordPart(arabic: "السَّلَامُ", transliteration: "as-salamu"),
                WordPart(arabic: "عَلَيْكُم", transliteration: "alaykum")
            ],
            audioName: "phrase_salam"
        ),
        PhraseData(
            id: 4,
            arabic: "مَا اسْمُكَ",
            transliteration: "ma ismuka",
            translationEn: "What is your name?",
            translationFr: "Comment tu t'appelles ?",
            words: [
                WordPart(arabic: "مَا", transliteration: "ma"),
                WordPart(arabic: "اسْمُكَ", transliteration: "ismuka")
            ],
            audioName: "phrase_ma_ismuka"
        ),
        PhraseData(
            id: 5,
            arabic: "اسْمِي أَحْمَد",
            transliteration: "ismi Ahmad",
            translationEn: "My name is Ahmad",
            translationFr: "Je m'appelle Ahmad",
            words: [
                WordPart(arabic: "اسْمِي", transliteration: "ismi"),
                WordPart(arabic: "أَحْمَد", transliteration: "Ahmad")
            ],
            audioName: "phrase_ismi_ahmad"
        )
    ]
}

struct WordSlot: View {
    let word: PhraseWord
    let isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(word.arabic)
                .font(.system(size: 22, weight: .medium))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .foregroundColor(isCorrect ? .green : .noorText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCorrect ? Color.green.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCorrect ? Color.green : Color.clear, lineWidth: 1.5)
                        )
                )
                
        }
        .buttonStyle(.plain)
        .disabled(isCorrect)
    }
}

struct LetterSlot: View {
    let letter: ArabicLetter
    let isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(letter.isolated)
                .font(.system(size: 28))
                .foregroundColor(isCorrect ? .green : .noorText)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCorrect ? Color.green.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCorrect ? Color.green : Color.clear, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(isCorrect)
    }
}

struct EmptyLetterSlot: View {
    let isHighlighted: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                isHighlighted ? Color.noorGold : Color(.systemGray4),
                style: StrokeStyle(lineWidth: 2, dash: [6])
            )
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHighlighted ? Color.noorGold.opacity(0.05) : Color.clear)
            )
    }
}

struct LetterChip: View {
    let letter: ArabicLetter
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(letter.isolated)
                .font(.system(size: 28))
                .foregroundColor(.noorText)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

struct EmptySlot: View {
    let isHighlighted: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(
                isHighlighted ? Color.noorGold : Color(.systemGray4),
                style: StrokeStyle(lineWidth: 1.5, dash: [4])
            )
            .frame(width: 60, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHighlighted ? Color.noorGold.opacity(0.05) : Color.clear)
            )
    }
}

struct WordChip: View {
    let word: PhraseWord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(word.arabic)
                .font(.system(size: 22, weight: .medium))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .foregroundColor(.noorText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.noorGold, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}

struct PhraseFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }
    
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}

struct ShakeModifier: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 10, y: 0))
    }
}


