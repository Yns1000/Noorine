import SwiftUI

struct WordChoiceExercise: View {
    let prompt: String
    let options: [ArabicWord]
    let correctId: Int
    let onAnswer: (Bool) -> Void
    var allowRetry: Bool = true
    
    @State private var selectedId: Int? = nil
    @State private var locked = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(prompt)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(options) { option in
                    ChoiceOptionCard(
                        title: option.arabic,
                        subtitle: option.transliteration,
                        isSelected: selectedId == option.id,
                        isCorrect: option.id == correctId
                    )
                    .onTapGesture {
                        handleSelection(optionId: option.id)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func handleSelection(optionId: Int) {
        guard !locked else { return }
        selectedId = optionId
        let correct = optionId == correctId
        if correct {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            onAnswer(false)
            if allowRetry {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    selectedId = nil
                }
            } else {
                locked = true
            }
        }
    }
}

struct PhraseChoiceExercise: View {
    let prompt: String
    let options: [ArabicPhrase]
    let correctId: Int
    let onAnswer: (Bool) -> Void
    var allowRetry: Bool = true
    
    @State private var selectedId: Int? = nil
    @State private var locked = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(prompt)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(options) { option in
                    ChoiceOptionCard(
                        title: option.arabic,
                        subtitle: option.transliteration,
                        isSelected: selectedId == option.id,
                        isCorrect: option.id == correctId
                    )
                    .onTapGesture {
                        handleSelection(optionId: option.id)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func handleSelection(optionId: Int) {
        guard !locked else { return }
        selectedId = optionId
        let correct = optionId == correctId
        if correct {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            onAnswer(false)
            if allowRetry {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    selectedId = nil
                }
            } else {
                locked = true
            }
        }
    }
}

struct VowelChoiceExercise: View {
    let baseLetter: ArabicLetter
    let targetVowel: ArabicVowel
    let options: [ArabicVowel]
    let onAnswer: (Bool) -> Void
    var allowRetry: Bool = true
    
    @State private var selectedId: Int? = nil
    @State private var locked = false
    @State private var isPlaying = false
    @EnvironmentObject var languageManager: LanguageManager
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        VStack(spacing: 28) {
            Text(isEnglish ? "What sound do you hear?" : "Quel son entends-tu ?")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorText)
            
            Text(baseLetter.isolated)
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.noorText.opacity(0.3))
                .padding(.bottom, -8)
            
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.noorGold.opacity(isPlaying ? 0.3 - Double(i) * 0.1 : 0.08), lineWidth: 2)
                        .frame(width: 80 + CGFloat(i) * 30, height: 80 + CGFloat(i) * 30)
                        .scaleEffect(isPlaying ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                                .repeatCount(3, autoreverses: true)
                                .delay(Double(i) * 0.15),
                            value: isPlaying
                        )
                }
                
                Button(action: playTargetSound) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.noorGold, .orange],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 72, height: 72)
                            .shadow(color: .noorGold.opacity(0.4), radius: 10, y: 5)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 140)
            
            VStack(spacing: 12) {
                ForEach(options) { vowel in
                    ChoiceOptionCard(
                        title: baseLetter.isolated + vowel.symbol,
                        subtitle: "",
                        isSelected: selectedId == vowel.id,
                        isCorrect: vowel.id == targetVowel.id
                    )
                    .onTapGesture {
                        handleSelection(optionId: vowel.id)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                playTargetSound()
            }
        }
    }
    
    private func playTargetSound() {
        isPlaying = true
        let combo = baseLetter.isolated + targetVowel.symbol
        AudioManager.shared.playText(combo, style: .letter, useCache: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPlaying = false
        }
    }
    
    private func handleSelection(optionId: Int) {
        guard !locked else { return }
        selectedId = optionId
        let correct = optionId == targetVowel.id
        if correct {
            FeedbackManager.shared.success()
            locked = true
            onAnswer(true)
        } else {
            FeedbackManager.shared.error()
            onAnswer(false)
            if allowRetry {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    selectedId = nil
                }
            } else {
                locked = true
            }
        }
    }
}

struct ChoiceOptionCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isCorrect: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.noorText)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private var borderColor: Color {
        if isSelected && isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        return Color.black.opacity(0.05)
    }
    
    private var backgroundColor: Color {
        if isSelected && isCorrect { return Color.green.opacity(0.12) }
        if isSelected && !isCorrect { return Color.red.opacity(0.12) }
        return colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white
    }
}
