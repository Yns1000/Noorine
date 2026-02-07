import SwiftUI

struct ListeningModuleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    
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
                        
                        Text(languageManager.currentLanguage == .english ? "Listening" : "Écoute")
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
                        Text(languageManager.currentLanguage == .english ? "Focused practice" : "Pratique ciblée")
                            .font(.headline)
                            .foregroundColor(.noorSecondary)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: ListeningPracticeView(mode: .word)) {
                                ListeningModuleCard(
                                    icon: "message.fill",
                                    title: languageManager.currentLanguage == .english ? "Common words" : "Mots courants",
                                    subtitle: languageManager.currentLanguage == .english ? "Audio quiz" : "Quiz audio",
                                    colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6)]
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: ListeningPracticeView(mode: .phrase)) {
                                ListeningModuleCard(
                                    icon: "quote.bubble.fill",
                                    title: languageManager.currentLanguage == .english ? "Phrases" : "Phrases",
                                    subtitle: languageManager.currentLanguage == .english ? "Guided listening" : "Écoute guidée",
                                    colors: [Color.green.opacity(0.9), Color.green.opacity(0.6)]
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
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
