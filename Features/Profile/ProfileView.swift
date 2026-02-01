import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showLanguageSheet = false
    @State private var showStreakSheet = false
    @State private var showXPSheet = false
    @State private var showLeagueSheet = false
    @State private var showFAQSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        ModernProfileHeader()
                            .padding(.top, 10)
                        
                        StatsBentoGrid(
                            onStreakTap: { showStreakSheet = true },
                            onXPTap: { showXPSheet = true },
                            onLeagueTap: { showLeagueSheet = true }
                        )
                        
                        ActivityCard()
                        
                        VStack(spacing: 16) {
                            MenuSection(title: "Général") {
                                MenuToggleRow(
                                    icon: "bell.fill",
                                    color: .orange,
                                    title: "Notifications",
                                    isOn: Binding(
                                        get: { dataManager.userProgress?.notificationsEnabled ?? true },
                                        set: { newValue in
                                            dataManager.userProgress?.notificationsEnabled = newValue
                                        }
                                    )
                                )
                                
                                Divider().padding(.leading, 56)
                                
                                MenuRow(
                                    icon: "globe",
                                    color: .blue,
                                    title: "Langue de l'interface",
                                    subtitle: LocalizedStringKey(languageManager.currentLanguage.displayName),
                                    action: { showLanguageSheet = true }
                                )
                                
                                Divider().padding(.leading, 56)
                                
                                MenuRow(icon: "crown.fill", color: .noorGold, title: "Noorine Plus", subtitle: "Gérer l'abonnement")
                            }
                            
                            MenuSection(title: "Préférences") {
                                MenuToggleRow(
                                    icon: "speaker.wave.2.fill",
                                    color: .pink,
                                    title: "Sons",
                                    isOn: Binding(
                                        get: { dataManager.userProgress?.soundEnabled ?? true },
                                        set: { dataManager.userProgress?.soundEnabled = $0 }
                                    )
                                )
                                
                                Divider().padding(.leading, 56)
                                
                                MenuToggleRow(
                                    icon: "iphone.radiowaves.left.and.right",
                                    color: .purple,
                                    title: "Vibrations",
                                    isOn: Binding(
                                        get: { dataManager.userProgress?.hapticsEnabled ?? true },
                                        set: { dataManager.userProgress?.hapticsEnabled = $0 }
                                    )
                                )
                            }
                            
                            MenuSection(title: LocalizedStringKey("Aide & Support")) {
                                MenuRow(
                                    icon: "questionmark.circle.fill",
                                    color: .blue,
                                    title: LocalizedStringKey("Foire aux questions"),
                                    subtitle: LocalizedStringKey("Tout savoir sur Noorine")
                                ) {
                                    showFAQSheet = true
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                MenuRow(
                                    icon: "envelope.fill",
                                    color: .green,
                                    title: LocalizedStringKey("Contactez-nous"),
                                    subtitle: LocalizedStringKey("Signaler un problème")
                                ) {
                                    openMail()
                                }
                            }

                            MenuSection(title: "Développement") {
                                VStack(spacing: 0) {
                                    DevActionRow(
                                        title: "Réinitialiser le nom",
                                        subtitle: "Remettre 'Apprenti'",
                                        icon: "person.text.rectangle",
                                        color: .blue,
                                        action: { dataManager.devResetName() }
                                    )
                                    
                                    Divider().padding(.leading, 56)
                                    
                                    DevActionRow(
                                        title: "Réinitialiser Défi Quotidien",
                                        subtitle: "Le revoir aujourd'hui",
                                        icon: "calendar.badge.minus",
                                        color: .orange,
                                        action: { dataManager.devResetDailyChallenge() }
                                    )
                                    
                                    Divider().padding(.leading, 56)
                                    
                                    DevActionRow(
                                        title: "Tout réinitialiser",
                                        subtitle: "XP, Progression, Niveaux",
                                        icon: "trash.fill",
                                        color: .red,
                                        action: { dataManager.devResetAllProgress() }
                                    )
                                }
                            }
                            
                            MenuSection(title: "Partage & Export") {
                                VStack(spacing: 0) {
                                    ShareLink(item: renderMascotIcon(style: .light), preview: SharePreview("Icône Noorine (Claire)", image: renderMascotIcon(style: .light))) {
                                        ExportRow(title: "Export Icône Claire", subtitle: "Fond Crème (Standard)", icon: "sun.max.fill", color: .orange)
                                    }
                                    Divider().padding(.leading, 56)
                                    ShareLink(item: renderMascotIcon(style: .dark), preview: SharePreview("Icône Noorine (Sombre)", image: renderMascotIcon(style: .dark))) {
                                        ExportRow(title: "Export Icône Sombre", subtitle: "Fond Noir (Glow)", icon: "moon.stars.fill", color: .indigo)
                                    }
                                    Divider().padding(.leading, 56)
                                    ShareLink(item: renderMascotIcon(style: .tinted), preview: SharePreview("Icône Noorine (Teintée)", image: renderMascotIcon(style: .tinted))) {
                                        ExportRow(title: "Export Icône Teintée", subtitle: "Gabarit iOS (Grayscale)", icon: "paintpalette.fill", color: .purple)
                                    }
                                }
                            }

                            VStack(spacing: 6) {
                                Text(LocalizedStringKey("Développé par Sny avec ❤️ pour Lau"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.noorSecondary)
                                Text(LocalizedStringKey("et tous ceux qui veulent apprendre l'arabe."))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.noorSecondary.opacity(0.8))
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
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
            .sheet(isPresented: $showStreakSheet) {
                StreakDetailView()
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showXPSheet) {
                XPDetailView()
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showLeagueSheet) {
                LeagueDetailView()
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showFAQSheet) {
                FAQView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(30)
            }
        }
    }

    private func openMail() {
        let email = "younes.bgrt@icloud.com"
        if let url = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    @MainActor
    private func renderMascotIcon(style: IconStyle) -> Image {
        let renderer = ImageRenderer(content: MascotExportView(style: style))
        renderer.scale = 1.0
        
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
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
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            MenuRowContent(icon: icon, color: color, title: title, subtitle: subtitle)
        }
    }
}

struct MenuToggleRow: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    @Binding var isOn: Bool
    var onChanged: (Bool) -> Void = { _ in }
    
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
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.noorText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.noorGold)
                .onChange(of: isOn) { _, newValue in
                    onChanged(newValue)
                }
        }
        .padding(16)
    }
}


struct ExportRow: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.noorText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.noorSecondary)
            }
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14))
                .foregroundColor(.noorSecondary.opacity(0.5))
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

struct DevActionRow: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    let color: Color
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.noorText)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.noorSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.noorSecondary.opacity(0.3))
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
                Text(LocalizedStringKey("Choisir la langue"))
                    .font(.headline)
                    .foregroundColor(.noorText)
                    .padding(.top, 25)
                
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button(action: {
                            languageManager.currentLanguage = lang
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
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .strokeBorder(Color.noorGold.opacity(0.3), lineWidth: 2)
                    .frame(width: 90, height: 90)
                
                EmotionalMascot(mood: .happy, size: 60, showAura: false)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(color: .noorGold.opacity(0.2), radius: 10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataManager.userProgress?.name ?? "Apprenti")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
                
                Text(levelTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.noorSecondary)
                
                HStack(spacing: 8) {
                    ProgressView(value: levelProgress)
                        .tint(.noorGold)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(height: 6)
                        .clipShape(Capsule())
                        .background(Color.noorSecondary.opacity(0.2).clipShape(Capsule()))
                    
                    Text("\(Int(levelProgress * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.noorGold)
                }
                .padding(.top, 4)
            }
            Spacer()
        }
    }
    
    var levelTitle: LocalizedStringKey {
        guard let progress = dataManager.userProgress else { return "Niveau 1" }
        let level = (progress.xpTotal / 500) + 1
        return "Niveau \(level) • Érudit"
    }
    
    var levelProgress: Double {
        guard let progress = dataManager.userProgress else { return 0 }
        let currentLevelXP = Double(progress.xpTotal % 500)
        return currentLevelXP / 500.0
    }
}

struct StatsBentoGrid: View {
    @EnvironmentObject var dataManager: DataManager
    var onStreakTap: () -> Void = {}
    var onXPTap: () -> Void = {}
    var onLeagueTap: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 12) {
            if let progress = dataManager.userProgress {
                StatCardModern(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: LocalizedStringKey("\(progress.streakDays)"),
                    label: "Jours",
                    subLabel: "Série en cours",
                    action: onStreakTap
                )
                
                StatCardModern(
                    icon: "star.fill",
                    iconColor: .noorGold,
                    value: LocalizedStringKey(formatNumber(progress.xpTotal)),
                    label: "XP",
                    subLabel: "Total gagné",
                    action: onXPTap
                )
                
                StatCardModern(
                    icon: "trophy.fill",
                    iconColor: .yellow,
                    value: LocalizedStringKey(leagueName(for: progress.currentWeekXP())),
                    label: "Ligue",
                    subLabel: "Actuelle",
                    action: onLeagueTap
                )
            }
        }
    }
    
    private func leagueName(for xp: Int) -> String {
        if xp < 50 { return "Bronze" }
        if xp < 150 { return "Argent" }
        if xp < 300 { return "Or" }
        if xp < 600 { return "Platine" }
        if xp < 1000 { return "Émeraude" }
        return "Diamant"
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct StatCardModern: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let iconColor: Color
    let value: LocalizedStringKey
    let label: LocalizedStringKey
    let subLabel: LocalizedStringKey
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 24))
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityCard: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    
    private var days: [String] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: languageManager.currentLanguage.rawValue)
        let symbols = calendar.veryShortWeekdaySymbols
        return [
            symbols[1], symbols[2], symbols[3], symbols[4], symbols[5], symbols[6], symbols[0]
        ]
    }
    
    var activityData: [Double] {
        var heights = Array(repeating: 0.0, count: 7)
        guard let progress = dataManager.userProgress else { return heights }
        
        let calendar = Calendar.current
        let today = Date()
        guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return heights }
        
        let dailyGoal = 50.0
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monday) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let key = formatter.string(from: date)
                let xp = Double(progress.dailyXP[key] ?? 0)
                heights[dayOffset] = min(xp / dailyGoal, 1.0)
            }
        }
        return heights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(LocalizedStringKey("Activité"))
                    .font(.headline)
                    .foregroundColor(.noorText)
                Spacer()
                Text(LocalizedStringKey("Cette semaine"))
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
                                .frame(width: 8, height: 100 * activityData[index])
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activityData[index])
                        }
                        Text(days[index])
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(activityData[index] > 0.5 ? .noorText : .noorSecondary.opacity(0.7))
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

struct StreakDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.3), radius: 15)
                            .padding(.top, 40)
                        
                        VStack(spacing: 8) {
                            Text(LocalizedStringKey("\(dataManager.userProgress?.streakDays ?? 0) Jours de série"))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            
                            Text(LocalizedStringKey("Ton assiduité est la clé de ta réussite !"))
                                .font(.subheadline)
                                .foregroundColor(.noorSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    VStack(spacing: 40) {
                        ForEach(monthsToDisplay, id: \.self) { monthDate in
                            MonthCalendarView(monthDate: monthDate)
                        }
                    }
                    .padding(.bottom, 120)
                }
                .padding(.horizontal)
            }
            
            VStack {
                Spacer()
                Button(LocalizedStringKey("Continuer")) { dismiss() }
                    .buttonStyle(NoorPrimaryButtonStyle())
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(colors: [.noorBackground.opacity(0), .noorBackground], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                    )
            }
        }
        .background(Color.noorBackground.ignoresSafeArea())
    }
    
    private var monthsToDisplay: [Date] {
        let calendar = Calendar.current
        let start = calendar.startOfMonth(for: dataManager.userProgress?.installationDate ?? Date())
        let end = calendar.startOfMonth(for: Date())
        
        var months: [Date] = []
        var current = end
        
        while current >= start {
            months.append(current)
            guard let next = calendar.date(byAdding: .month, value: -1, to: current) else { break }
            current = next
            if months.count > 12 { break }
        }
        
        return months
    }
}

struct MonthCalendarView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    let monthDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(monthName)
                .font(.headline)
                .foregroundColor(.noorText)
                .padding(.leading, 5)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(getWeekdays(), id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.noorSecondary.opacity(0.5))
                }
                
                ForEach(0..<paddingDays, id: \.self) { _ in
                    Color.clear.frame(height: 34)
                }
                
                ForEach(daysInMonth, id: \.self) { day in
                    DayCircleView(date: date(for: day))
                }
            }
            .padding(20)
            .background(Color.noorSecondary.opacity(0.04))
            .cornerRadius(24)
        }
    }
    
    private var monthName: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        df.locale = Locale(identifier: languageManager.currentLanguage.rawValue)
        return df.string(from: monthDate).capitalized
    }
    
    private var daysInMonth: [Int] {
        let range = Calendar.current.range(of: .day, in: .month, for: monthDate)!
        return Array(range)
    }
    
    private var paddingDays: Int {
        let calendar = Calendar.current
        var firstDay = calendar.component(.weekday, from: monthDate)
        firstDay = (firstDay + 5) % 7
        return firstDay
    }
    
    private func date(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day - 1, to: monthDate)!
    }
    
    private func getWeekdays() -> [String] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: languageManager.currentLanguage.rawValue)
        let symbols = calendar.veryShortWeekdaySymbols
        return [
            symbols[1], symbols[2], symbols[3], symbols[4], symbols[5], symbols[6], symbols[0]
        ]
    }
}

struct DayCircleView: View {
    @EnvironmentObject var dataManager: DataManager
    let date: Date
    
    var body: some View {
        let dateString = formatDate(date)
        let isActive = dataManager.userProgress?.dailyXP[dateString] != nil
        let isToday = Calendar.current.isDateInToday(date)
        let isFuture = date > Date()
        
        Circle()
            .fill(isActive ? Color.orange : Color.noorSecondary.opacity(0.08))
            .frame(width: 32, height: 32)
            .overlay(
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isActive ? .white : (isFuture ? .noorSecondary.opacity(0.2) : .noorSecondary.opacity(0.6)))
            )
            .overlay(
                Circle()
                    .stroke(Color.noorGold, lineWidth: isToday ? 2 : 0)
                    .scaleEffect(1.2)
            )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}

struct XPDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.noorGold.opacity(0.1))
                                .frame(width: 160, height: 160)
                            
                            Circle()
                                .fill(Color.noorGold.opacity(0.2))
                                .frame(width: 130, height: 130)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.noorGold)
                                .shadow(color: .noorGold.opacity(0.4), radius: 10)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 8) {
                            Text("\(dataManager.userProgress?.xpTotal ?? 0)")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(.noorText)
                            
                            Text(LocalizedStringKey("POINTS D'EXPÉRIENCE TOTAL"))
                                .font(.caption)
                                .fontWeight(.bold)
                                .tracking(2)
                                .foregroundColor(.noorSecondary)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Cette semaine")
                                .font(.subheadline)
                                .foregroundColor(.noorSecondary)
                            Text("+\(dataManager.userProgress?.currentWeekXP() ?? 0) XP")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 5) {
                            Text(LocalizedStringKey("Membre depuis"))
                                .font(.subheadline)
                                .foregroundColor(.noorSecondary)
                            Text(formattedInstallationDate)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(25)
                    .background(Color.noorGold.opacity(0.05))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStringKey("Tes Succès"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(UserProgress.AchievementID.allCases, id: \.self) { id in
                                    let info = achievementInfo(for: id)
                                    let isUnlocked = dataManager.userProgress?.achievements.contains(id.rawValue) ?? false
                                    MilestoneCard(title: info.title, subtitle: info.subtitle, icon: info.icon, color: info.color, isUnlocked: isUnlocked)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dernières activités")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            let last7Days = (0..<7).compactMap { i in
                                Calendar.current.date(byAdding: .day, value: -i, to: Date())
                            }
                            
                            let activeDays = last7Days.filter { (dataManager.userProgress?.dailyXP[formatDate($0)] ?? 0) > 0 }
                            
                            if activeDays.isEmpty {
                                Text(LocalizedStringKey("Aucune activité récente"))
                                    .font(.subheadline)
                                    .foregroundColor(.noorSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            } else {
                                ForEach(activeDays, id: \.self) { date in
                                    let xp = dataManager.userProgress?.dailyXP[formatDate(date)] ?? 0
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.noorGold.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.noorGold)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(relativeDate(date: date))
                                                .fontWeight(.bold)
                                            Text("Leçon complétée")
                                                .font(.caption)
                                                .foregroundColor(.noorSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("+\(xp) XP")
                                            .fontWeight(.black)
                                            .foregroundColor(.noorGold)
                                    }
                                    .padding()
                                    
                                    if date != activeDays.last {
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .background(Color.noorSecondary.opacity(0.04))
                        .cornerRadius(24)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 120)
                }
            }
            
            VStack {
                Spacer()
                Button(LocalizedStringKey("Génial !")) { dismiss() }
                    .buttonStyle(NoorPrimaryButtonStyle())
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(colors: [.noorBackground.opacity(0), .noorBackground], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                    )
            }
        }
        .background(Color.noorBackground.ignoresSafeArea())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func relativeDate(date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Aujourd'hui" }
        if Calendar.current.isDateInYesterday(date) { return "Hier" }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "fr_FR")
        return df.string(from: date)
    }
    
    private var formattedInstallationDate: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: languageManager.currentLanguage.rawValue)
        return df.string(from: dataManager.userProgress?.installationDate ?? Date())
    }
    
    private func achievementInfo(for id: UserProgress.AchievementID) -> AchievementInfo {
        switch id {
        case .beginner:
            return AchievementInfo(title: "Débutant", subtitle: "Premier XP gagné", icon: "sparkles", color: .blue)
        case .persistent:
            return AchievementInfo(title: "Persistant", subtitle: "3 jours de série", icon: "flame", color: .orange)
        case .expert:
            return AchievementInfo(title: "Expert", subtitle: "100 XP atteint", icon: "shield.fill", color: .purple)
        case .alphabetic:
            return AchievementInfo(title: "Linguiste", subtitle: "10 lettres apprises", icon: "character.book.closed.fill", color: .green)
        case .weeklyHero:
            return AchievementInfo(title: "Héros", subtitle: "50 XP cette semaine", icon: "bolt.fill", color: .yellow)
        }
    }
    
    struct AchievementInfo {
        let title: LocalizedStringKey
        let subtitle: LocalizedStringKey
        let icon: String
        let color: Color
    }
}

struct MilestoneCard: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                if isUnlocked {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                }
                
                ZStack {
                    Circle()
                        .fill(isUnlocked ?
                            AnyShapeStyle(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                            AnyShapeStyle(Color.noorSecondary.opacity(0.1)))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: isUnlocked ? icon : "lock.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isUnlocked ? .white : .noorSecondary.opacity(0.4))
                }
                .shadow(color: isUnlocked ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isUnlocked ? .noorText : .noorSecondary.opacity(0.6))
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.noorSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
            }
        }
        .frame(width: 120, height: 160)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.noorSecondary.opacity(isUnlocked ? 0.05 : 0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isUnlocked ? color.opacity(0.2) : Color.clear, lineWidth: 1.5)
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.8)
    }
}

struct LeagueDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let weeklyXP = dataManager.userProgress?.currentWeekXP() ?? 0
        let leagueName = getLeague(xp: weeklyXP)
        let leagueColor = getLeagueColor(xp: weeklyXP)
        
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(leagueColor.opacity(0.1))
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 60))
                                .foregroundColor(leagueColor)
                                .shadow(color: leagueColor.opacity(0.3), radius: 10)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text(LocalizedStringKey("Ligue"))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text(LocalizedStringKey(leagueName))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                            }
                            
                            Text(LocalizedStringKey("Ton rang est basé sur tes XP de la semaine."))
                                .font(.subheadline)
                                .foregroundColor(.noorSecondary)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        LeagueRow(name: "Bronze", minXP: 0, currentXP: weeklyXP, color: .orange)
                        LeagueRow(name: "Argent", minXP: 50, currentXP: weeklyXP, color: .gray)
                        LeagueRow(name: "Or", minXP: 150, currentXP: weeklyXP, color: .yellow)
                        LeagueRow(name: "Platine", minXP: 300, currentXP: weeklyXP, color: .cyan)
                        LeagueRow(name: "Émeraude", minXP: 600, currentXP: weeklyXP, color: .green)
                        LeagueRow(name: "Diamant", minXP: 1000, currentXP: weeklyXP, color: .blue)
                    }
                    .padding(25)
                    .background(Color.noorSecondary.opacity(0.04))
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    Text(LocalizedStringKey("La ligue est réinitialisée chaque lundi."))
                        .font(.caption)
                        .foregroundColor(.noorSecondary.opacity(0.6))
                        .padding(.bottom, 120)
                }
            }
            
            VStack {
                Spacer()
                Button(LocalizedStringKey("Fermer")) { dismiss() }
                    .buttonStyle(NoorPrimaryButtonStyle())
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(colors: [.noorBackground.opacity(0), .noorBackground], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                    )
            }
        }
        .background(Color.noorBackground.ignoresSafeArea())
    }
    
    private func getLeague(xp: Int) -> String {
        if xp < 50 { return "Bronze" }
        if xp < 150 { return "Argent" }
        if xp < 300 { return "Or" }
        if xp < 600 { return "Platine" }
        if xp < 1000 { return "Émeraude" }
        return "Diamant"
    }
    
    private func getLeagueColor(xp: Int) -> Color {
        if xp < 50 { return .orange }
        if xp < 150 { return .gray }
        if xp < 300 { return .yellow }
        if xp < 600 { return .cyan }
        if xp < 1000 { return .green }
        return .blue
    }
}

struct LeagueRow: View {
    let name: LocalizedStringKey
    let minXP: Int
    let currentXP: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            
            Text(name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Spacer()
            
            if currentXP >= minXP {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Text(LocalizedStringKey("\(minXP) XP requis"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.noorSecondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NoorPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.noorGold)
            .cornerRadius(18)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - FAQ View
struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    
    struct FAQItem: Identifiable {
        let id = UUID()
        let question: LocalizedStringKey
        let answer: LocalizedStringKey
    }
    
    let items: [FAQItem] = [
        FAQItem(
            question: LocalizedStringKey("Comment fonctionne la série ?"),
            answer: LocalizedStringKey("La série augmente chaque jour où vous terminez une leçon. Si vous manquez un jour, elle retombe à zéro !")
        ),
        FAQItem(
            question: LocalizedStringKey("Comment gagner des XP ?"),
            answer: LocalizedStringKey("Gagnez des XP en terminant des leçons, en révisant des lettres ou en complétant des séries.")
        ),
        FAQItem(
            question: LocalizedStringKey("Puis-je utiliser l'app hors ligne ?"),
            answer: LocalizedStringKey("Oui ! Noorine fonctionne parfaitement sans connexion internet une fois installée.")
        ),
        FAQItem(
            question: LocalizedStringKey("Comment sont calculées les ligues ?"),
            answer: LocalizedStringKey("Les ligues sont basées sur votre total d'XP hebdomadaire. Plus vous apprenez, plus vous montez !")
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    DisclosureGroup {
                        Text(item.answer)
                            .padding(.vertical, 8)
                            .foregroundColor(.noorSecondary)
                    } label: {
                        Text(item.question)
                            .font(.headline)
                            .foregroundColor(.noorText)
                            .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.noorBackground)
            .navigationTitle(LocalizedStringKey("Foire aux questions"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.noorSecondary.opacity(0.5))
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LanguageManager())
        .environmentObject(DataManager.shared)
}
