import SwiftUI

struct SolarLunarLessonView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentStep = 0
    @State private var selectedAnswer: ArabicLetter.LetterCategory?
    @State private var showFeedback = false
    @State private var correctCount = 0
    @State private var quizLetters: [ArabicLetter] = []
    @State private var currentQuizIndex = 0
    
    private let steps = ["intro", "solar", "lunar", "rule", "quiz", "complete"]
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                TabView(selection: $currentStep) {
                    introView.tag(0)
                    solarLettersView.tag(1)
                    lunarLettersView.tag(2)
                    ruleExplanationView.tag(3)
                    quizView.tag(4)
                    completionView.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: currentStep)
                
                if currentStep < 4 {
                    continueButton
                }
            }
        }
        .onAppear { prepareQuiz() }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
            }
            
            Spacer()
            
            ProgressIndicator(current: currentStep, total: steps.count - 1)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            HStack(spacing: 24) {
                CategoryIcon(category: .solar, size: 80)
                CategoryIcon(category: .lunar, size: 80)
            }
            
            VStack(spacing: 12) {
                Text(isEnglish ? "Sun & Moon Letters" : "Lettres Solaires & Lunaires")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(isEnglish
                     ? "Learn how the definite article 'Al' changes based on the first letter of a word"
                     : "Découvre comment l'article défini 'Al' change selon la première lettre du mot")
                    .font(.system(size: 16))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var solarLettersView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            CategoryIcon(category: .solar, size: 60)
            
            Text(isEnglish ? "Solar Letters" : "Lettres Solaires")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(isEnglish
                 ? "The 'L' sound in 'Al' is absorbed by these letters"
                 : "Le son 'L' de 'Al' est absorbé par ces lettres")
                .font(.subheadline)
                .foregroundColor(.noorSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            ExampleCard(
                word: "الشَّمْس",
                transliteration: "ash-shams",
                translation: isEnglish ? "the sun" : "le soleil",
                explanation: isEnglish
                    ? "ال + شمس → الشَّمْس (the L becomes Sh)"
                    : "ال + شمس → الشَّمْس (le L devient Sh)"
            )
            
            LetterGrid(letters: ArabicLetter.alphabet.filter { $0.isSolar }, accentColor: .orange)
            
            Spacer()
        }
    }
    
    private var lunarLettersView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            CategoryIcon(category: .lunar, size: 60)
            
            Text(isEnglish ? "Lunar Letters" : "Lettres Lunaires")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(isEnglish
                 ? "The 'L' sound in 'Al' stays unchanged"
                 : "Le son 'L' de 'Al' reste inchangé")
                .font(.subheadline)
                .foregroundColor(.noorSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            ExampleCard(
                word: "القَمَر",
                transliteration: "al-qamar",
                translation: isEnglish ? "the moon" : "la lune",
                explanation: isEnglish
                    ? "ال + قمر → القَمَر (the L stays)"
                    : "ال + قمر → القَمَر (le L reste)"
            )
            
            LetterGrid(letters: ArabicLetter.alphabet.filter { $0.isLunar }, accentColor: .blue)
            
            Spacer()
        }
    }
    
    private var ruleExplanationView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 40))
                .foregroundColor(.noorGold)
            
            Text(isEnglish ? "The Rule" : "La Règle")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.noorText)
            
            VStack(alignment: .leading, spacing: 16) {
                RuleRow(
                    icon: "sun.max.fill",
                    color: .orange,
                    title: isEnglish ? "Solar" : "Solaire",
                    description: isEnglish
                        ? "Double the first letter (shadda)"
                        : "On double la première lettre (shadda)"
                )
                
                RuleRow(
                    icon: "moon.fill",
                    color: .blue,
                    title: isEnglish ? "Lunar" : "Lunaire",
                    description: isEnglish
                        ? "Keep the 'L' sound of Al"
                        : "On garde le son 'L' de Al"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 24)
            
            Text(isEnglish
                 ? "Tip: Solar letters are pronounced with the tongue tip touching the teeth or gums"
                 : "Astuce : Les lettres solaires se prononcent avec la langue touchant les dents ou les gencives")
                .font(.system(size: 14))
                .foregroundColor(.noorSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
    
    private var quizView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if currentQuizIndex < quizLetters.count {
                let letter = quizLetters[currentQuizIndex]
                
                Text(isEnglish ? "Is this letter..." : "Cette lettre est-elle...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
                
                Text(letter.isolated)
                    .font(.system(size: 100))
                    .foregroundColor(.noorText)
                
                Text(letter.transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
                
                HStack(spacing: 20) {
                    QuizButton(
                        category: .solar,
                        isSelected: selectedAnswer == .solar,
                        isCorrect: showFeedback ? letter.isSolar : nil,
                        action: { selectAnswer(.solar, for: letter) }
                    )
                    
                    QuizButton(
                        category: .lunar,
                        isSelected: selectedAnswer == .lunar,
                        isCorrect: showFeedback ? letter.isLunar : nil,
                        action: { selectAnswer(.lunar, for: letter) }
                    )
                }
                .padding(.horizontal, 24)
                .disabled(showFeedback)
                
                if showFeedback {
                    feedbackView(for: letter)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text("\(currentQuizIndex + 1) / \(quizLetters.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            Spacer()
        }
        .animation(.spring(response: 0.4), value: showFeedback)
        .animation(.spring(response: 0.4), value: currentQuizIndex)
    }
    
    private func feedbackView(for letter: ArabicLetter) -> some View {
        let isCorrect = selectedAnswer == letter.letterCategory
        
        return VStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect
                 ? (isEnglish ? "Correct!" : "Correct !")
                 : (isEnglish ? "It's a \(letter.isSolar ? "solar" : "lunar") letter" : "C'est une lettre \(letter.isSolar ? "solaire" : "lunaire")"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isCorrect ? .green : .noorText)
        }
        .padding(.top, 16)
    }
    
    private var completionView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.noorGold)
            }
            
            VStack(spacing: 8) {
                Text(isEnglish ? "Lesson Complete!" : "Leçon terminée !")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(isEnglish
                     ? "You got \(correctCount)/\(quizLetters.count) correct"
                     : "Tu as eu \(correctCount)/\(quizLetters.count) bonnes réponses")
                    .font(.subheadline)
                    .foregroundColor(.noorSecondary)
            }
            
            HStack(spacing: 32) {
                StatView(
                    value: 14,
                    label: isEnglish ? "Solar" : "Solaires",
                    icon: "sun.max.fill",
                    color: .orange
                )
                StatView(
                    value: 14,
                    label: isEnglish ? "Lunar" : "Lunaires",
                    icon: "moon.fill",
                    color: .blue
                )
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text(isEnglish ? "Finish" : "Terminer")
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
    
    private var continueButton: some View {
        Button(action: { withAnimation { currentStep += 1 } }) {
            Text(isEnglish ? "Continue" : "Continuer")
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
    
    private func prepareQuiz() {
        let solar = ArabicLetter.alphabet.filter { $0.isSolar }.shuffled().prefix(3)
        let lunar = ArabicLetter.alphabet.filter { $0.isLunar }.shuffled().prefix(3)
        quizLetters = Array((solar + lunar)).shuffled()
    }
    
    private func selectAnswer(_ answer: ArabicLetter.LetterCategory, for letter: ArabicLetter) {
        selectedAnswer = answer
        showFeedback = true
        
        if answer == letter.letterCategory {
            correctCount += 1
            HapticManager.shared.trigger(.success)
        } else {
            HapticManager.shared.trigger(.error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showFeedback = false
                selectedAnswer = nil
                
                if currentQuizIndex < quizLetters.count - 1 {
                    currentQuizIndex += 1
                } else {
                    currentStep = 5
                }
            }
        }
    }
}

struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.noorGold : Color(.systemGray4))
                    .frame(width: index == current ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

struct CategoryIcon: View {
    let category: ArabicLetter.LetterCategory
    let size: CGFloat
    
    private var color: Color {
        category == .solar ? .orange : .blue
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            
            Image(systemName: category.icon)
                .font(.system(size: size * 0.45))
                .foregroundColor(color)
        }
    }
}

struct ExampleCard: View {
    let word: String
    let transliteration: String
    let translation: String
    let explanation: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(word)
                .font(.system(size: 44))
                .foregroundColor(.noorText)
            
            Text(transliteration)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.noorGold)
            
            Text(translation)
                .font(.system(size: 16))
                .foregroundColor(.noorSecondary)
            
            Divider().padding(.horizontal, 32)
            
            Text(explanation)
                .font(.system(size: 14))
                .foregroundColor(.noorSecondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 24)
    }
}

struct LetterGrid: View {
    let letters: [ArabicLetter]
    let accentColor: Color
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(letters) { letter in
                Text(letter.isolated)
                    .font(.system(size: 22))
                    .foregroundColor(.noorText)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accentColor.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 24)
    }
}

struct RuleRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorText)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
        }
    }
}

struct QuizButton: View {
    let category: ArabicLetter.LetterCategory
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    private var color: Color {
        category == .solar ? .orange : .blue
    }
    
    private var borderColor: Color {
        if let correct = isCorrect {
            return correct ? .green : .red
        }
        return isSelected ? color : .clear
    }
    
    private var backgroundColor: Color {
        if let correct = isCorrect {
            return correct ? .green.opacity(0.15) : .red.opacity(0.15)
        }
        return isSelected ? color.opacity(0.15) : Color(.secondarySystemGroupedBackground)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(LocalizedStringKey(category.nameKey))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.noorText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(borderColor, lineWidth: 3)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatView: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.noorSecondary)
        }
    }
}
