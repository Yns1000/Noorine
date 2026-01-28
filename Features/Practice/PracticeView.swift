import SwiftUI

struct PracticeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. EN-TÊTE
                        PracticeHeader()
                            .padding(.top, 10)
                        
                        // 2. LE DÉFI DU JOUR (HERO CARD)
                        DailyChallengeCard()
                        
                        // 3. GRILLE D'OUTILS (BENTO)
                        PracticeToolsGrid()
                        
                        // 4. MOTS À REVOIR (LISTE)
                        WordsReviewList()
                        
                        Spacer().frame(height: 120) // Espace TabBar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// --- 1. HEADER ---
struct PracticeHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("RÉVISIONS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .tracking(2)
                
                Text("Centre d'entraînement")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
            }
            Spacer()
        }
    }
}

// --- 2. DÉFI DU JOUR (HERO) ---
struct DailyChallengeCard: View {
    var body: some View {
        ZStack {
            // Fond dégradé
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
                        Text("DÉFI QUOTIDIEN")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    
                    Text("Renforce ta mémoire")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {}) {
                        Text("LANCER (+20 XP)")
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
                
                // La Mascotte qui dépasse un peu
                NoorineMascot()
                    .frame(width: 100, height: 100)
                    .offset(x: -10, y: 10)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
        .frame(height: 160)
    }
}

// --- 3. GRILLE D'OUTILS ---
struct PracticeToolsGrid: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ToolCard(icon: "rectangle.on.rectangle.angled", color: .blue, title: "Flashcards", subtitle: "40 mots")
            ToolCard(icon: "waveform", color: .purple, title: "Écoute", subtitle: "Audio pur")
            ToolCard(icon: "heart.slash.fill", color: .red, title: "Erreurs", subtitle: "12 à corriger")
            ToolCard(icon: "mic.fill", color: .green, title: "Parler", subtitle: "Prononciation")
        }
    }
}

struct ToolCard: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                // Icône dans son container
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
}

// --- 4. LISTE MOTS À REVOIR ---
struct WordsReviewList: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("À revoir bientôt")
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
    let strength: Double // 0.0 à 1.0 (Force de la mémoire)
    
    var body: some View {
        HStack(spacing: 15) {
            // Indicateur de force (Cercle de progression)
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
