import SwiftUI

struct FlashcardLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let cards = FlashcardManager.shared.allCards
    var onCardSelected: ((Flashcard) -> Void)? = nil
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cards) { card in
                            LibraryCardView(card: card)
                                .onTapGesture {
                                    HapticManager.shared.impact(.light)
                                    if let callback = onCardSelected {
                                        callback(card)
                                    }
                                    dismiss()
                                }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Bibliothèque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LibraryCardView: View {
    let card: Flashcard
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var audioManager = AudioManager.shared
    
    var isMature: Bool {
        FlashcardManager.shared.getInterval(for: card) >= 21
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                if isMature {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(LocalizedStringKey("Maîtrisés"))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            Text(card.arabic)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.noorText)
                .frame(height: 60)
            
            Text(card.transliteration)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            Divider()
            
            Text(languageManager.currentLanguage == .english ? card.english : card.french)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.noorText)
            
            Button(action: {
                audioManager.playLetter(card.arabic)
                HapticManager.shared.impact(.light)
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.noorGold)
                    .padding(8)
                    .background(Color.noorGold.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isMature ? Color.green.opacity(0.05) : (colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isMature ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}
