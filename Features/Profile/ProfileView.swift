import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showLanguageSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        ModernProfileHeader()
                            .padding(.top, 10)
                        
                        StatsBentoGrid()
                        
                        ActivityCard()
                        
                        VStack(spacing: 16) {
                            MenuSection(title: "Général") {
                                MenuRow(icon: "crown.fill", color: .noorGold, title: "Noorine Plus", subtitle: "Gérer l'abonnement")
                                Divider().padding(.leading, 56)
                                
                                Button(action: { showLanguageSheet = true }) {
                                    MenuRowContent(
                                        icon: "globe",
                                        color: .blue,
                                        title: "Langue",
                                        subtitle: LocalizedStringKey(languageManager.currentLanguage.courseLabel)
                                    )
                                }
                            }
                            
                            MenuSection(title: "Préférences") {
                                MenuRow(icon: "bell.fill", color: .purple, title: "Notifications", subtitle: "Rappels quotidiens")
                                Divider().padding(.leading, 56)
                                MenuRow(icon: "speaker.wave.2.fill", color: .pink, title: "Sons & Haptique", subtitle: "Activé")
                            }
                            
                            MenuSection(title: "Support") {
                                MenuRow(icon: "questionmark", color: .gray, title: "Aide", subtitle: "FAQ et contact")
                            }
                        }
                        
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionView()
                    .presentationDetents([.height(300)])
                    .presentationCornerRadius(30)
            }
        }
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Choisir la langue")
                    .font(.headline)
                    .foregroundColor(.noorText)
                    .padding(.top, 25)
                
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button(action: {
                            languageManager.setLanguage(lang)
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(lang.displayName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.noorText)
                                    Text(lang.courseLabel)
                                        .font(.caption)
                                        .foregroundColor(.noorSecondary)
                                }
                                
                                Spacer()
                                
                                if languageManager.currentLanguage == lang {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.noorGold)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.noorSecondary.opacity(0.3))
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(languageManager.currentLanguage == lang ? Color.noorGold : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct ModernProfileHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .strokeBorder(Color.noorGold.opacity(0.3), lineWidth: 2)
                    .frame(width: 90, height: 90)
                
                NoorineMascot()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(color: .noorGold.opacity(0.2), radius: 10)
                
                Circle()
                    .fill(Color.noorGold)
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "pencil").font(.caption).bold().foregroundColor(.white))
                    .offset(x: 30, y: 30)
                    .shadow(color: .black.opacity(0.2), radius: 3)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Laurine")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
                
                Text("Niveau 3 • Érudit")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.noorSecondary)
                
                HStack(spacing: 8) {
                    ProgressView(value: 0.7)
                        .tint(.noorGold)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(height: 6)
                        .clipShape(Capsule())
                        .background(Color.noorSecondary.opacity(0.2).clipShape(Capsule()))
                    
                    Text("70%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.noorGold)
                }
                .padding(.top, 4)
            }
            Spacer()
        }
    }
}

struct StatsBentoGrid: View {
    var body: some View {
        HStack(spacing: 12) {
            StatCardModern(icon: "flame.fill", iconColor: .orange, value: "3", label: "Jours", subLabel: "Série en cours")
            StatCardModern(icon: "star.fill", iconColor: .noorGold, value: "1,420", label: "XP", subLabel: "Total gagné")
            StatCardModern(icon: "trophy.fill", iconColor: .yellow, value: "#1", label: "Or", subLabel: "Ligue actuelle")
        }
    }
}

struct StatCardModern: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let iconColor: Color
    let value: String
    let label: LocalizedStringKey
    let subLabel: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.noorSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

struct ActivityCard: View {
    @Environment(\.colorScheme) var colorScheme
    let days = ["L", "M", "M", "J", "V", "S", "D"]
    let data = [0.2, 0.5, 0.8, 0.3, 0.0, 0.9, 0.4]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Activité")
                    .font(.headline)
                    .foregroundColor(.noorText)
                Spacer()
                Text("Cette semaine")
                    .font(.caption)
                    .foregroundColor(.noorSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.noorBackground)
                    .cornerRadius(10)
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Color.noorSecondary.opacity(0.15))
                                .frame(width: 8, height: 100)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.noorGold, .orange]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 8, height: 100 * data[index])
                        }
                        Text(days[index])
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(index == 5 ? .noorText : .noorSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

struct MenuSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: LocalizedStringKey
    let content: Content
    
    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.noorSecondary)
                .tracking(1)
                .textCase(.uppercase)
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                content
            }
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        }
    }
}

struct MenuRowContent: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorText)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.noorSecondary.opacity(0.4))
        }
        .padding(16)
    }
}

struct MenuRow: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    
    var body: some View {
        Button(action: {}) {
            MenuRowContent(icon: icon, color: color, title: title, subtitle: subtitle)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LanguageManager())
}
