import SwiftUI

struct AlphabetAudioView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var currentFact: String = ""
    
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
                        
                        TipBanner(factKey: currentFact, onTap: {
                            HapticManager.shared.impact(.light)
                            withAnimation(.spring()) {
                                loadNewFact()
                            }
                        })
                        
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
        .onAppear {
            if currentFact.isEmpty {
                loadNewFact()
            }
        }
    }
    
    private func loadNewFact() {
        currentFact = FactsData.shared.getRandomFact(for: languageManager.currentLanguage)
    }
}
