import SwiftUI
import UIKit

struct FreeDrawingStep: View {
    let letter: ArabicLetter
    let formType: LetterFormType
    let onComplete: () -> Void
    
    @StateObject private var model = DrawingCanvasModel()
    @State private var showSuccess = false
    @State private var mascotMessage = "Le savais-tu ?"
    @State private var mascotDetail = ArabicFunFacts.randomFact()
    @State private var accentColor = Color.noorGold
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    @State private var showManualValidation = false
    @State private var currentFunFact = ArabicFunFacts.randomFact()
    @State private var hasTriedOnce = false
    @State private var showFailure = false
    
    var isChallengeMode: Bool = false
    var onChallengeComplete: ((Bool) -> Void)? = nil
    
    let canvasSize = CGSize(width: 250, height: 250)
    let requiredScore: Double = 0.50
    
    @EnvironmentObject var languageManager: LanguageManager
    
    var currentForm: String {
        formType.getForm(from: letter)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                Color.clear.frame(width: 44, height: 44)
                
                VStack(spacing: 4) {
                    if isChallengeMode {
                        Text(letter.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.noorText)
                        
                        Text(letter.transliteration)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.noorGold)
                        
                        Text(LocalizedStringKey("Forme \(languageManager.localizedString(formType.rawValue).lowercased())"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.noorSecondary)
                            .padding(.top, 2)
                    } else {
                        Text(LocalizedStringKey("Forme \(languageManager.localizedString(formType.rawValue).lowercased())"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.noorSecondary)
                        
                        Text(currentForm)
                            .font(.system(size: 90, weight: .regular))
                            .foregroundColor(.noorGold)
                        
                        Text(letter.transliteration)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.noorSecondary.opacity(0.8))
                    }
                }
                
                Button(action: {
                    AudioManager.shared.playLetter(currentForm)
                    HapticManager.shared.impact(.light)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.noorGold.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.noorGold)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemBackground).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                showSuccess ? Color.green : (showFailure ? Color.red : Color.noorSecondary.opacity(0.3)),
                                lineWidth: (showSuccess || showFailure) ? 3 : 2
                            )
                    )
                
                FreeDrawingCanvas(
                    model: model,
                    referenceText: currentForm,
                    canvasSize: canvasSize
                )
            }
            .frame(width: canvasSize.width + 10, height: canvasSize.height + 10)
            .padding(.top, 8)
            
            if hasTriedOnce && model.hasContent {
                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                            
                            Capsule()
                                .fill(similarityColor)
                                .frame(width: geo.size.width * model.similarity)
                                .animation(.easeInOut, value: model.similarity)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(model.similarity * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(similarityColor)
                        .frame(width: 32)
                }
                .padding(.horizontal, 50)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
            if !showSuccess && !showFailure {
                Button(action: clearDrawing) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text(LocalizedStringKey("Effacer"))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.noorSecondary.opacity(0.3), lineWidth: 1.5)
                    )
                }
            }
                
                Button(action: validateDrawing) {
                    HStack(spacing: 4) {
                        if model.isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.white)
                        } else {
                            Image(systemName: (showSuccess || showFailure) ? "checkmark" : "sparkle.magnifyingglass")
                        }
                        Text(LocalizedStringKey(showSuccess ? "Continuer" : (showFailure ? "Suivant" : "Vérifier")))
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(
                                showSuccess
                                    ? LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                    : (showFailure ? LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.noorGold, .noorGold.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            )
                    )
                }
                .disabled(model.strokes.isEmpty || model.isAnalyzing)
            }
            .padding(.top, 12)
            
            if showManualValidation && !showSuccess {
                Button(action: manualValidation) {
                    Text(LocalizedStringKey("Je pense que c'est correct"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.noorSecondary.opacity(0.8))
                        .underline()
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            MascotWithBubble(
                message: mascotMessage,
                detail: mascotDetail,
                accentColor: accentColor,
                mood: mascotMood,
                mascotSize: 80
            )
            .padding(.bottom, 30)
            .onAppear {
                mascotDetail = ArabicFunFacts.randomFact()
            }
        }
    }
    
    var similarityColor: Color {
        if model.similarity >= requiredScore {
            return .green
        } else if model.similarity >= requiredScore * 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func clearDrawing() {
        model.clear()
        let newFact = ArabicFunFacts.randomFact()
        mascotMessage = "Le savais-tu ?"
        mascotDetail = newFact
        accentColor = .noorGold
        showSuccess = false
        mascotMood = .neutral
        showManualValidation = false
    }
    
    private func manualValidation() {
        showSuccess = true
        model.isValidated = true
        mascotMood = .happy
        mascotMessage = "Je te fais confiance"
        mascotDetail = "Excuse-moi si mon analyse n'était pas juste"
        accentColor = .green
        
        HapticManager.shared.trigger(.success)
        AudioManager.shared.playSystemSound(1054)
    }
    
    private func validateDrawing() {
        if showSuccess || showFailure {
            if isChallengeMode {
                onChallengeComplete?(showSuccess)
            } else {
                onComplete()
            }
            return
        }
        
        model.isAnalyzing = true
        mascotMood = .thinking
        mascotMessage = "Hmm, laisse-moi voir..."
        mascotDetail = ""
        accentColor = .noorGold
        
        let userDrawing = model.renderDrawing(size: canvasSize)
        let fontSize = min(canvasSize.width, canvasSize.height) * 0.65
        let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        let referenceImage = DrawingCanvasModel.renderReferenceLetter(currentForm, size: canvasSize, font: font)
        
        RecognitionEngine.evaluate(
            userDrawing: userDrawing,
            referenceImage: referenceImage,
            expectedLetter: currentForm
        ) { result in
            model.similarity = result.score
            model.recognizedText = result.recognizedText ?? ""
            model.isAnalyzing = false
            hasTriedOnce = true
            
            if result.score >= requiredScore {
                showSuccess = true
                model.isValidated = true
                mascotMood = .happy
                mascotMessage = "Bravo, c'est parfait"
                mascotDetail = "Tu maîtrises cette forme"
                accentColor = .green
                showManualValidation = false
                
                HapticManager.shared.trigger(.success)
                AudioManager.shared.playSystemSound(1054)
            } else if result.score >= requiredScore * 0.6 {
                mascotMood = .neutral
                mascotMessage = "Tu y es presque"
                accentColor = .orange
                showManualValidation = true
                
                if let shape = result.shapeAnalysis {
                    if shape.strokeCoverage < 0.4 {
                        mascotDetail = "Essaie de couvrir toute la lettre"
                    } else if shape.overflowPenalty > 0.4 {
                        mascotDetail = "Reste dans les limites"
                    } else {
                        mascotDetail = ArabicFunFacts.randomEncouragement()
                    }
                }
                
                HapticManager.shared.trigger(.warning)
                AudioManager.shared.playSystemSound(1051)
            } else {
                mascotMood = .sad
                mascotMessage = "On réessaie ensemble"
                mascotDetail = ArabicFunFacts.randomEncouragement()
                accentColor = .noorSecondary
                showManualValidation = true
                
                currentFunFact = ArabicFunFacts.randomFact()
                
                HapticManager.shared.trigger(.error)
                AudioManager.shared.playSystemSound(1053)
                
                DataManager.shared.addMistake(
                    itemId: String(letter.id),
                    type: "letter",
                    formType: formType.rawValue
                )
                
                if isChallengeMode {
                    showFailure = true
                    mascotMessage = "C'est pas bon..."
                    mascotDetail = "On passe à la lettre suivante."
                }
            }
        }
    }
}
