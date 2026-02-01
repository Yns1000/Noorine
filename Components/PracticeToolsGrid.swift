import SwiftUI

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
    let subtitle: LocalizedStringKey // String interpolée convertie
    var action: (() -> Void)? = nil
    
    // Initialiseur personnalisé pour gérer String vs LocalizedStringKey si besoin
    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
        self.subtitle = LocalizedStringKey(subtitle)
        self.action = action
    }
    
    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey, action: (() -> Void)? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
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