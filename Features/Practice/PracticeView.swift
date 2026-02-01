import SwiftUI
import SwiftData
import Speech
import AVFoundation
import UIKit

struct PracticeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        PracticeHeader()
                            .padding(.top, 10)
                        
                        DailyChallengeCard()
                        
                        PracticeToolsGrid()
                        
                        WordsReviewList()
                        
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PracticeHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("RÉVISIONS"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .tracking(2)
                
                Text(LocalizedStringKey("Centre d'entraînement"))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
            }
            Spacer()
        }
    }
}

struct DailyChallengeCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.noorGold, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 15, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                        Text(LocalizedStringKey("DÉFI QUOTIDIEN"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    
                    Text(LocalizedStringKey("Renforce ta mémoire"))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    NavigationLink(destination: DailyChallengeView()) {
                        Text(LocalizedStringKey("LANCER (+60 XP)"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                
                Spacer()
                
                NoorineMascot()
                    .frame(width: 100, height: 100)
                    .offset(x: -10, y: 10)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
        .frame(height: 160)
    }
}

struct PracticeToolsGrid: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showSpeakingPractice = false
    @State private var showFlashcards = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ToolCard(icon: "rectangle.on.rectangle.angled", color: .blue, title: "Flashcards", subtitle: "40 mots", action: {
                showFlashcards = true
            })
            
            NavigationLink(destination: ListeningModuleView()) {
                ToolCard(icon: "waveform", color: .purple, title: "Écoute", subtitle: "Audio pur")
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: MistakesReviewView()) {
                ToolCard(
                    icon: "heart.slash.fill",
                    color: .red,
                    title: "Erreurs",
                    subtitle: "\(dataManager.mistakes.count) à corriger"
                )
            }
            .buttonStyle(PlainButtonStyle())

            ToolCard(icon: "mic.fill", color: .green, title: "Parler", subtitle: "Prononciation", action: {
                showSpeakingPractice = true
            })
        }
        .fullScreenCover(isPresented: $showSpeakingPractice) {
            SpeakingPracticeView()
        }
        .fullScreenCover(isPresented: $showFlashcards) {
            FlashcardsView()
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

struct WordsReviewList: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(LocalizedStringKey("À revoir bientôt"))
                    .font(.headline)
                    .foregroundColor(.noorText)
                
                Spacer()
                
                Button("Tout voir") { }
                    .font(.caption)
                    .foregroundColor(.noorGold)
            }
            
            VStack(spacing: 0) {
                ReviewRow(arabic: "كِتَاب", phonetic: "Kitāb", translation: "Livre", strength: 0.3)
                Divider().padding(.leading, 60)
                ReviewRow(arabic: "قَلَم", phonetic: "Qalam", translation: "Stylo", strength: 0.5)
                Divider().padding(.leading, 60)
                ReviewRow(arabic: "مَدْرَسَة", phonetic: "Madrasa", translation: "École", strength: 0.8)
            }
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
        }
    }
}

struct ReviewRow: View {
    let arabic: String
    let phonetic: String
    let translation: String
    let strength: Double
    
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
                
                Text(arabic)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorText)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(translation)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorText)
                
                Text(phonetic)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.title2)
                    .foregroundColor(.noorSecondary.opacity(0.5))
            }
        }
        .padding(16)
    }
    
    var strengthColor: Color {
        if strength < 0.4 { return .red }
        if strength < 0.7 { return .orange }
        return .green
    }
}

#Preview {
    PracticeView()
}



// MARK: - LISTENING MODULE VIEW
struct ListeningModuleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.noorGold)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            )
                        }
                        
                        Text(LocalizedStringKey("Écoute"))
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    NavigationLink(destination: AlphabetAudioView()) {
                        AlphabetHeroCard()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey("Catégories à venir"))
                            .font(.headline)
                            .foregroundColor(.noorSecondary)
                        
                        HStack(spacing: 15) {
                            FutureModuleCard(icon: "message.fill", title: "Mots courants", color: .blue)
                            FutureModuleCard(icon: "quote.bubble.fill", title: "Phrases", color: .green)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(20)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AlphabetHeroCard: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.noorGold, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 15, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey("Alphabet Arabe"))
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(LocalizedStringKey("Apprends la prononciation correcte de chaque lettre."))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(LocalizedStringKey("28 lettres"))
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        
                        Text(LocalizedStringKey("Audio HD"))
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .foregroundColor(.white)
                    .padding(.top, 8)
                }
                Spacer()
            }
            .padding(24)
            
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.15))
                .offset(x: 10, y: 20)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

struct FutureModuleCard: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color.opacity(0.5))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.noorSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - ALPHABET AUDIO VIEW
struct AlphabetAudioView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var audioManager = AudioManager.shared
    @State private var currentFactKey = ArabicFunFacts.randomFact()
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorGold)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(LocalizedStringKey("Prononciation"))
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                        
                        Text(LocalizedStringKey("28 lettres"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.noorSecondary)
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        TipBanner(factKey: currentFactKey)
                            .onTapGesture {
                                withAnimation {
                                    currentFactKey = ArabicFunFacts.randomFact()
                                }
                            }
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(ArabicLetter.alphabet) { letter in
                                LetterAudioCard(letter: letter) {
                                    audioManager.playLetter(letter.isolated)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


struct LetterAudioCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isPlaying = false
    let letter: ArabicLetter
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            HapticManager.shared.impact(.medium)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPlaying = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isPlaying = false
                }
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Text(letter.isolated)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.noorText)
                }
                .frame(height: 60)
                
                VStack(spacing: 2) {
                    Text(letter.transliteration)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.noorText)
                    
                    Text(letter.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.noorSecondary)
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isPlaying ? Color.noorGold.opacity(0.5) : Color.black.opacity(0.03), lineWidth: isPlaying ? 2 : 1.5)
            )
            .scaleEffect(isPlaying ? 1.05 : 1.0)
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TipBanner: View {
    @Environment(\.colorScheme) var colorScheme
    let factKey: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.noorGold.opacity(0.1))
                    .frame(width: 38, height: 38)
                
                NoorineMascot(size: 42, showAura: false)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey("Le savais-tu ?"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorGold)
                
                Text(LocalizedStringKey(factKey))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "arrow.2.circlepath")
                .font(.system(size: 12))
                .foregroundColor(.noorSecondary.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

// MARK: - MISTAKES REVIEW VIEW
struct MistakesReviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentMistake: MistakeItem?
    @State private var currentLetter: ArabicLetter?
    @State private var currentForm: LetterFormType = .isolated
    
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackColor = Color.green
    @State private var feedbackIcon = "checkmark.circle.fill"
    @State private var showExitAlert = false
    
    @State private var stepId = UUID()
    
    private func resetPartialProgress() {
        for mistake in dataManager.mistakes {
            if mistake.correctionCount == 1 {
                mistake.correctionCount = 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        let hasPartialProgress = dataManager.mistakes.contains { $0.correctionCount == 1 }
                        
                        if hasPartialProgress {
                            withAnimation { showExitAlert = true }
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            )
                    }
                    
                    Spacer()
                    
                    if !dataManager.mistakes.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.slash.fill")
                                .foregroundColor(.red)
                            Text("\(dataManager.mistakes.count) à corriger")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                if dataManager.mistakes.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                        
                        Text("Tout est propre !")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.noorText)
                        
                        Text("Aucune erreur à corriger pour le moment.\nContinue comme ça !")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { dismiss() }) {
                            Text("Continuer")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(Color.noorGold)
                                .cornerRadius(30)
                        }
                        .padding(.top, 20)
                    }
                    Spacer()
                } else if let letter = currentLetter, let mistake = currentMistake {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Maîtrise :")
                                .font(.caption)
                                .foregroundColor(.noorSecondary)
                            
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(index < mistake.correctionCount ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                            
                            if mistake.correctionCount == 1 {
                                Text("• Validation finale")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 30)
                        
                        FreeDrawingStep(
                            letter: letter,
                            formType: currentForm,
                            onComplete: {
                                handleSuccess(for: mistake)
                            },
                            isChallengeMode: false
                        )
                        .id(stepId)
                        
                        Spacer()
                    }
                } else {
                    ProgressView()
                }
            }
            
            if showExitAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation { showExitAlert = false }
                    }
                
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding(.top, 10)
                    
                    VStack(spacing: 8) {
                        Text("Attention")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.noorText)
                        
                        Text("Si vous quittez maintenant, la progression des erreurs en cours (1/2) sera perdue.")
                            .font(.subheadline)
                            .foregroundColor(.noorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation { showExitAlert = false }
                        }) {
                            Text("Continuer")
                                .font(.headline)
                                .foregroundColor(.noorText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.noorSecondary.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            resetPartialProgress()
                            dismiss()
                        }) {
                            Text("Quitter")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
            }
            
            if showFeedback {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: feedbackIcon)
                            .font(.title2)
                        Text(feedbackMessage)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(feedbackColor)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                    .padding(.top, 100)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(300)
            }
        }
        .onAppear {
            loadNextMistake()
        }
        .navigationBarHidden(true)
    }
    
    private func loadNextMistake() {
        guard !dataManager.mistakes.isEmpty else {
            currentMistake = nil
            return
        }
        
        if let randomMistake = dataManager.mistakes.randomElement() {
            currentMistake = randomMistake
            
            if randomMistake.itemType == "letter", let id = Int(randomMistake.itemId) {
                currentLetter = ArabicLetter.letter(byId: id)
                
                if let savedForm = randomMistake.formType, let form = LetterFormType(rawValue: savedForm) {
                    currentForm = form
                } else {
                    currentForm = LetterFormType.allCases.randomElement() ?? .isolated
                }
            }
            
            stepId = UUID()
        }
    }
    
    private func handleSuccess(for mistake: MistakeItem) {
        let isFullyCorrected = dataManager.recordMistakeSuccess(item: mistake)
        
        withAnimation {
            showFeedback = true
            if isFullyCorrected {
                feedbackMessage = "Corrigé ! Plus d'erreur."
                feedbackColor = .green
                feedbackIcon = "checkmark.seal.fill"
            } else {
                feedbackMessage = "Bien ! À confirmer plus tard."
                feedbackColor = .orange
                feedbackIcon = "arrow.triangle.2.circlepath"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showFeedback = false
            }
            loadNextMistake()
        }
    }
}

// MARK: - SPEAKING PRACTICE VIEW
struct SpeakingPracticeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var currentLetter = ArabicLetter.alphabet.randomElement()!
    @State private var isListening = false
    @State private var showSuccess = false
    @State private var showFailure = false
    @State private var feedbackMessage = ""
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
        .sheet(isPresented: $showLibrary) {
            PronunciationLibraryView(onSelect: { letter in
                currentLetter = letter
                showLibrary = false
                resetState()
            })
        }
    }
    
    // MARK: - Header
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
    
    // MARK: - Letter Display
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
                    Capsule()
                        .fill(Color.noorGold.opacity(0.12))
                )
        }
    }
    
    // MARK: - Help Buttons
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
                        Text(LocalizedStringKey("Écouter"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.purple.opacity(0.1))
                    )
                }
                
                Button(action: { 
                    withAnimation(.spring(response: 0.3)) {
                        showTip.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(LocalizedStringKey("Astuce"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.1))
                    )
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
    
    // MARK: - Mascot
    private var mascotView: some View {
        EmotionalMascot(mood: mascotMood, size: 120, showAura: false)
            .scaleEffect(isListening ? 1.08 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isListening)
            .padding(.top, 24)
    }
    
    // MARK: - Feedback
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
    
    // MARK: - Mic Button
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
            
            Text(LocalizedStringKey("Maintiens pour parler"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noorSecondary.opacity(0.8))
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Skip Button
    private var skipButtonView: some View {
        Button(action: {
            withAnimation {
                nextLetter()
            }
        }) {
            HStack(spacing: 6) {
                Text(LocalizedStringKey("Passer"))
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.noorSecondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .stroke(Color.noorSecondary.opacity(0.3), lineWidth: 1.5)
            )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.noorGold.opacity(0.3), .clear]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    EmotionalMascot(mood: .happy, size: 100, showAura: false)
                }
                
                VStack(spacing: 12) {
                    Text(LocalizedStringKey("Excellent !"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(LocalizedStringKey("Tu as bien prononcé la lettre."))
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
            withAnimation {
                showSuccess = false
                nextLetter()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSuccess = false
                    nextLetter()
                }
            }
        }
    }
    
    // MARK: - Actions
    private func startListening() {
        guard speechManager.authorizationStatus == .authorized else {
            feedbackMessage = NSLocalizedString("Autorisation micro requise", comment: "")
            return
        }
        
        isListening = true
        showFailure = false
        mascotMood = .happy
        feedbackMessage = NSLocalizedString("J'écoute...", comment: "")
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        do {
            try speechManager.startRecording()
        } catch {
            print("Error starting recording: \(error)")
            isListening = false
            mascotMood = .sad
        }
    }
    
    private func stopListening() {
        isListening = false
        mascotMood = .thinking
        speechManager.stopRecording()
        
        feedbackMessage = NSLocalizedString("Analyse...", comment: "")
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            validatePronunciation()
        }
    }
    
    private func validatePronunciation() {
        let recognized = speechManager.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let target = currentLetter.isolated
        let transliteration = currentLetter.transliteration.lowercased()
        let name = currentLetter.name.lowercased()
        
        let simplifiedTranslit = transliteration
            .replacingOccurrences(of: "ṣ", with: "s")
            .replacingOccurrences(of: "ḍ", with: "d")
            .replacingOccurrences(of: "ṭ", with: "t")
            .replacingOccurrences(of: "ẓ", with: "z")
            .replacingOccurrences(of: "ḥ", with: "h")
            .replacingOccurrences(of: "ā", with: "a")
            .replacingOccurrences(of: "ī", with: "i")
            .replacingOccurrences(of: "ū", with: "u")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        let isValid: Bool
        
        if recognized.isEmpty {
            isValid = false
            feedbackMessage = NSLocalizedString("Je n'ai rien entendu...", comment: "")
        } else {
            isValid = recognized.contains(target) || 
                      recognized.contains(name) ||
                      recognized.contains(transliteration) ||
                      recognized.contains(simplifiedTranslit) ||
                      transliteration.contains(recognized) ||
                      simplifiedTranslit.contains(recognized)
            
            if !isValid {
                feedbackMessage = "\"" + speechManager.recognizedText + "\" — " + NSLocalizedString("Essaie encore...", comment: "")
            }
        }

        if isValid {
            withAnimation {
                showSuccess = true
            }
            mascotMood = .happy
            feedbackMessage = NSLocalizedString("Bravo !", comment: "")
            HapticManager.shared.trigger(.success)
            failCount = 0
        } else {
            showFailure = true
            mascotMood = .sad
            failCount += 1
            HapticManager.shared.trigger(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if mascotMood == .sad {
                    mascotMood = .neutral
                }
            }
        }
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
    }
}

// MARK: - Pronunciation Library View
struct PronunciationLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let onSelect: (ArabicLetter) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(ArabicLetter.alphabet) { letter in
                            Button(action: { onSelect(letter) }) {
                                HStack(spacing: 16) {
                                    Text(letter.isolated)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.noorGold)
                                        .frame(width: 60)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(letter.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.noorText)
                                        
                                        Text(letter.transliteration)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.noorSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        AudioManager.shared.playLetter(letter.isolated)
                                    }) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.purple)
                                            .padding(10)
                                            .background(Circle().fill(Color.purple.opacity(0.1)))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.noorSecondary.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(LocalizedStringKey("Toutes les lettres"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.noorSecondary.opacity(0.6))
                    }
                }
            }
        }
    }
}




// MARK: - Flashcards Module

struct Flashcard: Identifiable {
    let id = UUID()
    let arabic: String
    let transliteration: String
    let french: String
    let example: String
}

struct FlashcardsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var cards: [Flashcard] = [
        Flashcard(arabic: "كِتَاب", transliteration: "Kitāb", french: "Livre", example: "Al-kitāb kabīr (Le livre est grand)"),
        Flashcard(arabic: "قَلَم", transliteration: "Qalam", french: "Stylo", example: "Hādhā qalam (Ceci est un stylo)"),
        Flashcard(arabic: "بَيْت", transliteration: "Bayt", french: "Maison", example: "Al-bayt jamīl (La maison est belle)"),
        Flashcard(arabic: "مَسْجِد", transliteration: "Masjid", french: "Mosquée", example: "Ana fī al-masjid (Je suis à la mosquée)"),
        Flashcard(arabic: "شَمْس", transliteration: "Shams", french: "Soleil", example: "Ash-shams mushriqa (Le soleil est brillant)"),
        Flashcard(arabic: "قَمَر", transliteration: "Qamar", french: "Lune", example: "Al-qamar munīr (La lune est lumineuse)"),
        Flashcard(arabic: "مَاء", transliteration: "Mā'", french: "Eau", example: "Sharibt al-mā' (J'ai bu de l'eau)"),
        Flashcard(arabic: "خُبْز", transliteration: "Khubz", french: "Pain", example: "Akkalt al-khubz (J'ai mangé du pain)")
    ]
    
    @State private var swipedCards: [Flashcard] = []
    @State private var knownCount = 0
    @State private var learningCount = 0
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    
    private var totalCards: Int { cards.count + swipedCards.count }
    private var progress: Double { totalCards > 0 ? Double(swipedCards.count) / Double(totalCards) : 0 }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        saveProgress()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                                    .shadow(color: .black.opacity(0.08), radius: 8)
                            )
                    }
                    
                    Spacer()
                    
                    // Progress bar
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.noorGold, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress, height: 8)
                                    .animation(.spring(response: 0.4), value: progress)
                            }
                        }
                        .frame(width: 140, height: 8)
                        
                        Text("\(swipedCards.count)/\(totalCards)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.noorSecondary)
                    }
                    
                    Spacer()
                    
                    // Stats badge
                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("\(knownCount)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        HStack(spacing: 3) {
                            Circle().fill(Color.orange).frame(width: 8, height: 8)
                            Text("\(learningCount)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(.noorSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Cards area
                ZStack {
                    if cards.isEmpty {
                        completionView
                    } else {
                        ForEach(cards.reversed()) { card in
                            ModernCardView(
                                card: card,
                                isTop: card.id == cards.last?.id,
                                onSwipeRight: {
                                    knownCount += 1
                                    mascotMood = .happy
                                    HapticManager.shared.trigger(.success)
                                    removeCard(card)
                                },
                                onSwipeLeft: {
                                    learningCount += 1
                                    mascotMood = .thinking
                                    removeCard(card)
                                },
                                onListen: {
                                    audioManager.playLetter(card.arabic)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom actions only (no separate mascot)
                if !cards.isEmpty {
                    HStack(spacing: 50) {
                            // Still learning
                            VStack(spacing: 6) {
                                Button(action: {
                                    if let top = cards.last {
                                        learningCount += 1
                                        mascotMood = .thinking
                                        withAnimation(.spring(response: 0.4)) {
                                            removeCard(top)
                                        }
                                    }
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.orange)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle()
                                                .fill(Color.orange.opacity(0.15))
                                        )
                                }
                                Text(LocalizedStringKey("À revoir"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.noorSecondary)
                            }
                            
                            // Listen
                            VStack(spacing: 6) {
                                Button(action: {
                                    if let top = cards.last {
                                        audioManager.playLetter(top.arabic)
                                        HapticManager.shared.impact(.light)
                                    }
                                }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 64, height: 64)
                                        .background(
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.noorGold, .orange],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .shadow(color: .noorGold.opacity(0.4), radius: 12, y: 6)
                                        )
                                }
                                Text(LocalizedStringKey("Écouter"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.noorSecondary)
                            }
                            
                            // Known
                            VStack(spacing: 6) {
                                Button(action: {
                                    if let top = cards.last {
                                        knownCount += 1
                                        mascotMood = .happy
                                        withAnimation(.spring(response: 0.4)) {
                                            removeCard(top)
                                        }
                                    }
                                }) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.green)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle()
                                                .fill(Color.green.opacity(0.15))
                                        )
                                }
                                Text(LocalizedStringKey("Je connais"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.noorSecondary)
                            }
                        }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            saveProgress()
        }
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(knownCount, forKey: "flashcards_known_count")
        UserDefaults.standard.set(learningCount, forKey: "flashcards_learning_count")
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            EmotionalMascot(mood: .happy, size: 120, showAura: true)
            
            VStack(spacing: 8) {
                Text(LocalizedStringKey("Session terminée !"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(LocalizedStringKey("Tu as révisé \(totalCards) mots"))
                    .font(.subheadline)
                    .foregroundColor(.noorSecondary)
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(knownCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text(LocalizedStringKey("Maîtrisés"))
                        .font(.caption)
                        .foregroundColor(.noorSecondary)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                VStack(spacing: 4) {
                    Text("\(learningCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text(LocalizedStringKey("À revoir"))
                        .font(.caption)
                        .foregroundColor(.noorSecondary)
                }
            }
            .padding(.top, 8)
            
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text(LocalizedStringKey("Retour"))
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 200, height: 52)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.noorGold, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .noorGold.opacity(0.3), radius: 12, y: 6)
                )
            }
            .padding(.top, 12)
        }
    }
    
    private func removeCard(_ card: Flashcard) {
        withAnimation(.spring(response: 0.4)) {
            cards.removeAll { $0.id == card.id }
            swipedCards.append(card)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if mascotMood != .neutral {
                mascotMood = .neutral
            }
        }
    }
}

struct ModernCardView: View {
    let card: Flashcard
    let isTop: Bool
    var onSwipeRight: () -> Void
    var onSwipeLeft: () -> Void
    var onListen: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var isFlipped = false
    @State private var degrees: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    private var swipeProgress: CGFloat { min(abs(offset.width) / 150, 1.0) }
    private var isSwipingRight: Bool { offset.width > 0 }
    
    private var dynamicMascotMood: EmotionalMascot.Mood {
        if swipeProgress > 0.3 {
            return isSwipingRight ? .happy : .neutral
        }
        return .neutral
    }
    
    var body: some View {
        ZStack {
            // Back side
            cardBack
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            // Front side
            cardFront
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 320, height: 420)
        .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
        .offset(x: offset.width, y: offset.height * 0.3)
        .rotationEffect(.degrees(Double(offset.width / 25)))
        .scaleEffect(isTop ? 1.0 : 0.92)
        .opacity(isTop ? 1.0 : 0.0)
        .gesture(
            isTop ? DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        withAnimation(.spring(response: 0.3)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        onSwipeRight()
                    } else if offset.width < -100 {
                        withAnimation(.spring(response: 0.3)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        onSwipeLeft()
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
            : nil
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                degrees += 180
                isFlipped.toggle()
            }
            HapticManager.shared.impact(.light)
        }
    }
    
    private var cardFront: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 28)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 15)
            
            // Swipe indicator overlay
            if isTop && swipeProgress > 0.1 {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSwipingRight ? Color.green : Color.orange, lineWidth: 4)
                    .opacity(Double(swipeProgress))
            }
            
            // Content
            VStack(spacing: 0) {
                // Mascot at top
                EmotionalMascot(mood: dynamicMascotMood, size: 55, showAura: false)
                    .animation(.spring(response: 0.3), value: dynamicMascotMood)
                    .padding(.top, 24)
                
                Spacer()
                
                Text(card.arabic)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.noorText)
                
                Text(card.transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .padding(.top, 8)
                
                Spacer()
                
                // Hint
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 12))
                    Text(LocalizedStringKey("Appuyer pour révéler"))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.6))
                .padding(.bottom, 24)
            }
            
            // Swipe labels
            if isTop && swipeProgress > 0.2 {
                VStack {
                    HStack {
                        if !isSwipingRight {
                            swipeLabel(text: "À revoir", color: .orange, icon: "arrow.counterclockwise")
                                .opacity(Double(swipeProgress))
                        }
                        Spacer()
                        if isSwipingRight {
                            swipeLabel(text: "Je connais", color: .green, icon: "checkmark")
                                .opacity(Double(swipeProgress))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    Spacer()
                }
            }
        }
    }
    
    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.noorGold.opacity(0.15), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 15)
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.noorGold.opacity(0.3), lineWidth: 2)
            
            VStack(spacing: 16) {
                // Mascot at top
                EmotionalMascot(mood: dynamicMascotMood, size: 55, showAura: false)
                    .animation(.spring(response: 0.3), value: dynamicMascotMood)
                    .padding(.top, 24)
                
                Spacer()
                
                Text(card.french)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Divider()
                    .frame(width: 60)
                    .padding(.vertical, 8)
                
                Text(card.example)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 12))
                    Text(LocalizedStringKey("Appuyer pour retourner"))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.6))
                .padding(.bottom, 24)
            }
        }
    }
    
    private func swipeLabel(text: LocalizedStringKey, color: Color, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

