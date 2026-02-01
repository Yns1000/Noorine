import SwiftUI

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