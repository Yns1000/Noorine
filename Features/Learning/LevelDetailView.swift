import SwiftUI
import UniformTypeIdentifiers

struct LevelDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let levelNumber: Int
    let title: String
    
    @State private var selectedLetter: ArabicLetter?
    
    var letters: [ArabicLetter] {
        ArabicLetter.letters(forLevel: levelNumber)
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
                            Text(LocalizedStringKey("Retour"))
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
    }
    
    var masteredCount: Int {
        letters.filter { dataManager.isLetterMastered(letterId: $0.id, inLevel: levelNumber) }.count
    }
}

struct LevelDetailHeader: View {
    let title: String
    let masteredCount: Int
    let totalCount: Int
    
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
                    Text(LocalizedStringKey("\(masteredCount)/\(totalCount) lettres maîtrisées"))
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
    
    @State private var currentStepIndex = 0

    @State private var steps: [VowelStep] = []
    
    
    enum VowelStep: Identifiable {
        case intro(ArabicVowel)
        case example(ArabicVowel, VowelExample)
        case quiz(target: ArabicVowel, allVowels: [ArabicVowel], baseLetter: ArabicLetter)
        case completion
        
        var id: String {
            switch self {
            case .intro(let v): return "intro_\(v.id)"
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
        let isFirstExposure = (levelNumber == 2)
        let loadedVowels = vowels
        
        if isFirstExposure {
            for vowel in loadedVowels {
                sequence.append(.intro(vowel))
                if let firstExample = vowel.examples.first {
                    sequence.append(.example(vowel, firstExample))
                }
            }
        }
        
        var targetLetterIds: [Int] = []
        if let previousLevel = CourseContent.getLevels(language: .english).first(where: { $0.id == levelNumber - 1 }) {
            targetLetterIds = previousLevel.contentIds
        }
        
        if targetLetterIds.isEmpty { targetLetterIds = [2, 3] }
        
        var quizSteps: [VowelStep] = []

        let uniqueTargetIds = Array(Set(targetLetterIds))
        
        for baseId in uniqueTargetIds {
            if let baseLetter = ArabicLetter.letter(byId: baseId) {
                if let randomVowel = loadedVowels.randomElement() {
                    quizSteps.append(.quiz(target: randomVowel, allVowels: loadedVowels, baseLetter: baseLetter))
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .padding(12)
                            .background(Color.white)
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
                        Text(LocalizedStringKey("Continuer"))
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
    }
    
    func isQuizStep(_ step: VowelStep) -> Bool {
        if case .quiz = step { return true }
        return false
    }
    
    func getVowels() -> [ArabicVowel] {
        guard let levelDef = CourseContent.getLevels(language: .english).first(where: { $0.id == levelNumber }),
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
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Quel son entends-tu ?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
                .padding(.top)
            
            Button(action: {
                playTargetSound()
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 32))
                    Text("Réécouter")
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
            
            HStack(spacing: 16) {
                ForEach(allVowels) { vowel in
                    Button(action: {
                        handleSelection(vowel)
                    }) {
                        VStack(spacing: 10) {
                            Text(baseLetter.initial + vowel.symbol)
                                .font(.system(size: 56))
                                .foregroundColor(foregroundColor(for: vowel))
                                .frame(height: 80)
                            
                            Text(vowel.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.noorSecondary.opacity(0.8))
                            
                            Text(getPhonetic(letter: baseLetter, vowel: vowel))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.noorGold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(backgroundColor(for: vowel))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(borderColor(for: vowel), lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                        )
                    }
                    .disabled(showSuccess)
                }
            }
            .padding(.horizontal, 16)
            
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
        
        let vowelSound = vowel.transliteration
        
        return consonant + vowelSound
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
            AudioManager.shared.playSystemSound(1001)
            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onCorrect()
            }
        } else {
            AudioManager.shared.playSystemSound(1002)
            isWrong = true
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
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Découvre le son")
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
            
            VStack(spacing: 8) {
                Text(vowel.name)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
                
                Text("Se prononce \"\(vowel.transliteration)\"")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Button(action: {
                AudioManager.shared.playSound(named: vowel.soundName)
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Écouter")
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
            
            Text("Mise en pratique")
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
                    Text("Lettre")
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
            
            Text("Excellent travail !")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(getMessage())
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.noorSecondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Terminer la leçon")
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
        switch levelNumber {
        case 2: return "Tu as appris les 3 voyelles courtes (Harakat) !"
        case 4: return "Bravo ! Tu maîtrises les voyelles avec les lettres Jim à Dhal."
        case 6: return "Excellent ! Tu avances bien avec les lettres Ra à Sad."
        case 8: return "Super ! Les lettres Dad à Ghayn n'ont plus de secrets."
        case 10: return "Félicitations ! Tu as terminé toutes les leçons de voyelles."
        case 11: return "Incroyable ! Tu as assemblé tes premiers mots en arabe."
        default: return "Excellent travail ! Continue comme ça."
        }
    }
}


import SwiftUI

struct WordAssemblyView: View {
    let levelNumber: Int
    let onCompletion: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
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
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            if let word = currentWord {
                VStack(spacing: 24) {
                    headerView
                    wordDisplayView(word: word)
                    slotsView(word: word)
                    instructionAndLettersView
                    Spacer()
                    if showSuccess { nextButton }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear { loadLevel() }
    }
    
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            Spacer()
            Text("Word \(currentWordIndex + 1)/\(words.count)")
                .font(.headline)
                .foregroundColor(.noorSecondary)
        }
        .padding(.horizontal)
    }
    
    private func wordDisplayView(word: ArabicWord) -> some View {
        VStack(spacing: 12) {
            if showSuccess {
                VStack(spacing: 16) {
                    DiacriticHelper.highlightedArabicText(text: word.arabic, fontSize: 60)
                    
                    Text(word.transliteration)
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    wordBreakdownView(word: word)
                }
            } else {
                let translation = languageManager.currentLanguage == .english ? word.translationEn : word.translationFr
                Text(translation)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(word.transliteration)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 120)
        .animation(.spring(), value: showSuccess)
    }
    
    private func wordBreakdownView(word: ArabicWord) -> some View {
        DiacriticBreakdownView(arabicText: word.arabic, showMascot: true, isCompact: false)
    }
    
    private func slotsView(word: ArabicWord) -> some View {
        HStack(spacing: 12) {
            ForEach(Array(word.componentLetterIds.enumerated()), id: \.offset) { index, _ in
                slotButton(at: index)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding(.horizontal)
        .modifier(ShakeEffect(shakes: showError ? 2 : 0))
        .animation(.default, value: showError)
    }
    
    private func slotButton(at index: Int) -> some View {
        let hasLetter = placedLetters.indices.contains(index) && placedLetters[index] != nil
        let isHighlighted = selectedLetter != nil && !hasLetter
        
        return Button {
            handleSlotTap(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isHighlighted ? Color.noorGold.opacity(0.2) : Color(.secondarySystemBackground))
                    .frame(width: 70, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isHighlighted ? Color.noorGold : Color.noorSecondary.opacity(0.3),
                                lineWidth: isHighlighted ? 3 : 2
                            )
                    )
                    .shadow(color: isHighlighted ? Color.noorGold.opacity(0.3) : .clear, radius: 8)
                
                if hasLetter, let letter = placedLetters[index] {
                    VStack(spacing: 2) {
                        Text(letter.isolated)
                            .font(.system(size: 36))
                            .foregroundStyle(.primary)
                        Text(letter.transliteration)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scaleEffect(isHighlighted ? 1.08 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
        }
        .buttonStyle(.plain)
    }
    
    private var instructionAndLettersView: some View {
        VStack(spacing: 16) {
            if selectedLetter != nil {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Place the letter in a slot")
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
                Text(item.letter.isolated)
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
    
    private var nextButton: some View {
        Button { nextWord() } label: {
            Text(currentWordIndex < words.count - 1 ? "Next Word" : "Finish")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.noorGold)
                .cornerRadius(16)
        }
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func selectLetter(_ item: UniqueLetter) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedLetter?.id == item.id {
                selectedLetter = nil
            } else {
                selectedLetter = item
                AudioManager.shared.playSystemSound(1104)
            }
        }
    }
    
    private func handleSlotTap(at index: Int) {
        if placedLetters.indices.contains(index), placedLetters[index] != nil {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                placedLetters[index] = nil
                placedSourceIds[index] = nil
            }
            AudioManager.shared.playSystemSound(1306)
        } else if let selected = selectedLetter {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                placedLetters[index] = selected.letter
                placedSourceIds[index] = selected.id
                selectedLetter = nil
            }
            AudioManager.shared.playSystemSound(1104)
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
            AudioManager.shared.playSystemSound(1001)
            withAnimation { showSuccess = true }
        } else {
            AudioManager.shared.playSystemSound(1002)
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
        if let level = CourseContent.getLevels(language: .english).first(where: { $0.id == levelNumber }) {
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
        
        var letters: [ArabicLetter] = word.componentLetterIds.compactMap { ArabicLetter.letter(byId: $0) }
        let distractors = ArabicLetter.alphabet
            .filter { !word.componentLetterIds.contains($0.id) }
            .shuffled()
            .prefix(3)
        letters.append(contentsOf: distractors)
        scrambledLetters = letters.map { UniqueLetter(letter: $0) }.shuffled()
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

struct UniqueLetter: Identifiable, Equatable {
    let id = UUID()
    let letter: ArabicLetter
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


