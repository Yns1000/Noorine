import SwiftUI

struct PracticeToolsGrid: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showSpeakingPractice = false
    @State private var showFlashcards = false
    @State private var showMistakes = false
    @State private var showResources = false
    @State private var showMatching = false
    @State private var showDictation = false
    @State private var showSentenceBuilder = false
    @State private var showFreePractice = false

    let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 15)
    ]

    var body: some View {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let allowedArabic = Set(pool.words.map { $0.arabic })
        let flashcardCount = FlashcardManager.shared.filteredCards(allowedArabic: allowedArabic).count

        let isEnglish = languageManager.currentLanguage == .english
        
        LazyVGrid(columns: columns, spacing: 15) {
            ToolCard(
                icon: "rectangle.on.rectangle.angled",
                color: .blue,
                title: "Flashcards",
                subtitle: LocalizedStringKey(flashcardCount > 0
                    ? (isEnglish ? "\(flashcardCount) cards" : "\(flashcardCount) cartes")
                    : (isEnglish ? "Spaced review" : "Révision espacée")),
                action: { showFlashcards = true }
            )

            NavigationLink(destination: ListeningModuleView()) {
                ToolCard(
                    icon: "waveform",
                    color: .purple,
                    title: LocalizedStringKey(isEnglish ? "Listening" : "Écoute"),
                    subtitle: LocalizedStringKey(isEnglish ? "Pure audio" : "Audio pur")
                )
            }
            .buttonStyle(PlainButtonStyle())

            ToolCard(
                icon: "heart.slash.fill",
                color: .red,
                title: LocalizedStringKey(isEnglish ? "Mistakes" : "Erreurs"),
                subtitle: LocalizedStringKey(isEnglish ? "\(dataManager.mistakes.count) to fix" : "\(dataManager.mistakes.count) à corriger"),
                action: { showMistakes = true }
            )

            ToolCard(
                icon: "mic.fill",
                color: .green,
                title: LocalizedStringKey(isEnglish ? "Speaking" : "Parler"),
                subtitle: LocalizedStringKey(isEnglish ? "Pronunciation" : "Prononciation"),
                action: { showSpeakingPractice = true }
            )

            ToolCard(
                icon: "bolt.fill",
                color: .mint,
                title: LocalizedStringKey(isEnglish ? "Speed Quiz" : "Quiz Chrono"),
                subtitle: LocalizedStringKey(isEnglish ? "Speed & vocabulary" : "Rapidité & vocabulaire"),
                action: { showMatching = true }
            )

            ToolCard(
                icon: "ear.fill",
                color: .indigo,
                title: LocalizedStringKey(isEnglish ? "Dictation" : "Dictée"),
                subtitle: LocalizedStringKey(isEnglish ? "Listen & build" : "Écoute & construis"),
                action: { showDictation = true }
            )

            ToolCard(
                icon: "text.word.spacing",
                color: .cyan,
                title: LocalizedStringKey(isEnglish ? "Sentences" : "Phrases"),
                subtitle: LocalizedStringKey(isEnglish ? "Word order" : "Ordre des mots"),
                action: { showSentenceBuilder = true }
            )

            ToolCard(
                icon: "arrow.counterclockwise.circle.fill",
                color: .teal,
                title: LocalizedStringKey(isEnglish ? "Replay" : "Rejouer"),
                subtitle: LocalizedStringKey(isEnglish ? "\(dataManager.completedLevels().count) levels" : "\(dataManager.completedLevels().count) niveaux"),
                action: { showFreePractice = true }
            )

            ToolCard(
                icon: "book.fill",
                color: .orange,
                title: LocalizedStringKey(isEnglish ? "Resources" : "Ressources"),
                subtitle: LocalizedStringKey(isEnglish ? "Alphabet & vowels" : "Alphabet & harakat"),
                action: { showResources = true }
            )
        }
        .fullScreenCover(isPresented: $showSpeakingPractice) {
            SpeakingPracticeView(
                sessionTitle: languageManager.currentLanguage == .english ? "Pronunciation" : "Prononciation",
                sessionLetters: pool.letters,
                goalCount: 8,
                onCompletion: { showSpeakingPractice = false }
            )
        }
        .fullScreenCover(isPresented: $showFlashcards) {
            FlashcardsView()
        }
        .fullScreenCover(isPresented: $showMistakes) {
            MistakesReviewView()
        }
        .fullScreenCover(isPresented: $showResources) {
            ResourcesView()
        }
        .fullScreenCover(isPresented: $showMatching) {
            SpeedQuizView()
        }
        .fullScreenCover(isPresented: $showDictation) {
            DictationView()
        }
        .fullScreenCover(isPresented: $showSentenceBuilder) {
            SentenceBuilderView()
        }
        .sheet(isPresented: $showFreePractice) {
            FreePracticeView()
        }
    }
}

struct FreePracticeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedLevel: LevelProgress?

    private var isEnglish: Bool { languageManager.currentLanguage == .english }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.noorBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        let weakAreas = dataManager.weakAreas()
                        if !weakAreas.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text(isEnglish ? "Areas to improve" : "Points à améliorer")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                ForEach(weakAreas.prefix(3), id: \.type) { area in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.orange.opacity(0.2))
                                            .frame(width: 8, height: 8)
                                        Text(localizedType(area.type))
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.noorSecondary)
                                        Spacer()
                                        Text("\(area.count)")
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.orange.opacity(0.06))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }

                        let completed = dataManager.completedLevels()
                        if completed.isEmpty {
                            VStack(spacing: 16) {
                                EmotionalMascot(mood: .encouraging, size: 80)
                                Text(isEnglish ? "Complete levels to replay them!" : "Complète des niveaux pour les rejouer !")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.noorSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(completed, id: \.levelNumber) { level in
                                Button(action: { selectedLevel = level }) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(levelColor(level.levelType).opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: levelIcon(level.levelType))
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(levelColor(level.levelType))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(CourseContent.getLevelTitle(for: level.levelNumber, language: languageManager.currentLanguage))
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(.noorText)
                                            Text(CourseContent.getLevelSubtitle(for: level.levelNumber, language: languageManager.currentLanguage))
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.noorSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.noorGold.opacity(0.6))
                                            .font(.system(size: 20))
                                    }
                                    .padding(14)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(16)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(isEnglish ? "Replay Levels" : "Rejouer des niveaux")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.noorSecondary)
                    }
                }
            }
            .fullScreenCover(item: $selectedLevel) { level in
                NavigationStack {
                    switch level.levelType {
                    case .vowels:
                        VowelLessonView(levelNumber: level.levelNumber)
                    case .wordBuild:
                        WordAssemblyView(levelNumber: level.levelNumber, onCompletion: { selectedLevel = nil })
                    case .solarLunar:
                        SolarLunarLessonView(onCompletion: { selectedLevel = nil })
                    case .phrases:
                        PhraseLessonView(levelNumber: level.levelNumber, onCompletion: { selectedLevel = nil })
                    case .speaking:
                        let letterIds = CourseContent.getLevels(language: languageManager.currentLanguage)
                            .first(where: { $0.id == level.levelNumber })?.contentIds ?? []
                        let letters = ArabicLetter.alphabet.filter { letterIds.contains($0.id) }
                        SpeakingPracticeView(
                            sessionTitle: languageManager.currentLanguage == .english ? "Pronunciation" : "Prononciation",
                            sessionLetters: letters.isEmpty ? ArabicLetter.alphabet : letters,
                            goalCount: 5,
                            onCompletion: { selectedLevel = nil }
                        )
                    case .alphabet, .quiz:
                        let letters = ArabicLetter.letters(forLevel: level.levelNumber)
                        if letters.count == 1, let letter = letters.first {
                            LetterLessonView(letter: letter, levelNumber: level.levelNumber)
                        } else {
                            LevelDetailView(levelNumber: level.levelNumber, title: level.title)
                        }
                    }
                }
            }
        }
    }

    private func localizedType(_ type: String) -> String {
        let isEn = languageManager.currentLanguage == .english
        switch type {
        case "letter": return isEn ? "Letters" : "Lettres"
        case "word": return isEn ? "Words" : "Mots"
        case "phrase": return isEn ? "Phrases" : "Phrases"
        case "vowel": return isEn ? "Vowels" : "Voyelles"
        case "solarLunar": return isEn ? "Solar/Lunar" : "Solaire/Lunaire"
        case "speaking": return isEn ? "Speaking" : "Prononciation"
        default: return type.capitalized
        }
    }

    private func levelIcon(_ type: LevelType) -> String {
        switch type {
        case .alphabet: return "character.textbox"
        case .quiz: return "brain.head.profile"
        case .vowels: return "textformat"
        case .wordBuild: return "puzzlepiece.fill"
        case .solarLunar: return "sun.max.fill"
        case .phrases: return "text.bubble.fill"
        case .speaking: return "mic.fill"
        }
    }

    private func levelColor(_ type: LevelType) -> Color {
        switch type {
        case .alphabet: return .blue
        case .quiz: return .purple
        case .vowels: return .orange
        case .wordBuild: return .green
        case .solarLunar: return .yellow
        case .phrases: return .cyan
        case .speaking: return .red
        }
    }
}

struct ToolCard: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var action: (() -> Void)? = nil

    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
        self.subtitle = LocalizedStringKey(subtitle)
        self.action = action
    }

    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey, action: (() -> Void)? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
    }
}
