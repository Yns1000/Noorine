import SwiftUI
import Speech

struct SpeakingPracticeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var audioManager = AudioManager.shared
    
    let sessionTitle: String?
    let sessionLetters: [ArabicLetter]?
    let goalCount: Int?
    let onCompletion: (() -> Void)?
    
    @State private var currentLetter = ArabicLetter.alphabet.randomElement()!
    @State private var isListening = false
    @State private var showSuccess = false
    @State private var showFailure = false
    @State private var feedbackMessage = ""
    @State private var debugHeardText = ""
    @State private var failCount = 0
    @State private var showLibrary = false
    @State private var showTip = false
    @State private var completedCount = 0
    @State private var showLevelComplete = false
    
    @State private var mascotMood: EmotionalMascot.Mood = .neutral

    init(sessionTitle: String? = nil, sessionLetters: [ArabicLetter]? = nil, goalCount: Int? = nil, onCompletion: (() -> Void)? = nil) {
        self.sessionTitle = sessionTitle
        self.sessionLetters = sessionLetters
        self.goalCount = goalCount
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                Spacer(minLength: 4)

                letterDisplayView

                helpButtonsView

                mascotView

                feedbackSection

                Spacer(minLength: 4)

                micButtonView
                skipButtonView
            }
            
            if showSuccess {
                successOverlay
            }
            
            if showLevelComplete {
                SpeakingLevelCompleteOverlay(
                    onClose: {
                        showLevelComplete = false
                        onCompletion?()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            speechManager.requestAuthorization()
            currentLetter = letterPool.randomElement() ?? ArabicLetter.alphabet.randomElement()!
        }
        .onChange(of: speechManager.recognizedText) { _, newText in
            if isListening && !showSuccess {
                debugHeardText = newText
                let cleaned = cleanString(newText)
                if checkMatch(heard: cleaned, target: currentLetter) {
                    validatePronunciation(finalCheck: false)
                }
            }
        }
        .sheet(isPresented: $showLibrary) {
            PronunciationLibraryView(onSelect: { letter in
                currentLetter = letter
                showLibrary = false
                resetState()
            })
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
            }
            Spacer()
            Text(LocalizedStringKey(sessionTitle ?? "L'Écho de Noorine"))
                .font(.headline)
                .foregroundColor(.noorGold)
            Spacer()
            if sessionLetters == nil {
                Button(action: { showLibrary = true }) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                }
            } else {
                progressChip
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var progressChip: some View {
        let goal = goalCount ?? 0
        return HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 12))
            Text("\(completedCount)/\(goal)")
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(.noorGold)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.noorGold.opacity(0.12)))
    }
    
    private var letterDisplayView: some View {
        VStack(spacing: 6) {
            Text(currentLetter.isolated)
                .font(.system(size: 90, weight: .black, design: .rounded))
                .foregroundColor(.noorText)
                .shadow(color: .noorGold.opacity(0.2), radius: 20)

            Text(currentLetter.transliteration)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.noorGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(Color.noorGold.opacity(0.12))
                )

            if let goal = goalCount {
                HStack(spacing: 8) {
                    ProgressView(value: min(1.0, Double(completedCount) / Double(max(goal, 1))))
                        .tint(.noorGold)
                        .frame(maxWidth: 160)

                    Text("\(completedCount)/\(goal)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var helpButtonsView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button(action: {
                    AudioManager.shared.playLetter(currentLetter.isolated)
                    HapticManager.shared.impact(.light)
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(t("Écouter"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.purple.opacity(0.1)))
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3)) { showTip.toggle() }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(t("Astuce"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.orange.opacity(0.1)))
                }
            }
            .padding(.top, 10)

            if showTip {
                Text(LocalizedStringKey(currentLetter.pronunciationTip))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    private var mascotView: some View {
        EmotionalMascot(mood: mascotMood, size: 70, showAura: false)
            .scaleEffect(isListening ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isListening)
            .frame(width: 70, height: 70)
            .padding(.top, 12)
    }
    
    private var feedbackView: some View {
        Group {
            if !feedbackMessage.isEmpty {
                HStack(spacing: 6) {
                    if isListening {
                        audioLevelIndicator
                    }

                    Text(feedbackMessage)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(showSuccess ? .green : (showFailure ? .red : (isListening ? .noorGold : .noorSecondary)))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private var feedbackSection: some View {
        VStack(spacing: 4) {
            feedbackView
            debugTextSection
        }
        .frame(height: 80)
        .clipped()
    }

    private var debugTextSection: some View {
        VStack(spacing: 2) {
            if !debugHeardText.isEmpty {
                Text("\(t("Entendu :")) \(debugHeardText)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                let phonetic = phoneticForSpeech(debugHeardText)
                if !phonetic.isEmpty && phonetic != debugHeardText {
                    Text("\(t("Phonétique :")) \(phonetic)")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.9))
                }
            } else {
                Color.clear.frame(height: 1)
            }
        }
    }
    
    private var audioLevelIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.noorGold)
                    .frame(width: 3, height: 6 + CGFloat(speechManager.audioLevel * 14))
                    .animation(
                        .easeInOut(duration: 0.12)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.04),
                        value: speechManager.audioLevel
                    )
            }
        }
    }
    
    private var micButtonView: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.noorGold.opacity(isListening ? 0.3 : 0), lineWidth: 2.5)
                    .frame(width: 96, height: 96)
                    .scaleEffect(isListening ? 1.15 : 1.0)
                    .opacity(isListening ? 0.5 : 0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isListening)

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isListening ? [.noorGold, .orange] : [.white, .white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: isListening ? .orange.opacity(0.5) : .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(isListening ? .white : .noorGold)
                    )
                    .scaleEffect(isListening ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3), value: isListening)
            }
            .frame(width: 110, height: 110)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isListening {
                            startListening()
                        }
                    }
                    .onEnded { _ in
                        stopListening()
                    }
            )

            Text(t("Maintiens pour parler"))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.noorSecondary.opacity(0.7))
        }
        .padding(.bottom, 8)
    }
    
    private var skipButtonView: some View {
        Button(action: { withAnimation { nextLetter() } }) {
            HStack(spacing: 5) {
                Text(t("Passer"))
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.noorSecondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Capsule().stroke(Color.noorSecondary.opacity(0.25), lineWidth: 1.5))
        }
        .padding(.bottom, 20)
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.noorGold.opacity(0.3), .clear]), center: .center, startRadius: 40, endRadius: 100))
                        .frame(width: 180, height: 180)
                    EmotionalMascot(mood: .surprised, size: 100, showAura: false)
                }
                
                VStack(spacing: 12) {
                    Text(t("Excellent !"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(t("Tu as bien prononcé la lettre."))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.15).opacity(0.97))
                    .shadow(color: .black.opacity(0.3), radius: 40, y: 10)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .zIndex(100)
        .onTapGesture {
            withAnimation { showSuccess = false; nextLetter() }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showSuccess = false; nextLetter() }
            }
        }
    }
        
    private func startListening() {
        guard speechManager.authorizationStatus == .authorized else {
            feedbackMessage = t("Autorisation micro requise")
            return
        }
        
        speechManager.recognizedText = ""
        debugHeardText = ""
        showFailure = false
        
        isListening = true
        mascotMood = .happy
        feedbackMessage = t("J'écoute...")
        HapticManager.shared.impact(.medium)
        
        do { try speechManager.startRecording() }
        catch { isListening = false; mascotMood = .sad }
    }
    
    private func stopListening() {
        mascotMood = .thinking
        speechManager.stopRecording()
        feedbackMessage = t("Analyse...")
        HapticManager.shared.impact(.light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !showSuccess {
                isListening = false
                validatePronunciation(finalCheck: true)
            }
        }
    }
    
    private func validatePronunciation(finalCheck: Bool) {
        if showSuccess { return }
        
        let recognizedRaw = speechManager.recognizedText
        debugHeardText = recognizedRaw
        
        let recognized = cleanString(recognizedRaw)
        let isValid = checkMatch(heard: recognized, target: currentLetter)
        
        if isValid {
            withAnimation { showSuccess = true }
            mascotMood = .celebrating
            feedbackMessage = t("Bravo !")
            FeedbackManager.shared.success()
            failCount = 0
            speechManager.stopRecording()
            isListening = false
            if let goal = goalCount {
                completedCount += 1
                if completedCount >= goal {
                    showLevelComplete = true
                }
            }
            
        } else if finalCheck {
            showFailure = true
            mascotMood = .encouraging
            failCount += 1
            FeedbackManager.shared.error()
            dataManager.addMistake(itemId: String(currentLetter.id), type: "speaking")
            
            if recognized.isEmpty {
                feedbackMessage = t("Je n'ai rien entendu...")
            } else {
                feedbackMessage = t("Pas tout à fait...")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if mascotMood == .sad { mascotMood = .neutral }
            }
        }
    }
    
    private func checkMatch(heard: String, target: ArabicLetter) -> Bool {
        return PhoneticDictionary.shared.isMatch(heard: heard, target: target)
    }
    
    private func cleanString(_ input: String) -> String {
        return input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func phoneticForSpeech(_ input: String) -> String {
        guard containsArabicCharacters(input) else { return input }
        return transliterateArabic(input)
    }
    
    private func containsArabicCharacters(_ input: String) -> Bool {
        return input.unicodeScalars.contains { scalar in
            (0x0600...0x06FF).contains(scalar.value) || (0x0750...0x077F).contains(scalar.value) || (0x08A0...0x08FF).contains(scalar.value)
        }
    }
    
    private func transliterateArabic(_ input: String) -> String {
        let map: [Character: String] = [
            "ا": "a", "أ": "a", "إ": "i", "آ": "aa", "ء": "'", "ؤ": "u", "ئ": "i",
            "ب": "b", "ت": "t", "ث": "th", "ج": "j", "ح": "h", "خ": "kh",
            "د": "d", "ذ": "dh", "ر": "r", "ز": "z", "س": "s", "ش": "sh",
            "ص": "s", "ض": "d", "ط": "t", "ظ": "z", "ع": "‘", "غ": "gh",
            "ف": "f", "ق": "q", "ك": "k", "ل": "l", "م": "m", "ن": "n",
            "ه": "h", "و": "w", "ي": "y", "ى": "a", "ة": "a",
            "ً": "an", "ٌ": "un", "ٍ": "in", "َ": "a", "ُ": "u", "ِ": "i", "ْ": "", "ّ": ""
        ]
        
        var result = ""
        for ch in input {
            if let mapped = map[ch] {
                result.append(mapped)
            } else {
                result.append(ch)
            }
        }
        return result.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func nextLetter() {
        currentLetter = letterPool.randomElement() ?? ArabicLetter.alphabet.randomElement()!
        resetState()
    }
    
    private func resetState() {
        feedbackMessage = ""
        mascotMood = .neutral
        showFailure = false
        failCount = 0
        showTip = false
        debugHeardText = ""
        speechManager.recognizedText = ""
    }

    private var letterPool: [ArabicLetter] {
        sessionLetters ?? ArabicLetter.alphabet
    }

    private func t(_ key: String) -> String {
        if languageManager.currentLanguage == .french {
            return key
        }
        
        switch key {
        case "Maintiens pour parler": return "Hold to speak"
        case "Écouter": return "Listen"
        case "Astuce": return "Tip"
        case "Passer": return "Skip"
        case "J'écoute...": return "Listening..."
        case "Analyse...": return "Analyzing..."
        case "Bravo !": return "Well done!"
        case "Je n'ai rien entendu...": return "I didn't hear anything..."
        case "Pas tout à fait...": return "Not quite..."
        case "Excellent !": return "Excellent!"
        case "Tu as bien prononcé la lettre.": return "You pronounced it correctly."
        case "Autorisation micro requise": return "Microphone permission required"
        case "Entendu :": return "Heard:"
        case "Phonétique :": return "Phonetic:"
        default: return key
        }
    }
}

private struct SpeakingLevelCompleteOverlay: View {
    let onClose: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        let isEnglish = languageManager.currentLanguage == .english
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.noorGold.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.noorGold)
                }
                
                Text(LocalizedStringKey(isEnglish ? "Level cleared!" : "Niveau validé !"))
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey(isEnglish ? "Your pronunciation is improving fast." : "Ta prononciation progresse vite."))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button(action: onClose) {
                    Text(LocalizedStringKey(isEnglish ? "Continue" : "Continuer"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.noorDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.noorGold)
                        .cornerRadius(24)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(UIColor.systemBackground).opacity(0.95))
            )
            .padding(.horizontal, 32)
        }
    }
}
