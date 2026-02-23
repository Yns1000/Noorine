import SwiftUI

struct DialogueView: View {
    let levelNumber: Int
    var onCompletion: (() -> Void)? = nil

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var dialogue: Dialogue? = nil
    @State private var visibleLineCount = 0
    @State private var selectedOption: String? = nil
    @State private var isAnswerRevealed = false
    @State private var score = 0
    @State private var totalQuestions = 0
    @State private var showCelebration = false
    @State private var shakeWrong = false

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    private var currentLine: DialogueLine? {
        guard let dialogue = dialogue, visibleLineCount < dialogue.lines.count else { return nil }
        return dialogue.lines[visibleLineCount]
    }

    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            if dialogue == nil {
                VStack {
                    ProgressView()
                    Text(isEnglish ? "Loading..." : "Chargement...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.noorSecondary)
                }
                .onAppear { loadDialogue() }
            } else if showCelebration {
                celebrationView
            } else {
                VStack(spacing: 0) {
                    headerBar
                    chatArea
                }
            }
        }
        .navigationBarHidden(true)
    }

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

            if let dialogue = dialogue {
                Text(isEnglish ? dialogue.titleEn : dialogue.titleFr)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
            }

            Spacer()

            EmotionalMascot(mood: .encouraging, size: 36, showAura: false)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var chatArea: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        if let dialogue = dialogue {
                            ForEach(Array(dialogue.lines.prefix(visibleLineCount).enumerated()), id: \.element.id) { index, line in
                                ChatBubble(
                                    line: line,
                                    isEnglish: isEnglish,
                                    isLastVisible: index == visibleLineCount - 1
                                )
                                .id("line_\(line.id)")
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
                .onChange(of: visibleLineCount) { _, count in
                    if let dialogue = dialogue, count > 0 {
                        let lineId = dialogue.lines[count - 1].id
                        withAnimation(.spring(response: 0.3)) {
                            proxy.scrollTo("line_\(lineId)", anchor: .bottom)
                        }
                    }
                }
            }

            if let line = currentLine {
                if line.isUserTurn, let options = line.options, !options.isEmpty {
                    optionsPanel(options: options, correctAnswer: line.arabic)
                } else {
                    continueButton
                }
            } else if let dialogue = dialogue, visibleLineCount >= dialogue.lines.count {
                finishButton
            }
        }
    }

    private func optionsPanel(options: [String], correctAnswer: String) -> some View {
        VStack(spacing: 8) {
            Text(isEnglish ? "Choose the right answer:" : "Choisis la bonne réponse :")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.noorSecondary)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        guard !isAnswerRevealed else { return }
                        selectOption(option, correct: correctAnswer)
                    }) {
                        Text(option)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(optionColor(option, correct: correctAnswer))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(optionBg(option, correct: correctAnswer))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(optionBorder(option, correct: correctAnswer), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .offset(x: shakeWrong && option == selectedOption && option != correctAnswer ? -8 : 0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.noorBackground)
    }

    private func optionColor(_ option: String, correct: String) -> Color {
        guard isAnswerRevealed else { return .noorText }
        if option == correct { return .green }
        if option == selectedOption { return .red }
        return .noorSecondary
    }

    private func optionBg(_ option: String, correct: String) -> Color {
        guard isAnswerRevealed else {
            return option == selectedOption ? Color.noorGold.opacity(0.1) : Color.noorSecondary.opacity(0.06)
        }
        if option == correct { return Color.green.opacity(0.1) }
        if option == selectedOption { return Color.red.opacity(0.1) }
        return Color.noorSecondary.opacity(0.04)
    }

    private func optionBorder(_ option: String, correct: String) -> Color {
        guard isAnswerRevealed else {
            return option == selectedOption ? Color.noorGold.opacity(0.3) : Color.clear
        }
        if option == correct { return Color.green.opacity(0.5) }
        if option == selectedOption { return Color.red.opacity(0.5) }
        return Color.clear
    }

    private var continueButton: some View {
        Button(action: advanceLine) {
            Text(isEnglish ? "Continue" : "Continuer")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.noorDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.noorGold)
                .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.noorBackground)
    }

    private var finishButton: some View {
        Button(action: finishDialogue) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text(isEnglish ? "Finish" : "Terminer")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.noorDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.noorBackground)
    }

    private func selectOption(_ option: String, correct: String) {
        selectedOption = option
        isAnswerRevealed = true
        totalQuestions += 1

        if option == correct {
            score += 1
            HapticManager.shared.impact(.medium)
        } else {
            HapticManager.shared.impact(.rigid)
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) {
                shakeWrong = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shakeWrong = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceLine()
        }
    }

    private func advanceLine() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            visibleLineCount += 1
            selectedOption = nil
            isAnswerRevealed = false
        }
    }

    private func finishDialogue() {
        HapticManager.shared.impact(.heavy)
        withAnimation(.easeInOut(duration: 0.3)) {
            showCelebration = true
        }
    }

    private func loadDialogue() {
        let levelDefs = CourseContent.getLevels(language: languageManager.currentLanguage)
        guard let levelDef = levelDefs.first(where: { $0.id == levelNumber }),
              let dialogueId = levelDef.contentIds.first else {
            return
        }
        dialogue = CourseContent.dialogues.first(where: { $0.id == dialogueId })
        totalQuestions = dialogue?.lines.filter { $0.isUserTurn }.count ?? 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            advanceLine()
        }
    }

    private var celebrationView: some View {
        UnifiedCelebrationView(
            data: CelebrationData(
                type: .levelComplete,
                title: LocalizedStringKey(isEnglish ? "Conversation Complete!" : "Conversation Terminée !"),
                subtitle: LocalizedStringKey(
                    totalQuestions > 0
                        ? (isEnglish ? "\(score)/\(totalQuestions) correct" : "\(score)/\(totalQuestions) correct")
                        : (isEnglish ? "Well done!" : "Bravo !")
                ),
                score: score,
                total: max(totalQuestions, 1),
                xpEarned: GameConstants.XP.levelCompleted,
                showStars: totalQuestions > 0
            ),
            onDismiss: {
                dataManager.completeLevel(levelNumber: levelNumber)
                onCompletion?()
                dismiss()
            }
        )
    }
}

struct ChatBubble: View {
    let line: DialogueLine
    let isEnglish: Bool
    let isLastVisible: Bool

    private var isSpeakerA: Bool { line.speaker == "A" }
    private var translation: String { isEnglish ? line.translationEn : line.translationFr }

    var body: some View {
        HStack {
            if !isSpeakerA { Spacer(minLength: 50) }

            VStack(alignment: isSpeakerA ? .leading : .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: isSpeakerA ? "person.fill" : "person.wave.2.fill")
                        .font(.system(size: 10))
                    Text(line.speaker == "A"
                         ? (isEnglish ? "Speaker" : "Locuteur")
                         : (isEnglish ? "You" : "Toi"))
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(isSpeakerA ? .noorSecondary : .noorGold)

                VStack(alignment: .leading, spacing: 8) {
                    Text(line.arabic)
                        .font(.system(size: 22, weight: .semibold))
                        .environment(\.layoutDirection, .rightToLeft)

                    Text(line.transliteration)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(isSpeakerA ? .white.opacity(0.7) : .noorDark.opacity(0.6))

                    Text(translation)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(isSpeakerA ? .white.opacity(0.5) : .noorDark.opacity(0.5))
                        .italic()
                }
                .padding(14)
                .background(bubbleBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            if isSpeakerA { Spacer(minLength: 50) }
        }
    }

    private var bubbleBackground: some View {
        Group {
            if isSpeakerA {
                Color.white.opacity(0.1)
            } else {
                LinearGradient(
                    colors: [Color.noorGold.opacity(0.9), Color.orange.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}
