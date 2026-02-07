import SwiftUI
import Speech

struct MistakesReviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager

    private let initialFocus: (String, String)?
    @State private var pendingFocus: (String, String)?
    
    @State private var currentMistake: MistakeItem?
    @State private var currentLetter: ArabicLetter?
    @State private var currentForm: LetterFormType = .isolated
    @State private var currentWord: ArabicWord?
    @State private var currentPhrase: ArabicPhrase?
    @State private var currentBaseLetter: ArabicLetter?
    @State private var currentVowel: ArabicVowel?
    @State private var wordOptions: [ArabicWord] = []
    @State private var phraseOptions: [ArabicPhrase] = []
    @State private var vowelOptions: [ArabicVowel] = []
    
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackColor = Color.green
    @State private var feedbackIcon = "checkmark.circle.fill"
    @State private var showExitAlert = false
    
    @State private var isProcessingSuccess = false
    
    @State private var stepId = UUID()

    init(focusItemId: String? = nil, focusItemType: String? = nil) {
        if let id = focusItemId, let type = focusItemType {
            self.initialFocus = (id, type)
        } else {
            self.initialFocus = nil
        }
        _pendingFocus = State(initialValue: initialFocus)
    }
    
    private func resetPartialProgress() {
        for index in dataManager.mistakes.indices {
            if dataManager.mistakes[index].correctionCount == 1 {
                dataManager.mistakes[index].correctionCount = 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if dataManager.mistakes.isEmpty {
                    emptyStateView
                } else if let mistake = currentMistake {
                    progressIndicatorView(mistake: mistake)
                        .padding(.bottom, 8)
                    
                    contentView(for: mistake)
                        .id(stepId)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(!isProcessingSuccess)
                } else {
                    Spacer()
                    ProgressView().tint(.noorGold)
                    Spacer()
                }
            }
            
            if showExitAlert { exitAlertView }
            if showFeedback { feedbackOverlay }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { loadNextMistake() }
    }
    
    
    private var headerView: some View {
        HStack {
            Button(action: {
                let hasPartialProgress = dataManager.mistakes.contains { $0.correctionCount == 1 }
                if hasPartialProgress {
                    withAnimation(.spring()) { showExitAlert = true }
                } else {
                    dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text(t("Retour"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.noorSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                )
            }
            .disabled(isProcessingSuccess)
            
            Spacer()
            
            Text(t("Correction"))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noorText)
            
            Spacer()
            
            if !dataManager.mistakes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                    Text("\(dataManager.mistakes.count)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.red.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.red.opacity(0.1)))
            } else {
                Color.clear.frame(width: 44, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
    
    
    private func progressIndicatorView(mistake: MistakeItem) -> some View {
        let isValidationStep = mistake.correctionCount >= 1
        
        return HStack(spacing: 8) {
            Circle()
                .fill(isValidationStep ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Capsule()
                .fill(Color.noorSecondary.opacity(0.2))
                .frame(width: 20, height: 2)
            
            Circle()
                .stroke(isValidationStep ? Color.orange : Color.noorSecondary.opacity(0.3), lineWidth: 2)
                .background(Circle().fill(Color.clear))
                .frame(width: 8, height: 8)
            
            Text(isValidationStep ? t("Validation finale") : t("Correction"))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isValidationStep ? .orange : .noorSecondary)
                .padding(.leading, 6)
                .textCase(.uppercase)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Capsule().fill(Color.noorSecondary.opacity(0.05)))
    }
    
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            ZStack {
                Circle().fill(Color.green.opacity(0.1)).frame(width: 140, height: 140)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70)).foregroundColor(.green)
                    .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
            }
            VStack(spacing: 12) {
                Text(t("Tout est propre !"))
                    .font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(.noorText)
                Text(t("Aucune erreur à corriger pour le moment."))
                    .font(.system(size: 16, weight: .medium)).foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            Button(action: { dismiss() }) {
                Text(t("Continuer"))
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.noorGold).cornerRadius(18)
                    .shadow(color: .noorGold.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 40).padding(.top, 20)
            Spacer()
        }
    }
    
    private var exitAlertView: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { showExitAlert = false } }
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44)).foregroundColor(.orange).padding(.top, 8)
                    VStack(spacing: 8) {
                        Text(t("Déjà fatigué ?")).font(.title3).bold().foregroundColor(.noorText)
                        Text(t("Si tu quittes maintenant, la progression de l'erreur en cours sera perdue."))
                            .font(.subheadline).foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                }
                HStack(spacing: 16) {
                    Button(action: { resetPartialProgress(); dismiss() }) {
                        Text(t("Quitter")).font(.headline).foregroundColor(.red)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.red.opacity(0.1)).cornerRadius(16)
                    }
                    Button(action: { withAnimation(.spring()) { showExitAlert = false } }) {
                        Text(t("Continuer")).font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.noorGold).cornerRadius(16)
                    }
                }
            }
            .padding(24).background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
            .cornerRadius(32).shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            .padding(.horizontal, 30).transition(.scale.combined(with: .opacity))
        }
        .zIndex(100)
    }
    
    private var feedbackOverlay: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .allowsHitTesting(true)
            
            VStack {
                HStack(spacing: 16) {
                    Image(systemName: feedbackIcon).font(.title2).fontWeight(.bold)
                    Text(feedbackMessage).font(.headline).fontWeight(.bold)
                }
                .foregroundColor(.white).padding(.horizontal, 24).padding(.vertical, 16)
                .background(Capsule().fill(feedbackColor).shadow(color: feedbackColor.opacity(0.4), radius: 10, y: 5))
                .padding(.top, 70)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
        .zIndex(200)
    }
    
    
    private func loadNextMistake() {
        isProcessingSuccess = false
        
        guard !dataManager.mistakes.isEmpty else { currentMistake = nil; return }
        
        let selectedMistake = selectNextMistake()
        
        if let randomMistake = selectedMistake {
            currentMistake = randomMistake
            currentLetter = nil
            currentWord = nil
            currentPhrase = nil
            currentBaseLetter = nil
            currentVowel = nil
            wordOptions = []
            phraseOptions = []
            vowelOptions = []
            
            switch randomMistake.itemType {
            case "letter":
                if let id = Int(randomMistake.itemId) {
                    currentLetter = ArabicLetter.letter(byId: id)
                    currentForm = LetterFormType(rawValue: randomMistake.formType ?? "") ?? .isolated
                }
            case "speaking":
                if let id = Int(randomMistake.itemId) {
                    currentLetter = ArabicLetter.letter(byId: id)
                }
            case "word":
                if let id = Int(randomMistake.itemId),
                   let word = CourseContent.words.first(where: { $0.id == id }) {
                    currentWord = word
                    wordOptions = makeWordOptions(target: word)
                }
            case "phrase":
                if let id = Int(randomMistake.itemId),
                   let phrase = CourseContent.phrases.first(where: { $0.id == id }) {
                    currentPhrase = phrase
                    phraseOptions = makePhraseOptions(target: phrase)
                }
            case "solarLunar":
                if let id = Int(randomMistake.itemId),
                   let letter = ArabicLetter.letter(byId: id) {
                    currentLetter = letter
                }
            case "vowel":
                if let (baseId, vowelId) = parseVowelMistake(randomMistake.itemId),
                   let base = ArabicLetter.letter(byId: baseId),
                   let vowel = CourseContent.vowels.first(where: { $0.id == vowelId }) {
                    currentBaseLetter = base
                    currentVowel = vowel
                    vowelOptions = makeVowelOptions(target: vowel)
                }
            default:
                break
            }
            
            if !isMistakeReady(randomMistake) {
                dataManager.removeMistake(randomMistake)
                loadNextMistake()
                return
            }
            stepId = UUID()
        }
    }
    
    private func handleSuccess(for mistake: MistakeItem) {
        guard !isProcessingSuccess else { return }
        isProcessingSuccess = true
        
        let isFullyCorrected = dataManager.recordMistakeSuccess(item: mistake)
        FeedbackManager.shared.success()
        
        withAnimation(.spring()) {
            showFeedback = true
            if isFullyCorrected {
                feedbackMessage = t("Confirmation réussie ! Erreur effacée.")
                feedbackColor = .green; feedbackIcon = "checkmark.seal.fill"
            } else {
                feedbackMessage = t("C'est noté ! À confirmer plus tard.")
                feedbackColor = .orange; feedbackIcon = "clock.arrow.circlepath"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showFeedback = false }
            loadNextMistake()
        }
    }
    
    private func t(_ key: String) -> String {
        if languageManager.currentLanguage == .french { return key }
        switch key {
        case "Retour": return "Back"
        case "Correction": return "Correction"
        case "Validation finale": return "Final Check"
        case "Erreur": return "Mistake"
        case "Entraînement": return "Practice"
        case "restant(s)": return "remaining"
        case "Tout est propre !": return "All Clean!"
        case "Aucune erreur à corriger pour le moment.": return "No mistakes to correct right now."
        case "Continuer": return "Continue"
        case "Déjà fatigué ?": return "Tired already?"
        case "Si tu quittes maintenant, la progression de l'erreur en cours sera perdue.": return "If you quit now, current progress will be lost."
        case "Quitter": return "Quit"
        case "Confirmation réussie ! Erreur effacée.": return "Confirmed! Mistake cleared."
        case "C'est noté ! À confirmer plus tard.": return "Good! To be confirmed later."
        default: return key
        }
    }

    @ViewBuilder
    private func contentView(for mistake: MistakeItem) -> some View {
        switch mistake.itemType {
        case "letter":
            if let letter = currentLetter {
                FreeDrawingStep(
                    letter: letter,
                    formType: currentForm,
                    onComplete: {
                        handleSuccess(for: mistake)
                    },
                    isChallengeMode: false
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case "word":
            if let word = currentWord {
                WordAssemblyView(
                    word: word,
                    onCompletion: {
                        handleSuccess(for: mistake)
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case "phrase":
            if let phrase = currentPhrase {
                PhraseChoiceExercise(
                    prompt: languageManager.currentLanguage == .english ? phrase.translationEn : phrase.translationFr,
                    options: phraseOptions,
                    correctId: phrase.id,
                    onAnswer: { correct in
                        if correct {
                            handleSuccess(for: mistake)
                        }
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case "vowel":
            if let base = currentBaseLetter, let vowel = currentVowel {
                VowelChoiceExercise(
                    baseLetter: base,
                    targetVowel: vowel,
                    options: vowelOptions,
                    onAnswer: { correct in
                        if correct {
                            handleSuccess(for: mistake)
                        }
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case "solarLunar":
            if let letter = currentLetter {
                SolarLunarMistakeExercise(
                    letter: letter,
                    onAnswer: { correct in
                        if correct {
                            handleSuccess(for: mistake)
                        }
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        case "speaking":
            if let letter = currentLetter {
                SpeakingMistakeExercise(
                    letter: letter,
                    onSuccess: {
                        handleSuccess(for: mistake)
                    }
                )
            } else {
                ProgressView().tint(.noorGold)
            }
        default:
            ProgressView().tint(.noorGold)
        }
    }
    
    private func makeWordOptions(target: ArabicWord) -> [ArabicWord] {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage).words
        let source = pool.count >= 4 ? pool : CourseContent.words
        let options = source.filter { $0.id != target.id }.shuffled().prefix(3)
        var final = Array(options) + [target]
        final.shuffle()
        return final
    }
    
    private func makePhraseOptions(target: ArabicPhrase) -> [ArabicPhrase] {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage).phrases
        let source = pool.count >= 4 ? pool : CourseContent.phrases
        let options = source.filter { $0.id != target.id }.shuffled().prefix(3)
        var final = Array(options) + [target]
        final.shuffle()
        return final
    }
    
    private func makeVowelOptions(target: ArabicVowel) -> [ArabicVowel] {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage).vowels
        let source = pool.count >= 3 ? pool : CourseContent.vowels
        let options = source.filter { $0.id != target.id }.shuffled().prefix(2)
        var final = Array(options) + [target]
        final.shuffle()
        return final
    }
    
    private func parseVowelMistake(_ itemId: String) -> (Int, Int)? {
        let parts = itemId.split(separator: ":")
        guard parts.count == 2, let baseId = Int(parts[0]), let vowelId = Int(parts[1]) else {
            return nil
        }
        return (baseId, vowelId)
    }

    private func isMistakeReady(_ mistake: MistakeItem) -> Bool {
        switch mistake.itemType {
        case "letter":
            return currentLetter != nil
        case "word":
            return currentWord != nil && !wordOptions.isEmpty
        case "phrase":
            return currentPhrase != nil && !phraseOptions.isEmpty
        case "vowel":
            return currentBaseLetter != nil && currentVowel != nil && !vowelOptions.isEmpty
        case "solarLunar":
            return currentLetter != nil
        case "speaking":
            return currentLetter != nil
        default:
            return false
        }
    }

    private func selectNextMistake() -> MistakeItem? {
        if let focus = pendingFocus,
           let targeted = dataManager.mistakes.first(where: { $0.itemId == focus.0 && $0.itemType == focus.1 }) {
            pendingFocus = nil
            return targeted
        }
        
        let ordered = dataManager.mistakes.sorted { lhs, rhs in
            if lhs.correctionCount != rhs.correctionCount {
                return lhs.correctionCount < rhs.correctionCount
            }
            return lhs.lastMistakeDate > rhs.lastMistakeDate
        }
        return ordered.first
    }
}

private struct SolarLunarMistakeExercise: View {
    let letter: ArabicLetter
    let onAnswer: (Bool) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selected: ArabicLetter.LetterCategory? = nil
    @State private var locked = false
    
    var body: some View {
        let isEnglish = languageManager.currentLanguage == .english
        VStack(spacing: 20) {
            Text(isEnglish ? "Solar or lunar?" : "Solaire ou lunaire ?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(letter.isolated)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(letter.transliteration)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            HStack(spacing: 16) {
                SolarLunarChoiceButton(
                    title: LocalizedStringKey(isEnglish ? "Solar" : "Solaire"),
                    icon: "sun.max.fill",
                    color: .orange,
                    isSelected: selected == .solar,
                    isCorrect: selected == .solar ? letter.isSolar : nil
                ) {
                    handleSelect(.solar)
                }
                
                SolarLunarChoiceButton(
                    title: LocalizedStringKey(isEnglish ? "Lunar" : "Lunaire"),
                    icon: "moon.fill",
                    color: .blue,
                    isSelected: selected == .lunar,
                    isCorrect: selected == .lunar ? letter.isLunar : nil
                ) {
                    handleSelect(.lunar)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func handleSelect(_ answer: ArabicLetter.LetterCategory) {
        guard !locked else { return }
        selected = answer
        let isCorrect = answer == letter.letterCategory
        if isCorrect {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            onAnswer(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                selected = nil
            }
        }
    }
}

private struct SolarLunarChoiceButton: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        if let isCorrect = isCorrect, isSelected {
            return isCorrect ? .green : .red
        }
        return color.opacity(isSelected ? 0.85 : 0.6)
    }
}

private struct SpeakingMistakeExercise: View {
    let letter: ArabicLetter
    let onSuccess: () -> Void

    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var speechManager = SpeechManager()
    @State private var isListening = false
    @State private var feedbackMessage = ""
    @State private var showSuccess = false

    private var isEnglish: Bool { languageManager.currentLanguage == .english }

    var body: some View {
        VStack(spacing: 24) {
            Text(isEnglish ? "Pronounce this letter" : "Prononce cette lettre")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.noorText)

            Text(letter.isolated)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.noorText)

            Text(letter.transliteration)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.noorGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.noorGold.opacity(0.12)))

            Button(action: {
                AudioManager.shared.playLetter(letter.isolated)
                HapticManager.shared.impact(.light)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(isEnglish ? "Listen" : "Écouter")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.purple)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.purple.opacity(0.1)))
            }

            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(showSuccess ? .green : .red)
                    .transition(.opacity)
            }

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isListening ? [.noorGold, .orange] : [.white, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: isListening ? .orange.opacity(0.4) : .black.opacity(0.1), radius: 12, y: 6)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(isListening ? .white : .noorGold)
                    )
                    .scaleEffect(isListening ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3), value: isListening)
            }
            .frame(width: 100, height: 100)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isListening { startListening() }
                    }
                    .onEnded { _ in
                        stopListening()
                    }
            )

            Text(isEnglish ? "Hold to speak" : "Maintiens pour parler")
                .font(.subheadline)
                .foregroundColor(.noorSecondary.opacity(0.8))
        }
        .onAppear {
            speechManager.requestAuthorization()
        }
        .onChange(of: speechManager.recognizedText) { _, newText in
            if isListening && !showSuccess {
                let cleaned = newText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if PhoneticDictionary.shared.isMatch(heard: cleaned, target: letter) {
                    handleSuccess()
                }
            }
        }
    }

    private func startListening() {
        guard speechManager.authorizationStatus == .authorized else {
            feedbackMessage = isEnglish ? "Microphone permission required" : "Autorisation micro requise"
            return
        }
        speechManager.recognizedText = ""
        showSuccess = false
        feedbackMessage = isEnglish ? "Listening..." : "J'écoute..."
        isListening = true
        HapticManager.shared.impact(.medium)
        do { try speechManager.startRecording() }
        catch { isListening = false }
    }

    private func stopListening() {
        speechManager.stopRecording()
        HapticManager.shared.impact(.light)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isListening = false
            if !showSuccess {
                let recognized = speechManager.recognizedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if PhoneticDictionary.shared.isMatch(heard: recognized, target: letter) {
                    handleSuccess()
                } else {
                    feedbackMessage = recognized.isEmpty
                        ? (isEnglish ? "I didn't hear anything..." : "Je n'ai rien entendu...")
                        : (isEnglish ? "Not quite..." : "Pas tout à fait...")
                    FeedbackManager.shared.error()
                }
            }
        }
    }

    private func handleSuccess() {
        guard !showSuccess else { return }
        showSuccess = true
        isListening = false
        speechManager.stopRecording()
        feedbackMessage = isEnglish ? "Well done!" : "Bravo !"
        FeedbackManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onSuccess()
        }
    }
}

