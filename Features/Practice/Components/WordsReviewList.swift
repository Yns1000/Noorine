import SwiftUI

struct WordsReviewList: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showMistakes = false
    @State private var focusedMistakeId: String? = nil
    @State private var focusedMistakeType: String? = nil

    private var mistakeWordCards: [Flashcard] {
        let mistakeIds = dataManager.mistakes
            .filter { $0.itemType == "word" }
            .compactMap { Int($0.itemId) }
        guard !mistakeIds.isEmpty else { return [] }
        
        let wordsById = Dictionary(uniqueKeysWithValues: CourseContent.words.map { ($0.id, $0) })
        let arabicSet = Set(mistakeIds.compactMap { wordsById[$0]?.arabic })
        return FlashcardManager.shared.allCards.filter { arabicSet.contains($0.arabic) }
    }

    private var primaryMistake: MistakeItem? {
        let ordered = dataManager.mistakes.sorted { lhs, rhs in
            if lhs.correctionCount != rhs.correctionCount {
                return lhs.correctionCount < rhs.correctionCount
            }
            return lhs.lastMistakeDate > rhs.lastMistakeDate
        }
        return ordered.first
    }
    
    var body: some View {
        if !dataManager.mistakes.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(languageManager.currentLanguage == .english ? "Mistakes to fix" : "Erreurs à corriger")
                        .font(.headline)
                        .foregroundColor(.noorText)
                    
                    Spacer()
                    
                    Button(languageManager.currentLanguage == .english ? "Fix now" : "Corriger") {
                        if let mistake = primaryMistake {
                            focusedMistakeId = mistake.itemId
                            focusedMistakeType = mistake.itemType
                            showMistakes = true
                        }
                    }
                        .font(.caption)
                        .foregroundColor(.noorGold)
                }
                
                VStack(spacing: 0) {
                    if let mistake = primaryMistake {
                        MistakePreviewRow(
                            mistake: mistake,
                            isEnglish: languageManager.currentLanguage == .english
                        ) {
                            focusedMistakeId = mistake.itemId
                            focusedMistakeType = mistake.itemType
                            showMistakes = true
                        }
                        
                        if !mistakeWordCards.isEmpty {
                            Divider().padding(.leading, 60)
                        }
                    }
                    
                    ForEach(Array(mistakeWordCards.prefix(3)).indices, id: \.self) { index in
                        let card = mistakeWordCards[index]
                        ReviewRow(
                            card: card,
                            isEnglish: languageManager.currentLanguage == .english,
                            isMistake: true,
                            onTap: {
                                if let word = CourseContent.words.first(where: { $0.arabic == card.arabic }) {
                                    focusedMistakeId = String(word.id)
                                    focusedMistakeType = "word"
                                    showMistakes = true
                                }
                            }
                        )
                        if index < min(2, mistakeWordCards.count - 1) {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
            }
            .fullScreenCover(isPresented: $showMistakes) {
                MistakesReviewView(focusItemId: focusedMistakeId, focusItemType: focusedMistakeType)
            }
        }
    }
}

private struct MistakePreviewRow: View {
    let mistake: MistakeItem
    let isEnglish: Bool
    let onTap: () -> Void
    
    var body: some View {
        let display = displayInfo(for: mistake)
        return HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(display.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: display.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(display.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(display.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorText)
                
                Text(display.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Text(isEnglish ? "Fix now" : "Corriger")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.red.opacity(0.12)))
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
    
    private func displayInfo(for mistake: MistakeItem) -> (title: String, subtitle: String, icon: String, color: Color) {
        switch mistake.itemType {
        case "letter":
            if let id = Int(mistake.itemId), let letter = ArabicLetter.letter(byId: id) {
                return (letter.isolated, letter.transliteration, "pencil.line", .orange)
            }
            return (isEnglish ? "Letter" : "Lettre", "", "pencil.line", .orange)
        case "phrase":
            if let id = Int(mistake.itemId), let phrase = CourseContent.phrases.first(where: { $0.id == id }) {
                let title = isEnglish ? phrase.translationEn : phrase.translationFr
                return (title, phrase.transliteration, "quote.bubble.fill", .green)
            }
            return (isEnglish ? "Phrase" : "Phrase", "", "quote.bubble.fill", .green)
        case "vowel":
            let subtitle = isEnglish ? "Short vowels" : "Voyelles courtes"
            return (isEnglish ? "Vowels" : "Voyelles", subtitle, "waveform", .blue)
        case "solarLunar":
            if let id = Int(mistake.itemId), let letter = ArabicLetter.letter(byId: id) {
                return (letter.isolated, isEnglish ? "Solar/Lunar" : "Solaire/Lunaire", "sun.max.fill", .yellow)
            }
            return (isEnglish ? "Rules" : "Règles", isEnglish ? "Solar/Lunar" : "Solaire/Lunaire", "sun.max.fill", .yellow)
        case "word":
            return (isEnglish ? "Word" : "Mot", "", "textformat.abc", .red)
        default:
            return (isEnglish ? "Mistake" : "Erreur", "", "exclamationmark.triangle.fill", .red)
        }
    }
}

struct ReviewRow: View {
    let card: Flashcard
    let isEnglish: Bool
    let isMistake: Bool
    let onTap: () -> Void
    @StateObject private var audioManager = AudioManager.shared
    
    private var strength: Double {
        let interval = FlashcardManager.shared.getInterval(for: card)
        return min(1.0, Double(interval) / 21.0)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(Color.noorSecondary.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: strength)
                    .stroke(strengthColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text(card.arabic)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorText)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isEnglish ? card.english : card.french)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorText)
                
                HStack(spacing: 6) {
                    Text(card.transliteration)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.noorSecondary)
                    
                    if isMistake {
                        let label = isEnglish ? "Mistake" : "Erreur"
                        Text(label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.red.opacity(0.12)))
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                audioManager.playLetter(card.arabic)
                FeedbackManager.shared.tapLight()
            }) {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.title2)
                    .foregroundColor(.noorSecondary.opacity(0.5))
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
    
    var strengthColor: Color {
        if strength < 0.4 { return .red }
        if strength < 0.7 { return .orange }
        return .green
    }
}
