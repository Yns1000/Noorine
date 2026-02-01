import SwiftUI

struct FlashcardsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject private var manager = FlashcardManager.shared
    
    @State private var cards: [Flashcard] = []
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    @State private var showLibrary = false
    
    private var knownCount: Int { manager.knownCardIds.count }
    private var learningCount: Int { manager.reviewCardIds.count }
    private var totalCards: Int { manager.getAllCards().count }
    private var globalProgress: Double {
        totalCards > 0 ? Double(knownCount) / Double(totalCards) : 0
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
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
                    
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.2))
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.noorGold, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * globalProgress, height: 8)
                                    .animation(.spring(response: 0.4), value: globalProgress)
                            }
                        }
                        .frame(width: 140, height: 8)
                        
                        Text("\(knownCount)/\(totalCards) ")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.noorSecondary)
                        + Text(LocalizedStringKey("Maîtrisés"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.noorSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showLibrary = true }) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorSecondary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                                    .shadow(color: .black.opacity(0.08), radius: 8)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                ZStack {
                    if cards.isEmpty && knownCount == totalCards {
                        completionView
                    } else if cards.isEmpty {
                         Text("Chargement...")
                             .foregroundColor(.noorSecondary)
                    } else {
                        ForEach(cards.reversed()) { card in
                            ModernCardView(
                                card: card,
                                isTop: card.id == cards.last?.id,
                                onSwipeRight: {
                                    mascotMood = .happy
                                    HapticManager.shared.trigger(.success)
                                    manager.markAsKnown(card)
                                    removeCard(card)
                                },
                                onSwipeLeft: {
                                    mascotMood = .thinking
                                    manager.markAsReview(card)
                                    requeueCard(card)
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
                
                if !cards.isEmpty {
                    HStack(spacing: 50) {
                        VStack(spacing: 6) {
                            Button(action: {
                                if let top = cards.last {
                                    mascotMood = .thinking
                                    manager.markAsReview(top)
                                    withAnimation(.spring(response: 0.4)) {
                                        requeueCard(top)
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.orange)
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(Color.orange.opacity(0.15)))
                            }
                            Text(LocalizedStringKey("À revoir"))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.noorSecondary)
                        }
                        
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
                        
                        VStack(spacing: 6) {
                            Button(action: {
                                if let top = cards.last {
                                    mascotMood = .happy
                                    HapticManager.shared.trigger(.success)
                                    manager.markAsKnown(top)
                                    withAnimation(.spring(response: 0.4)) {
                                        removeCard(top)
                                    }
                                }
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.green)
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(Color.green.opacity(0.15)))
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
        .onAppear {
            loadCards()
        }
        .sheet(isPresented: $showLibrary) {
            FlashcardLibraryView()
        }
    }
    
    private func loadCards() {
        cards = manager.getPracticeCards()
    }
    
    private func removeCard(_ card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards.remove(at: index)
        }
    }
    
    private func requeueCard(_ card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            withAnimation(.spring(response: 0.4)) {
                cards.remove(at: index)
                cards.insert(card, at: 0)
            }
        }
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
}