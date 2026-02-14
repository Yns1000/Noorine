import SwiftUI
import UniformTypeIdentifiers

struct LevelDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    let levelNumber: Int
    let title: String
    
    @State private var selectedLetter: ArabicLetter?
    @State private var autoOpenedSingleLetter = false
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var letters: [ArabicLetter] {
        ArabicLetter.letters(forLevel: levelNumber)
    }
    
    private var isSingleLetterLevel: Bool {
        letters.count == 1
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    LevelDetailHeader(
                        title: title,
                        masteredCount: masteredCount,
                        totalCount: letters.count
                    )
                    .padding(.top, 10)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(letters) { letter in
                            LetterCard(
                                letter: letter,
                                isMastered: dataManager.isLetterMastered(letterId: letter.id, inLevel: levelNumber)
                            )
                            .onTapGesture {
                                selectedLetter = letter
                            }
                        }
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey(isEnglish ? "Back" : "Retour"))
                    }
                    .foregroundColor(.noorGold)
                }
            }
        }
        .fullScreenCover(item: $selectedLetter) { letter in
            if let index = letters.firstIndex(where: { $0.id == letter.id }), index + 1 < letters.count {
                LetterLessonView(
                    letter: letter,
                    levelNumber: levelNumber,
                )
                .environmentObject(dataManager)
                .id(letter.id)
            } else {
                LetterLessonView(
                    letter: letter,
                    levelNumber: levelNumber,
                )
                .environmentObject(dataManager)
                .id(letter.id)
            }
        }
        .onAppear {
            if isSingleLetterLevel && !autoOpenedSingleLetter {
                autoOpenedSingleLetter = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedLetter = letters.first
                }
            }
        }
        .onChange(of: selectedLetter) { oldValue, newValue in
            if isSingleLetterLevel && oldValue != nil && newValue == nil {
                dismiss()
            }
        }
    }
    
    var masteredCount: Int {
        letters.filter { dataManager.isLetterMastered(letterId: $0.id, inLevel: levelNumber) }.count
    }
}

struct LevelDetailHeader: View {
    @EnvironmentObject var languageManager: LanguageManager
    let title: String
    let masteredCount: Int
    let totalCount: Int
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(masteredCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedStringKey(isEnglish ? "\(masteredCount)/\(totalCount) letters mastered" : "\(masteredCount)/\(totalCount) lettres maîtrisées"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorGold)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.noorSecondary.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.noorGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

struct LetterCard: View {
    @Environment(\.colorScheme) var colorScheme
    let letter: ArabicLetter
    let isMastered: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isMastered ? Color.noorGold.opacity(0.15) : Color.noorSecondary.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Text(letter.isolated)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(isMastered ? .noorGold : .noorText)
                
                if isMastered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.noorGold)
                        .offset(x: 25, y: -25)
                }
            }
            
            Text(letter.transliteration)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.noorSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

#Preview {
    NavigationView {
        LevelDetailView(levelNumber: 1, title: "L'Alphabet (1-7)")
            .environmentObject(DataManager.shared)
    }
}
struct VowelLessonView: View {
    let levelNumber: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var currentStepIndex = 0

    @State private var steps: [VowelStep] = []
    
    
    enum VowelStep: Identifiable {
        case intro(ArabicVowel)
        case specialIntro(ArabicVowel)
        case example(ArabicVowel, VowelExample)
        case quiz(target: ArabicVowel, allVowels: [ArabicVowel], baseLetter: ArabicLetter)
        case completion
        
        var id: String {
            switch self {
            case .intro(let v): return "intro_\(v.id)"
            case .specialIntro(let v): return "special_intro_\(v.id)"
            case .example(let v, _): return "example_\(v.id)"
            case .quiz(let v, _, let l): return "quiz_\(v.id)_\(l.id)" 
            case .completion: return "completion"
            }
        }
    }
    
    var vowels: [ArabicVowel] {
        getVowels()
    }
    
    
    func loadSteps() {
        guard steps.isEmpty else { return }

        var sequence: [VowelStep] = []
        let loadedVowels = vowels

        let hasNewVowelTypes = loadedVowels.contains(where: { ![1, 2, 3].contains($0.id) })
        let isFirstExposure = (levelNumber == 2) || hasNewVowelTypes

        if isFirstExposure {
            for vowel in loadedVowels {
                if vowel.type == .sukun || vowel.type == .shadda || vowel.type.rawValue.contains("tanwin") {
                    sequence.append(.specialIntro(vowel))
                } else {
                    sequence.append(.intro(vowel))
                }
                
                if let firstExample = vowel.examples.first {
                    sequence.append(.example(vowel, firstExample))
                }
            }
        }

        var targetLetterIds: [Int] = []
        if let previousLevel = CourseContent.getLevels(language: languageManager.currentLanguage).first(where: { $0.id == levelNumber - 1 }),
           previousLevel.type == .alphabet {
            targetLetterIds = previousLevel.contentIds
        }

        if targetLetterIds.isEmpty {
            targetLetterIds = [2, 5, 8, 10, 12, 22, 24, 25]
        }

        let validLetterIds = targetLetterIds.filter { $0 >= 1 && $0 <= 29 }
        let uniqueTargetIds = Array(Set(validLetterIds)).shuffled().prefix(6)

        let baseVowelIds = [1, 2, 3]
        let baseVowels = baseVowelIds.compactMap { id in CourseContent.vowels.first(where: { $0.id == id }) }
        
        var quizVowelChoices: [ArabicVowel] = baseVowels
        for vowel in loadedVowels {
            if !quizVowelChoices.contains(where: { $0.id == vowel.id }) {
                quizVowelChoices.append(vowel)
            }
        }

        var quizSteps: [VowelStep] = []

        for baseId in uniqueTargetIds {
            if let baseLetter = ArabicLetter.letter(byId: baseId) {
                if let randomVowel = loadedVowels.randomElement() {
                    quizSteps.append(.quiz(target: randomVowel, allVowels: quizVowelChoices, baseLetter: baseLetter))
                }
            }
        }

        sequence.append(contentsOf: quizSteps.shuffled())
        sequence.append(.completion)

        self.steps = sequence
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        logRemainingVowelQuizMistakes()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }

                    Spacer()

                    if !steps.isEmpty, currentStepIndex < steps.count - 1 {
                        ProgressView(value: Double(currentStepIndex), total: Double(steps.count - 1))
                            .progressViewStyle(LinearProgressViewStyle(tint: .noorGold))
                            .frame(width: 100)
                    }
                }
                .padding()

                GeometryReader { geometry in
                    if !steps.isEmpty, currentStepIndex < steps.count {
                        VStack {
                            switch steps[currentStepIndex] {
                            case .intro(let vowel):
                                VowelIntroView(vowel: vowel)
                            case .specialIntro(let vowel):
                                SpecialVowelIntroView(vowel: vowel)
                            case .example(let vowel, let example):
                                VowelExampleView(vowel: vowel, example: example)
                            case .quiz(let target, let all, let baseLetter):
                                VowelQuizView(targetVowel: target, allVowels: all, baseLetter: baseLetter, onCorrect: {
                                    withAnimation {
                                        currentStepIndex += 1
                                    }
                                })
                            case .completion:
                                VowelCompletionView(levelNumber: levelNumber, onContinue: {
                                    dataManager.completeLevel(levelNumber: levelNumber)
                                    dismiss()
                                })
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        .id(steps[currentStepIndex].id)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                if !steps.isEmpty, currentStepIndex < steps.count - 1, !isQuizStep(steps[currentStepIndex]) {
                    Button(action: {
                        withAnimation(.spring()) {
                            currentStepIndex += 1
                        }
                    }) {
                        Text(languageManager.currentLanguage == .english ? "Continue" : "Continuer")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(16)
                            .shadow(color: .noorGold.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(24)
                }
            }
        }
        .onAppear {
            loadSteps()
        }
        .onDisappear {
            logRemainingVowelQuizMistakes()
        }
    }

    private func logRemainingVowelQuizMistakes() {
        for i in currentStepIndex..<steps.count {
            if case .quiz(let target, _, let baseLetter) = steps[i] {
                let mistakeId = "\(baseLetter.id):\(target.id)"
                dataManager.addMistake(itemId: mistakeId, type: "vowel")
            }
        }
    }
    
    func isQuizStep(_ step: VowelStep) -> Bool {
        if case .quiz = step { return true }
        return false
    }
    
    func getVowels() -> [ArabicVowel] {
        guard let levelDef = CourseContent.getLevels(language: languageManager.currentLanguage).first(where: { $0.id == levelNumber }),
              levelDef.type == .vowels else { return [] }
        return levelDef.contentIds.compactMap { id in CourseContent.vowels.first(where: { $0.id == id }) }
    }
}

struct VowelQuizView: View {
    let targetVowel: ArabicVowel
    let allVowels: [ArabicVowel]
    let baseLetter: ArabicLetter
    let onCorrect: () -> Void
    
    @State private var selectedVowelId: Int?
    @State private var isWrong = false
    @State private var showSuccess = false
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Which sound do you hear?" : "Quel son entends-tu ?"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
                .padding(.top)
            
            Button(action: {
                playTargetSound()
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 32))
                    Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Listen again" : "Réécouter"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.noorGold)
                        .shadow(color: .noorGold.opacity(0.4), radius: 20, y: 10)
                )
                .scaleEffect(isWrong ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isWrong)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    playTargetSound()
                }
            }
            
            Spacer()
            
            let columns = allVowels.count > 3 ? 2 : allVowels.count
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: columns)
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(allVowels) { vowel in
                    Button(action: {
                        handleSelection(vowel)
                    }) {
                        VStack(spacing: 8) {
                            Text(baseLetter.initial + vowel.symbol)
                                .font(.system(size: allVowels.count > 3 ? 48 : 64))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(foregroundColor(for: vowel))
                                .frame(height: allVowels.count > 3 ? 60 : 90)
                            
                            Text(vowel.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.noorSecondary.opacity(0.8))
                                .lineLimit(1)
                            
                            Text(getPhonetic(letter: baseLetter, vowel: vowel))
                                .font(.system(size: allVowels.count > 3 ? 16 : 20, weight: .bold, design: .rounded))
                                .foregroundColor(.noorGold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: allVowels.count > 3 ? 130 : 180)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(backgroundColor(for: vowel))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(borderColor(for: vowel), lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
                        )
                    }
                    .disabled(showSuccess)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            Spacer()
        }
    }
    
    
    func getPhonetic(letter: ArabicLetter, vowel: ArabicVowel) -> String {
        let key = cleanTransliteration(letter.transliteration)
        
        let consonant: String
        switch key {
        case "alif": consonant = "" 
        case "ba": consonant = "B"
        case "ta": consonant = "T"
        case "tha": consonant = "Th"
        case "jim": consonant = "J"
        case "ha": consonant = "Ḥ"
        case "kha": consonant = "Kh"
        case "dal": consonant = "D"
        case "dhal": consonant = "Dh"
        case "ra": consonant = "R"
        case "zay": consonant = "Z"
        case "sin": consonant = "S"
        case "shin": consonant = "Sh"
        case "sad": consonant = "Ṣ"
        case "dad": consonant = "Ḍ"
        case "ta_emphatic": consonant = "Ṭ"
        case "za_emphatic": consonant = "Ẓ"
        case "ayn": consonant = "ʿ"
        case "ghayn": consonant = "Gh"
        case "fa": consonant = "F"
        case "qaf": consonant = "Q"
        case "kaf": consonant = "K"
        case "lam": consonant = "L"
        case "mim": consonant = "M"
        case "nun": consonant = "N"
        case "ha_round": consonant = "H"
        case "waw": consonant = "W"
        case "ya": consonant = "Y"
        default: consonant = String(letter.transliteration.prefix(1))
        }
        
        switch vowel.type {
        case .sukun:
            return consonant
        case .shadda:
            return consonant + consonant
        default:
            return consonant + vowel.transliteration
        }
    }
    
    func backgroundColor(for vowel: ArabicVowel) -> Color {
        if let selected = selectedVowelId, selected == vowel.id {
            if vowel.id == targetVowel.id {
                return Color.green.opacity(0.15)
            } else {
                return Color.red.opacity(0.15)
            }
        }
        return Color(UIColor.secondarySystemGroupedBackground)
    }
    
    func borderColor(for vowel: ArabicVowel) -> Color {
        if let selected = selectedVowelId, selected == vowel.id {
            if vowel.id == targetVowel.id {
                return .green
            } else {
                return .red
            }
        }
        return .clear
    }
    
    func foregroundColor(for vowel: ArabicVowel) -> Color {
        if let selected = selectedVowelId, selected == vowel.id {
            if vowel.id == targetVowel.id {
                return .green
            } else {
                return .red
            }
        }
        return .noorText
    }
    
    
    func handleSelection(_ vowel: ArabicVowel) {
        selectedVowelId = vowel.id
        
        if vowel.id == targetVowel.id {
            FeedbackManager.shared.success()
            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onCorrect()
            }
        } else {
            FeedbackManager.shared.error()
            isWrong = true
            let mistakeId = "\(baseLetter.id):\(targetVowel.id)"
            dataManager.addMistake(itemId: mistakeId, type: "vowel")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isWrong = false
                selectedVowelId = nil
            }
        }
    }
    
    func playTargetSound() {
        let desiredTransliterationInit = baseLetter.transliteration.prefix(1)
        if let example = targetVowel.examples.first(where: { $0.transliteration.starts(with: desiredTransliterationInit) }) {
             AudioManager.shared.playSound(named: example.audioName)
             return
        }
        
        let cleanName = cleanTransliteration(baseLetter.transliteration)
        let key = "\(cleanName)_\(targetVowel.type.rawValue)"
        
        AudioManager.shared.playSound(named: key)
    }
    
    func cleanTransliteration(_ raw: String) -> String {
        let mapping: [String: String] = [
            "Alif": "alif", "Bā'": "ba", "Tā'": "ta", "Thā'": "tha",
            "Jīm": "jim", "Ḥā'": "ha", "Khā'": "kha", "Dāl": "dal", "Dhāl": "dhal",
            "Rā'": "ra", "Zāy": "zay", "Sīn": "sin", "Shīn": "shin", "Ṣād": "sad",
            "Ḍād": "dad", "Ṭā'": "ta_emphatic", "Ẓā'": "za_emphatic", "'Ayn": "ayn", "Ghayn": "ghayn",
            "Fā'": "fa", "Qāf": "qaf", "Kāf": "kaf", "Lām": "lam", "Mīm": "mim",
            "Nūn": "nun", "Hā'": "ha_round", "Wāw": "waw", "Yā'": "ya"
        ]
        return mapping[raw] ?? raw.lowercased()
    }
}
 
struct VowelIntroView: View {
    let vowel: ArabicVowel
    @EnvironmentObject var languageManager: LanguageManager

    private var descriptionText: String? {
        languageManager.currentLanguage == .english ? vowel.descriptionEn : vowel.descriptionFr
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Discover the sound" : "Découvre le son"))
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.noorSecondary)

            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.1), radius: 20)
                    .frame(width: 200, height: 200)

                Text("◌" + vowel.symbol)
                    .font(.system(size: 100))
                    .foregroundColor(.noorText)
                    .offset(x: 0, y: -10)
            }
            .padding(20)

            VStack(spacing: 10) {
                Text(vowel.name)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)

                if let desc = descriptionText {
                    Text(desc)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.noorSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Pronounced \"\(vowel.transliteration)\"" : "Se prononce \"\(vowel.transliteration)\""))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.noorSecondary)
                }
            }

            Button(action: {
                AudioManager.shared.playSound(named: vowel.soundName)
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Listen" : "Écouter"))
                }
                .font(.headline)
                .foregroundColor(.noorGold)
                .padding()
                .background(Color.noorGold.opacity(0.1))
                .cornerRadius(12)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AudioManager.shared.playSound(named: vowel.soundName)
                }
            }

            Spacer()
        }
    }
}

struct VowelExampleView: View {
    let vowel: ArabicVowel
    let example: VowelExample
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Practice" : "Mise en pratique"))
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.noorSecondary)
            
            HStack(spacing: 15) {
                VStack {
                    if let letter = ArabicLetter.letter(byId: example.letterId) {
                        Text(letter.isolated)
                            .font(.system(size: 40))
                            .foregroundColor(.noorText)
                    } else {
                        Text("?")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Letter" : "Lettre"))
                        .font(.caption)
                        .foregroundColor(.noorSecondary)
                }
                
                Text("+")
                    .font(.title)
                    .foregroundColor(.noorSecondary)
                
                VStack {
                    Text("◌" + vowel.symbol)
                        .font(.system(size: 40))
                        .foregroundColor(.noorText)
                    Text(vowel.name)
                        .font(.caption)
                        .foregroundColor(.noorSecondary)
                }
                
                Text("=")
                    .font(.title)
                    .foregroundColor(.noorSecondary)
                
                
                VStack {
                    Text(example.combination)
                        .font(.system(size: 50))
                        .foregroundColor(.noorText)
                    Text(example.transliteration)
                        .font(.headline)
                        .foregroundColor(.noorGold)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            
            Text(example.combination)
                .font(.system(size: 140))
                .foregroundColor(.noorText)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.noorGold.opacity(0.3), lineWidth: 2)
                        .padding(-20)
                )
            
            Button(action: {
                AudioManager.shared.playSound(named: example.audioName)
            }) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.title)
                    .padding(24)
                    .background(Color.noorGold)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .onAppear {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AudioManager.shared.playSound(named: example.audioName)
                }
            }
            
            Spacer()
        }
    }
}

struct VowelCompletionView: View {
    let levelNumber: Int
    let onContinue: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.noorGold)
                .padding()
                .background(
                    Circle().fill(Color.noorGold.opacity(0.15))
                        .frame(width: 160, height: 160)
                )
            
            Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Excellent work!" : "Excellent travail !"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(getMessage())
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.noorSecondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: onContinue) {
                Text(LocalizedStringKey(languageManager.currentLanguage == .english ? "Finish lesson" : "Terminer la leçon"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.noorGold)
                    .cornerRadius(16)
            }
            .padding(24)
        }
    }
    
    func getMessage() -> String {
        let isEnglish = languageManager.currentLanguage == .english
        switch levelNumber {
        case 2: return isEnglish ? "You learned the 3 short vowels (Harakat)!" : "Tu as appris les 3 voyelles courtes (Harakat) !"
        case 4: return isEnglish ? "Well done! You've mastered vowels with letters Jim to Dhal." : "Bravo ! Tu maîtrises les voyelles avec les lettres Jim à Dhal."
        case 6: return isEnglish ? "Excellent! You're doing great with letters Ra to Sad." : "Excellent ! Tu avances bien avec les lettres Ra à Sad."
        case 8: return isEnglish ? "Super! Letters Dad to Ghayn hold no more secrets." : "Super ! Les lettres Dad à Ghayn n'ont plus de secrets."
        case 10: return isEnglish ? "Congratulations! You've completed all vowel lessons." : "Félicitations ! Tu as terminé toutes les leçons de voyelles."
        case 11: return isEnglish ? "Amazing! You've assembled your first Arabic words." : "Incroyable ! Tu as assemblé tes premiers mots en arabe."
        default: return isEnglish ? "Excellent work! Keep it up." : "Excellent travail ! Continue comme ça."
        }
    }
}

struct SpecialVowelIntroView: View {
    let vowel: ArabicVowel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedComparison: Int = 0
    @State private var isPulsing = false

    private var descriptionText: String? {
        languageManager.currentLanguage == .english ? vowel.descriptionEn : vowel.descriptionFr
    }
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    private var comparisonPairs: [(withVowel: String, withoutVowel: String, phonetic: String, phoneticBase: String)] {
        switch vowel.type {
        case .sukun:
            return [
                ("بْ", "بَ", "b", "ba"),
                ("مْ", "مَ", "m", "ma"),
                ("نْ", "نَ", "n", "na")
            ]
        case .shadda:
            return [
                ("بَّ", "بَ", "bba", "ba"),
                ("مَّ", "مَ", "mma", "ma"),
                ("سَّ", "سَ", "ssa", "sa")
            ]
        case .tanwinFatha, .tanwinKasra, .tanwinDamma:
            return [
                ("بًا", "بَ", "ban", "ba"),
                ("كًا", "كَ", "kan", "ka"),
                ("دًا", "دَ", "dan", "da")
            ]
        default:
            return [("بَ", "ب", "ba", "b")]
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text(LocalizedStringKey(isEnglish ? "New Concept" : "Nouveau Concept"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.noorGold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.noorGold.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.top, 20)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text("◌" + vowel.symbol)
                            .font(.system(size: 48))
                            .foregroundColor(.noorGold)
                            .scaleEffect(isPulsing ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
                            .onAppear { isPulsing = true }
                        
                        Text(vowel.name)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                    }

                    if let desc = descriptionText {
                        Text(desc)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                
                VStack(spacing: 16) {
                    Text(isEnglish ? "Compare the sounds:" : "Compare les sons :")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .textCase(.uppercase)
                    
                    ForEach(Array(comparisonPairs.enumerated()), id: \.offset) { index, pair in
                        ComparisonCard(
                            withEffect: pair.withVowel,
                            withoutEffect: pair.withoutVowel,
                            phoneticWith: pair.phonetic,
                            phoneticWithout: pair.phoneticBase,
                            vowelName: vowel.name,
                            isEnglish: isEnglish
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 16) {
                    Text(isEnglish ? "How it works:" : "Comment ça marche :")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .textCase(.uppercase)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 8) {
                            Text("ب")
                                .font(.system(size: 44))
                                .foregroundColor(.noorText)
                            Text(isEnglish ? "Letter" : "Lettre")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.noorSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.noorGold)
                        
                        VStack(spacing: 8) {
                            Text("◌" + vowel.symbol)
                                .font(.system(size: 44))
                                .foregroundColor(.noorGold)
                            Text(vowel.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.noorGold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.noorGold.opacity(0.1))
                        .cornerRadius(16)
                        
                        Image(systemName: "equal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.noorGold)
                        
                        VStack(spacing: 8) {
                            Text("ب" + vowel.symbol)
                                .font(.system(size: 44))
                                .foregroundColor(.noorText)
                            Text(isEnglish ? "Result" : "Résultat")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.noorSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 80)
            }
        }
    }
}

struct ComparisonCard: View {
    let withEffect: String
    let withoutEffect: String
    let phoneticWith: String
    let phoneticWithout: String
    let vowelName: String
    let isEnglish: Bool
    
    @State private var playingWith = false
    @State private var playingWithout = false
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                playWithoutEffect()
            }) {
                VStack(spacing: 8) {
                    Text(withoutEffect)
                        .font(.system(size: 42))
                        .foregroundColor(.noorText)
                    
                    Text(phoneticWithout)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.noorSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 12))
                        Text(isEnglish ? "Normal" : "Normal")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.noorSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(playingWithout ? Color.blue.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(playingWithout ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
            
            VStack {
                Text("VS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.noorSecondary.opacity(0.5))
            }
            .frame(width: 30)
            
            Button(action: {
                playWithEffect()
            }) {
                VStack(spacing: 8) {
                    Text(withEffect)
                        .font(.system(size: 42))
                        .foregroundColor(.noorGold)
                    
                    Text(phoneticWith)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.noorGold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 12))
                        Text(vowelName)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.noorGold.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(playingWith ? Color.noorGold.opacity(0.2) : Color.noorGold.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(playingWith ? Color.noorGold : Color.noorGold.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private func playWithoutEffect() {
        playingWithout = true
        HapticManager.shared.impact(.light)
        AudioManager.shared.playText(withoutEffect, style: .letter, useCache: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            playingWithout = false
        }
    }
    
    private func playWithEffect() {
        playingWith = true
        HapticManager.shared.impact(.medium)
        AudioManager.shared.playText(withEffect, style: .letter, useCache: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            playingWith = false
        }
    }
}


import SwiftUI

struct WordAssemblyView: View {
    let levelNumber: Int
    let onCompletion: () -> Void
    let singleWord: ArabicWord?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager

    init(levelNumber: Int, onCompletion: @escaping () -> Void) {
        self.levelNumber = levelNumber
        self.onCompletion = onCompletion
        self.singleWord = nil
    }

    init(word: ArabicWord, onCompletion: @escaping () -> Void) {
        self.levelNumber = -1
        self.onCompletion = onCompletion
        self.singleWord = word
    }

    @State private var words: [ArabicWord] = []
    @State private var currentWordIndex = 0
    
    @State private var scrambledLetters: [UniqueLetter] = []
    @State private var placedLetters: [ArabicLetter?] = []
    @State private var placedSourceIds: [UUID?] = []
    @State private var showSuccess = false
    @State private var showError = false
    
    @State private var selectedLetter: UniqueLetter? = nil
    
    var currentWord: ArabicWord? {
        words.indices.contains(currentWordIndex) ? words[currentWordIndex] : nil
    }
    
    private var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(currentWordIndex) / Double(words.count)
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            if let word = currentWord {
                VStack(spacing: 0) {
                    if singleWord == nil {
                        headerView
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            mascotSection
                            wordDisplayView(word: word)
                            slotsView(word: word)
                            instructionAndLettersView
                        }
                        .padding(.top, 16)
                        .padding(.bottom, singleWord != nil ? 40 : 120)
                    }
                }
                
                if showSuccess {
                    VStack {
                        Spacer()
                        nextButton
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear { loadLevel() }
        .onDisappear { logCurrentWordMistakeOnQuit() }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    logCurrentWordMistakeOnQuit()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "textformat.abc")
                        .font(.system(size: 14))
                        .foregroundColor(.noorGold)
                    Text("\(currentWordIndex + 1)/\(words.count)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.noorText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.noorGold, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    private var mascotSection: some View {
        VStack(spacing: 12) {
            if showSuccess {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text(languageManager.currentLanguage == .english ? "Perfect!" : "Parfait !")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green.opacity(0.1))
                )
            } else if showError {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                    Text(languageManager.currentLanguage == .english ? "Try again" : "Réessaie")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orange.opacity(0.1))
                )
            } else {
                HStack(spacing: 12) {
                    Image(systemName: selectedLetter != nil ? "square.grid.3x3.topleft.filled" : "character.cursor.ibeam")
                        .font(.system(size: 18))
                        .foregroundColor(.noorGold)
                    
                    Text(selectedLetter != nil
                         ? (languageManager.currentLanguage == .english ? "Tap a slot to place the letter" : "Tape sur un emplacement")
                         : (languageManager.currentLanguage == .english ? "Select a letter below" : "Sélectionne une lettre"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.noorText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.noorGold.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            if let word = currentWord, wordContainsTaMarbuta(word), !showSuccess {
                taMarbutaHintView
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.4), value: showSuccess)
        .animation(.spring(response: 0.4), value: showError)
        .animation(.spring(response: 0.4), value: selectedLetter?.id)
    }
    
    private func wordContainsTaMarbuta(_ word: ArabicWord) -> Bool {
        word.componentLetterIds.contains(29)
    }
    
    private var taMarbutaHintView: some View {
        HStack(spacing: 10) {
            Text("ة")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorGold)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(languageManager.currentLanguage == .english ? "Ta Marbuta" : "Ta Marbuta")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.noorText)
                Text(languageManager.currentLanguage == .english
                     ? "Feminine ending, pronounced 'a' or 'at'"
                     : "Terminaison féminine, se prononce 'a' ou 'at'")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.noorGold.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.noorGold.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func wordDisplayView(word: ArabicWord) -> some View {
        VStack(spacing: 16) {
            if showSuccess {
                VStack(spacing: 20) {
                    DiacriticHelper.highlightedArabicText(text: word.arabic, fontSize: 52)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                )
                        )
                    
                    Text(word.transliteration)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.noorGold)
                    
                    wordBreakdownView(word: word)
                }
            } else {
                let translation = languageManager.currentLanguage == .english ? word.translationEn : word.translationFr
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Text(translation)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.noorText)
                        
                        Button(action: {
                            playWordAudio(word)
                        }) {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.noorGold)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text(word.transliteration)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.noorSecondary)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.4), value: showSuccess)
    }
    
    private func playWordAudio(_ word: ArabicWord) {
        let cleanTrans = word.transliteration
            .replacingOccurrences(of: "ā", with: "a")
            .replacingOccurrences(of: "ī", with: "i")
            .replacingOccurrences(of: "ū", with: "u")
            .replacingOccurrences(of: "Ḥ", with: "h")
            .replacingOccurrences(of: "ḥ", with: "h")
            .replacingOccurrences(of: "Ṣ", with: "s")
            .replacingOccurrences(of: "ṣ", with: "s")
            .replacingOccurrences(of: "Ḍ", with: "d")
            .replacingOccurrences(of: "ḍ", with: "d")
            .replacingOccurrences(of: "Ṭ", with: "t")
            .replacingOccurrences(of: "ṭ", with: "t")
            .replacingOccurrences(of: "Ẓ", with: "z")
            .replacingOccurrences(of: "ẓ", with: "z")
            .replacingOccurrences(of: "ʿ", with: "")
            .replacingOccurrences(of: "'", with: "")
            .lowercased()
            
        let key = "word_\(cleanTrans)"
        AudioManager.shared.playSound(named: key)
    }
    
    private func wordBreakdownView(word: ArabicWord) -> some View {
        DiacriticBreakdownView(arabicText: word.arabic, showMascot: true, isCompact: false)
    }
    
    private func slotsView(word: ArabicWord) -> some View {
        HStack(spacing: 12) {
            ForEach(Array(word.componentLetterIds.enumerated()), id: \.offset) { index, _ in
                slotButton(at: index, word: word)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding(.horizontal)
        .modifier(ShakeEffect(shakes: showError ? 2 : 0))
        .animation(.default, value: showError)
    }
    
    private func isLetterCorrect(at index: Int) -> Bool {
        guard let word = currentWord,
              let letter = placedLetters[safe: index] as? ArabicLetter else { return false }
        return word.componentLetterIds.indices.contains(index) && letter.id == word.componentLetterIds[index]
    }
    
    private func contextualForm(for letter: ArabicLetter, at index: Int, in word: ArabicWord) -> String {
        let total = word.componentLetterIds.count
        let prevLetter: ArabicLetter? = index > 0 ? placedLetters[safe: index - 1] as? ArabicLetter : nil
        return ArabicLetter.determineLetterForm(
            letter: letter,
            index: index,
            totalLetters: total,
            previousLetter: prevLetter
        )
    }
    
    private func slotButton(at index: Int, word: ArabicWord) -> some View {
        let hasLetter = placedLetters.indices.contains(index) && placedLetters[index] != nil
        let isHighlighted = selectedLetter != nil && !hasLetter
        let correct = hasLetter && isLetterCorrect(at: index)
        
        let fillColor: Color = {
            if correct { return Color.green.opacity(0.15) }
            if isHighlighted { return Color.noorGold.opacity(0.2) }
            return Color(.secondarySystemBackground)
        }()
        
        let borderColor: Color = {
            if correct { return .green }
            if isHighlighted { return .noorGold }
            return .noorSecondary.opacity(0.3)
        }()
        
        return Button {
            handleSlotTap(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(fillColor)
                    .frame(width: 70, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: (isHighlighted || correct) ? 3 : 2)
                    )
                    .shadow(color: correct ? Color.green.opacity(0.3) : (isHighlighted ? Color.noorGold.opacity(0.3) : .clear), radius: 8)
                
                if hasLetter, let letter = placedLetters[index] {
                    VStack(spacing: 2) {
                        Text(contextualForm(for: letter, at: index, in: word))
                            .font(.system(size: 36))
                            .foregroundStyle(correct ? .green : .primary)
                        Text(letter.transliteration)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scaleEffect(isHighlighted ? 1.08 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
            .animation(.spring(response: 0.3), value: correct)
        }
        .buttonStyle(.plain)
    }
    
    private var instructionAndLettersView: some View {
        VStack(spacing: 16) {
            if selectedLetter != nil {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text(LocalizedStringKey("Place la lettre dans un emplacement"))
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Color.noorGold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.noorGold.opacity(0.1))
                .cornerRadius(20)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: 12) {
                ForEach(scrambledLetters) { item in
                    letterButton(item: item)
                }
            }
            .padding(.horizontal)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedLetter)
    }
    
    private func letterButton(item: UniqueLetter) -> some View {
        let isUsed = placedSourceIds.contains(item.id)
        let isSelected = selectedLetter?.id == item.id
        
        return Button {
            if !isUsed {
                selectLetter(item)
            }
        } label: {
            VStack(spacing: 2) {
                Text(item.displayCharacter)
                    .font(.system(size: 28))
                    .foregroundStyle(.primary)
                Text(item.letter.transliteration)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, height: 70)
            .background(isSelected ? Color.noorGold.opacity(0.2) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.noorGold : Color.clear, lineWidth: 3)
            )
            .shadow(color: isSelected ? Color.noorGold.opacity(0.4) : .black.opacity(0.1), radius: isSelected ? 6 : 2)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .opacity(isUsed ? 0.3 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isUsed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    @State private var showLevelSummary = false
    
    private var nextButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.noorBackground.opacity(0), Color.noorBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)
            
            Button {
                if currentWordIndex < words.count - 1 {
                    nextWord()
                } else if singleWord != nil {
                    onCompletion()
                } else {
                    withAnimation(.spring()) { showLevelSummary = true }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(currentWordIndex < words.count - 1 ? LocalizedStringKey(languageManager.currentLanguage == .english ? "Next word" : "Mot suivant") : LocalizedStringKey(languageManager.currentLanguage == .english ? "Finish" : "Terminer"))
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: currentWordIndex < words.count - 1 ? "arrow.right" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
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
                        .shadow(color: .noorGold.opacity(0.4), radius: 12, y: 6)
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            .background(Color.noorBackground)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(isPresented: $showLevelSummary) {
            LevelSummaryView(wordsLearned: words.count, onContinue: {
                showLevelSummary = false
                onCompletion()
            })
        }
    }
    
    private func selectLetter(_ item: UniqueLetter) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedLetter?.id == item.id {
                selectedLetter = nil
            } else {
                selectedLetter = item
                FeedbackManager.shared.tapLight()
            }
        }
    }
    
    private func handleSlotTap(at index: Int) {
        if placedLetters.indices.contains(index), placedLetters[index] != nil {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                placedLetters[index] = nil
                placedSourceIds[index] = nil
            }
            FeedbackManager.shared.tapMedium()
        } else if let selected = selectedLetter {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                placedLetters[index] = selected.letter
                placedSourceIds[index] = selected.id
                selectedLetter = nil
            }
            
            if let word = currentWord,
               word.componentLetterIds.indices.contains(index),
               selected.letter.id == word.componentLetterIds[index] {
                HapticManager.shared.impact(.light)
            }
            
            FeedbackManager.shared.tapLight()
            checkCompletion()
        }
    }
    
    private func checkCompletion() {
        guard let word = currentWord else { return }
        guard placedLetters.allSatisfy({ $0 != nil }) else { return }
        
        var allCorrect = true
        for (i, letter) in placedLetters.enumerated() {
            if let l = letter, l.id != word.componentLetterIds[i] {
                allCorrect = false
                break
            }
        }
        
        if allCorrect {
            FeedbackManager.shared.success()
            withAnimation { showSuccess = true }
        } else {
            FeedbackManager.shared.error()
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showError = false
                    placedLetters = Array(repeating: nil, count: word.componentLetterIds.count)
                    placedSourceIds = Array(repeating: nil, count: word.componentLetterIds.count)
                }
            }
        }
    }
    
    private func nextWord() {
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
            loadWord(words[currentWordIndex])
        } else {
            onCompletion()
        }
    }
    
    private func loadLevel() {
        if let single = singleWord {
            words = [single]
            loadWord(single)
        } else if let level = CourseContent.getLevels(language: .english).first(where: { $0.id == levelNumber }) {
            words = CourseContent.words.filter { level.contentIds.contains($0.id) }
            if !words.isEmpty { loadWord(words[0]) }
        }
    }
    
    private func loadWord(_ word: ArabicWord) {
        showSuccess = false
        showError = false
        selectedLetter = nil
        placedLetters = Array(repeating: nil, count: word.componentLetterIds.count)
        placedSourceIds = Array(repeating: nil, count: word.componentLetterIds.count)

        let lettersWithDiacritics = DiacriticHelper.extractLettersWithDiacritics(
            from: word.arabic,
            letterIds: word.componentLetterIds
        )
        
        var uniqueLetters: [UniqueLetter] = []
        for (index, letterId) in word.componentLetterIds.enumerated() {
            if let letter = ArabicLetter.letter(byId: letterId) {
                let diacritics = index < lettersWithDiacritics.count ? lettersWithDiacritics[index].diacritics : ""
                uniqueLetters.append(UniqueLetter(letter: letter, diacritics: diacritics))
            }
        }
        
        let commonDiacritics = ["َ", "ُ", "ِ", "ْ", ""]
        let distractorLetters = ArabicLetter.alphabet
            .filter { !word.componentLetterIds.contains($0.id) }
            .shuffled()
            .prefix(3)
        
        for letter in distractorLetters {
            let randomDiacritic = commonDiacritics.randomElement() ?? ""
            uniqueLetters.append(UniqueLetter(letter: letter, diacritics: randomDiacritic))
        }
        
        scrambledLetters = uniqueLetters.shuffled()
    }

    private func logCurrentWordMistakeOnQuit() {
        guard let word = currentWord, !showSuccess else { return }
        dataManager.addMistake(itemId: String(word.id), type: "word")
    }
}

struct LevelSummaryView: View {
    let wordsLearned: Int
    let onContinue: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .levelComplete,
                title: LocalizedStringKey(isEnglish ? "Level Complete!" : "Niveau terminé !"),
                subtitle: LocalizedStringKey(isEnglish ? "\(wordsLearned) words learned" : "\(wordsLearned) mots appris"),
                score: wordsLearned,
                total: wordsLearned,
                xpEarned: 100,
                showStars: true
            ),
            onDismiss: {
                dismiss()
                onContinue()
            }
        )
    }
}

struct SummaryStatCard: View {
    let icon: String
    let value: String
    let label: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.noorGold)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundColor(.noorSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 10, y: 0))
    }
}

struct UniqueLetter: Identifiable, Equatable, Hashable {
    let id = UUID()
    let letter: ArabicLetter
    let diacritics: String
    
    init(letter: ArabicLetter, diacritics: String = "") {
        self.letter = letter
        self.diacritics = diacritics
    }
    
    var displayCharacter: String {
        letter.isolated + diacritics
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UniqueLetter, rhs: UniqueLetter) -> Bool {
        lhs.id == rhs.id
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
