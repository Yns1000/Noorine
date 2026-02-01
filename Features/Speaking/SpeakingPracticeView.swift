import SwiftUI
import Speech

struct SpeakingPracticeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var currentLetter = ArabicLetter.alphabet.randomElement()!
    @State private var isListening = false
    @State private var showSuccess = false
    @State private var showFailure = false
    @State private var feedbackMessage = ""
    @State private var debugHeardText = ""
    @State private var failCount = 0
    @State private var showLibrary = false
    @State private var showTip = false
    
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                Spacer()
                letterDisplayView
                helpButtonsView
                mascotView
                feedbackView
                
                if !debugHeardText.isEmpty {
                    Text("\(t("Entendu :")) \(debugHeardText)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                
                Spacer()
                micButtonView
                skipButtonView
            }
            
            if showSuccess {
                successOverlay
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            speechManager.requestAuthorization()
            currentLetter = ArabicLetter.alphabet.randomElement()!
        }
        .onChange(of: speechManager.recognizedText) { newText in
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
            Text(LocalizedStringKey("L'Écho de Noorine"))
                .font(.headline)
                .foregroundColor(.noorGold)
            Spacer()
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
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private var letterDisplayView: some View {
        VStack(spacing: 12) {
            Text(currentLetter.isolated)
                .font(.system(size: 120, weight: .black, design: .rounded))
                .foregroundColor(.noorText)
                .shadow(color: .noorGold.opacity(0.2), radius: 25)
            
            Text(currentLetter.transliteration)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.noorGold)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.noorGold.opacity(0.12))
                )
        }
    }
    
    private var helpButtonsView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button(action: {
                    AudioManager.shared.playLetter(currentLetter.isolated)
                    HapticManager.shared.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(t("Écouter"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.purple.opacity(0.1)))
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) { showTip.toggle() }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(t("Astuce"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.orange.opacity(0.1)))
                }
            }
            .padding(.top, 20)
            
            if showTip {
                Text(LocalizedStringKey(currentLetter.pronunciationTip))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    private var mascotView: some View {
        EmotionalMascot(mood: mascotMood, size: 120, showAura: false)
            .scaleEffect(isListening ? 1.08 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isListening)
            .padding(.top, 24)
    }
    
    private var feedbackView: some View {
        Group {
            if !feedbackMessage.isEmpty {
                HStack(spacing: 8) {
                    if isListening {
                        audioLevelIndicator
                    }
                    
                    Text(feedbackMessage)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(showSuccess ? .green : (showFailure ? .red : (isListening ? .noorGold : .noorSecondary)))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .padding(.top, 16)
                .padding(.bottom, 24)
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
        VStack(spacing: 20) {
            ZStack {
                if isListening {
                    Circle()
                        .stroke(Color.noorGold.opacity(0.3), lineWidth: 3)
                        .frame(width: 110, height: 110)
                        .scaleEffect(1.2)
                        .opacity(0.5)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isListening)
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isListening ? [.noorGold, .orange] : [.white, .white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: isListening ? .orange.opacity(0.5) : .black.opacity(0.1), radius: 15, x: 0, y: 8)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isListening ? .white : .noorGold)
                    )
                    .scaleEffect(isListening ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3), value: isListening)
            }
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
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noorSecondary.opacity(0.8))
        }
        .padding(.bottom, 30)
    }
    
    private var skipButtonView: some View {
        Button(action: { withAnimation { nextLetter() } }) {
            HStack(spacing: 6) {
                Text(t("Passer"))
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.noorSecondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Capsule().stroke(Color.noorSecondary.opacity(0.3), lineWidth: 1.5))
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
                    EmotionalMascot(mood: .happy, size: 100, showAura: false)
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
                    .fill(Color(UIColor.systemBackground).opacity(0.95))
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
            mascotMood = .happy
            feedbackMessage = t("Bravo !")
            HapticManager.shared.trigger(.success)
            failCount = 0
            speechManager.stopRecording()
            isListening = false
            
        } else if finalCheck {
            showFailure = true
            mascotMood = .sad
            failCount += 1
            HapticManager.shared.trigger(.error)
            
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
    
    private func nextLetter() {
        currentLetter = ArabicLetter.alphabet.randomElement()!
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
        default: return key
        }
    }
}
