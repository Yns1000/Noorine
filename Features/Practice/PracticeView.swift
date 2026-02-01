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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            NavigationLink(destination: FlashcardsView()) {
                ToolCard(icon: "rectangle.on.rectangle.angled", color: .blue, title: "Flashcards", subtitle: "40 mots")
            }
            .buttonStyle(PlainButtonStyle())
            
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

            NavigationLink(destination: SpeakingPracticeView()) {
                ToolCard(icon: "mic.fill", color: .green, title: "Parler", subtitle: "Prononciation")
            }
            .buttonStyle(PlainButtonStyle())
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
                        .padding(.bottom, 10)
                        
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
    @State private var feedbackMessage = ""
    
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    @State private var pulsePhase = 0.0
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                    
                    Text("L'Écho de Noorine")
                        .font(.headline)
                        .foregroundColor(.noorGold)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                VStack(spacing: 32) {
                    
                    VStack(spacing: 12) {
                        Text(currentLetter.isolated)
                            .font(.system(size: 110, weight: .black, design: .rounded))
                            .foregroundColor(.noorText)
                            .shadow(color: .noorGold.opacity(0.15), radius: 20)
                            
                        Text(currentLetter.transliteration)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.noorSecondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.noorGold.opacity(0.1))
                            )
                    }
                    
                    ZStack {
                        EmotionalMascot(mood: mascotMood, size: 140, showAura: false)
                            .scaleEffect(isListening ? 1.08 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isListening)
                    }
                    
                    if !feedbackMessage.isEmpty {
                        HStack(spacing: 8) {
                            if isListening {
                                HStack(spacing: 4) {
                                    ForEach(0..<4, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.noorGold)
                                            .frame(width: 4, height: 8 + CGFloat(speechManager.audioLevel * 16))
                                            .animation(
                                                .easeInOut(duration: 0.15)
                                                    .repeatForever(autoreverses: true)
                                                    .delay(Double(i) * 0.05),
                                                value: speechManager.audioLevel
                                            )
                                    }
                                }
                            }
                            
                            Text(feedbackMessage)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(showSuccess ? .green : (isListening ? .noorGold : .noorSecondary))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
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
                .padding(.bottom, 50)
            }
            
            if showSuccess {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Text("🌟")
                            .font(.system(size: 70))
                            .scaleEffect(1.2)
                            .rotationEffect(.degrees(10))
                        
                        Text("Excellent !")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Tu as bien prononcé la lettre.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(radius: 50)
                    )
                    .padding(.horizontal, 40)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(100)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation {
                            showSuccess = false
                            nextLetter()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            speechManager.requestAuthorization()
        }
    }
    
    private func startListening() {
        guard speechManager.authorizationStatus == .authorized else {
            feedbackMessage = "Autorisation micro requise"
            return
        }
        
        isListening = true
        mascotMood = .happy
        feedbackMessage = "J'écoute..."
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
        
        feedbackMessage = "Analyse..."
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            validatePronunciation()
        }
    }
    
    private func validatePronunciation() {
        let recognized = speechManager.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = currentLetter.isolated
        
        print("Recognized: '\(recognized)' vs Target: '\(target)'") 
        
        let isValid: Bool
        
        if recognized.isEmpty {
             isValid = false
             feedbackMessage = "Je n'ai rien entendu..."
        } else {
             isValid = recognized.contains(target) || recognized.contains(currentLetter.name)
        }

        if isValid {
            withAnimation {
                showSuccess = true
            }
            mascotMood = .happy
            feedbackMessage = "Bravo !"
            HapticManager.shared.trigger(.success)
        } else {
            mascotMood = .sad
            feedbackMessage = "Essaie encore..."
            HapticManager.shared.trigger(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if mascotMood == .sad {
                    withAnimation { mascotMood = .neutral }
                }
            }
        }
    }
    
    private func nextLetter() {
        currentLetter = ArabicLetter.alphabet.randomElement()!
        feedbackMessage = ""
        mascotMood = .neutral
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
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            )
                    }
                    Spacer()
                    
                    Text("Flashcards")
                        .font(.headline)
                        .foregroundColor(.noorText)
                    
                    Text("\(cards.count)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.noorGold.opacity(0.2)))
                        .foregroundColor(.noorGold)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                ZStack {
                    if cards.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Session terminée !")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.noorText)
                            
                            Button(action: { dismiss() }) {
                                Text("Retour")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.noorGold)
                                    .cornerRadius(25)
                            }
                        }
                    } else {
                        ForEach(cards.reversed()) { card in
                            DraggableCardView(card: card, onRemove: { removeCard(card) })
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                if !cards.isEmpty {
                    HStack(spacing: 40) {
                        Button(action: {
                            if let last = cards.last {
                                withAnimation {
                                    removeCard(last)
                                }
                            }
                        }) {
                            Image(systemName: "arrow.uturn.left")
                                .font(.title2)
                                .foregroundColor(.noorSecondary)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color(UIColor.secondarySystemGroupedBackground)))
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            if let last = cards.last {
                                audioManager.playLetter(last.arabic)
                            }
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(Color.noorGold))
                                .shadow(color: .noorGold.opacity(0.4), radius: 10, y: 5)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func removeCard(_ card: Flashcard) {
        withAnimation {
            cards.removeAll { $0.id == card.id }
            swipedCards.append(card)
        }
    }
}

struct DraggableCardView: View {
    let card: Flashcard
    var onRemove: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var isFlipped = false
    @State private var degrees: Double = 0
    
    var body: some View {
        ZStack {
            CardContent(title: card.french, subtitle: card.example, isFront: false)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            CardContent(title: card.arabic, subtitle: card.transliteration, isFront: true)
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 320, height: 480)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        onRemove()
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                degrees += 180
                isFlipped.toggle()
            }
        }
    }
}

struct CardContent: View {
    let title: String
    let subtitle: String
    let isFront: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(title)
                .font(.system(size: isFront ? 60 : 32, weight: .bold, design: .rounded))
                .foregroundColor(.noorText)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.title3)
                .foregroundColor(isFront ? .noorSecondary : .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !isFront {
                Divider()
                    .frame(width: 50)
                Text("Appuyer pour retourner")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.noorGold.opacity(isFront ? 0.3 : 0.0), lineWidth: 2)
        )
    }
}
