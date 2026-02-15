import SwiftUI

struct LayoutConfig {
    static let buttonSize: CGFloat = 76
    static let verticalSpacing: CGFloat = 165
    static let amplitude: CGFloat = 50
    static let waveFrequency: Double = 0.85
    static let headerHeight: CGFloat = 90
}

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedLevel: LevelProgress?
    @State private var showStreakDetails = false
    @State private var showXPDetails = false
    @State private var showDailyChallengeInvite = false
    @State private var showDailyChallenge = false
    
    @State private var animationId = UUID()
    @State private var lastAutoScrollTarget: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()
                    .zIndex(0)
                
                GeometryReader { geometry in
                    let sortedLevels = dataManager.levels.sorted { $0.levelNumber < $1.levelNumber }
                    let contentHeight = CGFloat(sortedLevels.count + 1) * LayoutConfig.verticalSpacing + 50

                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ZStack(alignment: .top) {
                                PathLayer(levels: sortedLevels)
                                    .frame(width: geometry.size.width)
                                    .frame(height: contentHeight)
                                    .allowsHitTesting(false)
                                    .zIndex(0)

                                VStack(spacing: 0) {
                                    ForEach(Array(sortedLevels.enumerated()), id: \.element.levelNumber) { index, level in
                                        LevelNode(
                                            levelNumber: level.levelNumber,
                                            title: CourseContent.getLevelTitle(for: level.levelNumber, language: languageManager.currentLanguage),
                                            subtitle: CourseContent.getLevelSubtitle(for: level.levelNumber, language: languageManager.currentLanguage),
                                            state: dataManager.levelState(for: level.levelNumber),
                                            index: index,
                                            onTap: {
                                                let state = dataManager.levelState(for: level.levelNumber)
                                                if state != .locked {
                                                    selectedLevel = level
                                                }
                                            }
                                        )
                                        .frame(height: LayoutConfig.verticalSpacing)
                                        .id("level_\(level.levelNumber)")
                                    }
                                    
                                    ComingSoonNode(
                                        index: sortedLevels.count,
                                        isFrench: languageManager.currentLanguage != .english
                                    )
                                    .frame(height: LayoutConfig.verticalSpacing)
                                    .id("level_coming_soon")
                                }
                                .zIndex(1)
                            }
                            .padding(.bottom, 120)
                            .padding(.top, 20)
                            .background(
                                GeometryReader { scrollProxy in
                                    let scrollY = scrollProxy.frame(in: .named("homeScroll")).minY
                                    OrganizedWordLayer()
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .offset(y: -scrollY)
                                },
                                alignment: .top
                            )
                        }
                        .coordinateSpace(name: "homeScroll")
                        .onAppear {
                            scrollToLevel(proxy: proxy)
                        }
                        .onChange(of: dataManager.isAppReady) { _, ready in
                            if ready { scrollToLevel(proxy: proxy) }
                        }
                        .onChange(of: dataManager.levels.count) { _, _ in
                            scrollToLevel(proxy: proxy)
                        }
                        .onChange(of: dataManager.levels.map { $0.isCompleted }) { _, _ in
                            scrollToLevel(proxy: proxy)
                        }
                        .onChange(of: dataManager.progressTick) { _, _ in
                            scrollToLevel(proxy: proxy)
                        }
                    }
                }
                .zIndex(1)
            }
            .safeAreaInset(edge: .top) {
                HomeHeader(
                    xp: dataManager.userProgress?.xpTotal ?? 0,
                    streak: dataManager.userProgress?.streakDays ?? 0,
                    onStreakTap: { showStreakDetails = true },
                    onXPTap: { showXPDetails = true }
                )
            }
            .sheet(isPresented: $showStreakDetails) { StreakDetailView() }
            .sheet(isPresented: $showXPDetails) { XPDetailView() }
            .sheet(isPresented: $showDailyChallengeInvite, onDismiss: {
                if !showDailyChallenge {
                    dataManager.dismissDailyChallenge()
                }
            }) {
                DailyChallengeInviteView(
                    onStart: {
                        showDailyChallengeInvite = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showDailyChallenge = true }
                    },
                    onDismiss: {
                        showDailyChallengeInvite = false
                    }
                )
                .presentationDetents([.height(240)])
            }
            .fullScreenCover(isPresented: $showDailyChallenge) { DailyChallengeView() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(item: $selectedLevel) { level in
                NavigationStack {
                    switch level.levelType {
                    case .vowels:
                        VowelLessonView(levelNumber: level.levelNumber)
                    case .wordBuild:
                        WordAssemblyView(levelNumber: level.levelNumber, onCompletion: {
                            dataManager.completeLevel(levelNumber: level.levelNumber)
                            selectedLevel = nil
                        })
                    case .solarLunar:
                        SolarLunarLessonView(onCompletion: {
                            dataManager.completeLevel(levelNumber: level.levelNumber)
                            selectedLevel = nil
                        })
                    case .phrases:
                        PhraseLessonView(levelNumber: level.levelNumber, onCompletion: {
                            dataManager.completeLevel(levelNumber: level.levelNumber)
                            selectedLevel = nil
                        })
                    case .speaking:
                        let letterIds = CourseContent.getLevels(language: languageManager.currentLanguage)
                            .first(where: { $0.id == level.levelNumber })?
                            .contentIds ?? []
                        let letters = ArabicLetter.alphabet.filter { letterIds.contains($0.id) }
                        SpeakingPracticeView(
                            sessionTitle: languageManager.currentLanguage == .english ? "Pronunciation" : "Prononciation",
                            sessionLetters: letters.isEmpty ? ArabicLetter.alphabet : letters,
                            goalCount: 5,
                            onCompletion: {
                                dataManager.completeLevel(levelNumber: level.levelNumber)
                                selectedLevel = nil
                            }
                        )
                    case .alphabet, .quiz:
                        let letters = ArabicLetter.letters(forLevel: level.levelNumber)
                        if letters.count == 1, let letter = letters.first {
                            LetterLessonView(letter: letter, levelNumber: level.levelNumber)
                        } else {
                            LevelDetailView(levelNumber: level.levelNumber, title: level.title)
                        }
                    }
                }
            }
            .onAppear {
                if dataManager.isAppReady {
                    dataManager.manageStreakActivity()
                    if dataManager.canShowDailyChallenge() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if selectedLevel == nil {
                                showDailyChallengeInvite = true
                            }
                        }
                    }
                }
            }
            .onChange(of: dataManager.isAppReady) { _, ready in
                if ready {
                    if dataManager.canShowDailyChallenge() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if selectedLevel == nil {
                                showDailyChallengeInvite = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func scrollToLevel(proxy: ScrollViewProxy) {
        guard dataManager.isAppReady, !dataManager.levels.isEmpty else { return }
        let target = lastUnlockedLevel()
        lastAutoScrollTarget = target
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                proxy.scrollTo("level_\(target)", anchor: .center)
            }
        }
    }

    private func lastUnlockedLevel() -> Int {
        let sorted = dataManager.levels.sorted { $0.levelNumber < $1.levelNumber }
        let lastUnlocked = sorted.last { dataManager.levelState(for: $0.levelNumber) != .locked }
        return lastUnlocked?.levelNumber ?? dataManager.currentLevelNumber
    }

}

struct AmbientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [Color.noorGold.opacity(0.12), Color.clear]), center: .center, startRadius: 0, endRadius: 200))
                .frame(width: 400, height: 400)
                .offset(x: animateGradient ? 50 : -50, y: animateGradient ? -100 : -50)
                .blur(radius: 60)
            
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [Color.orange.opacity(0.06), Color.clear]), center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: animateGradient ? -80 : -30, y: animateGradient ? 400 : 500)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct OrganizedWordLayer: View {
    let items: [FloatingItemData] = [
        .word("لورين", fr: "Laurine", en: "Laurine"),
        .word("لورين", fr: "Laurine", en: "Laurine"),
        .word("لورين", fr: "Laurine", en: "Laurine"),
        .word("لورين", fr: "Laurine", en: "Laurine"),
        .word("أميرة", fr: "Princesse", en: "Princess"),
        .word("سمراء", fr: "Brune", en: "Brunette"),
        .word("كرة طائرة", fr: "Volleyball", en: "Volleyball"),
        .word("كرة سلة", fr: "Basketball", en: "Basketball"),
        .word("إسبانيا", fr: "Espagne", en: "Spain"),
        .word("المغرب", fr: "Maroc", en: "Morocco"),
        .word("ماجستير", fr: "Master", en: "Master's degree"),
        .word("جامعة", fr: "Université", en: "University"),
        .word("أراس", fr: "Arras", en: "Arras"),
        .word("ماري", fr: "Marie", en: "Marie"),
        .word("ميلودي", fr: "Mélodie", en: "Mélodie"),
        .word("مبتسمة", fr: "Souriante", en: "Smiling girl"),
        .word("جميلة", fr: "Belle", en: "Beautiful"),
        .word("لطيفة", fr: "Douce", en: "Gentle"),
        .word("طيبة", fr: "Gentille", en: "Kind-hearted"),
        .word("ذكية", fr: "Intelligente", en: "Brilliant"),
        .word("رائعة", fr: "Magnifique", en: "Magnificent"),
        .word("رونو سينيك", fr: "Renault Scénic", en: "Renault Scénic"),
        .word("فاوانيا", fr: "Pivoine", en: "Peony"),
        .word("توليب", fr: "Tulipe", en: "Tulip"),
        .word("زنبق", fr: "Lys", en: "Lily"),
        .word("ساحرة", fr: "Envoûtante", en: "Enchanting"),
        .word("حنونة", fr: "Affectueuse", en: "Affectionate"),
        .word("مشرقة", fr: "Radieuse", en: "Radiant"),
        .word("فريدة", fr: "Unique", en: "Unique"),
        .word("وردة", fr: "Rose", en: "Rose"),
        .word("ياسمين", fr: "Jasmin", en: "Jasmine"),
        .word("نورين", fr: "Noorine", en: "Noorine"),
        .word("ضحكة جميلة", fr: "Beau rire", en: "Beautiful laugh"),
        .word("قلب طيب", fr: "Cœur pur", en: "Pure heart"),
        .word("نجمة", fr: "Étoile", en: "Star"),
        .word("شمس", fr: "Soleil", en: "Sun"),
        .word("قمر", fr: "Lune", en: "Moon"),
        .word("أحبك", fr: "Je t'aime", en: "I love you"),
        .word("عائلة", fr: "Famille", en: "Family"),
        .word("سعادة", fr: "Bonheur", en: "Happiness"),
        .word("ابتسامة", fr: "Sourire", en: "Smile"),
        .icon("crown.fill"),
        .icon("star.fill"),
        .icon("heart.fill"),
        .icon("bolt.fill"),
        .icon("moon.stars.fill"),
        .icon("sparkles"),
        .icon("globe.europe.africa.fill"),
        .icon("sun.max.fill"),
        .icon("music.note"),
        .icon("graduationcap.fill"),
        .icon("book.fill"),
        .icon("paintpalette.fill"),
        .icon("leaf.fill"),
        .icon("flame.fill"),
        .icon("wand.and.stars")
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let yPercent = 0.08 + (CGFloat(index % 12) * 0.07)
                    let speed = 60.0 + Double(index * 8)
                    let offset = Double(index) * 0.25
                    
                    let progress = ((time / speed) + offset).truncatingRemainder(dividingBy: 1.0)
                    let xPos = screenWidth + 100 - (CGFloat(progress) * (screenWidth + 300))
                    let yPos = screenHeight * yPercent
                    
                    FloatingWordView(item: item)
                        .position(x: xPos, y: yPos)
                }
            }
        }
    }
}

struct FloatingWordView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let item: FloatingItemData
    @State private var isRevealed = false
    
    var body: some View {
        switch item.type {
        case .word(let arabic, let french, let english):
            let translation = languageManager.currentLanguage == .english ? english : french
            Text(isRevealed ? translation : arabic)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal, isRevealed ? 12 : 0)
                .padding(.vertical, isRevealed ? 6 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isRevealed ? Color.noorGold.opacity(0.5) : Color.clear)
                )
                .foregroundColor(isRevealed ? .white : Color.primary.opacity(0.25))
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.3)) {
                        isRevealed.toggle()
                    }
                    if isRevealed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut) { isRevealed = false }
                        }
                    }
                }
            
        case .icon(let name):
            Image(systemName: name)
                .font(.system(size: 20))
                .foregroundColor(Color.primary.opacity(0.12))
        }
    }
}

struct FloatingItemData {
    enum ItemType {
        case word(arabic: String, french: String, english: String)
        case icon(name: String)
    }
    let type: ItemType
    
    static func word(_ ar: String, fr: String, en: String) -> FloatingItemData {
        return FloatingItemData(type: .word(arabic: ar, french: fr, english: en))
    }
    static func icon(_ name: String) -> FloatingItemData {
        return FloatingItemData(type: .icon(name: name))
    }
}

struct HomeHeader: View {
    let xp: Int
    let streak: Int
    var onStreakTap: () -> Void = {}
    var onXPTap: () -> Void = {}
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: onStreakTap) {
                    StatBadge(icon: "flame.fill", value: "\(streak)", iconColor: .orange)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: onXPTap) {
                    StatBadge(icon: "star.fill", value: "\(xp)", iconColor: .noorGold)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(spacing: 0) {
                Text("NOORINE")
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .tracking(4)
                    .foregroundColor(Color.noorText)
                
                Text("نورين")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.noorGold)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .padding(.top, 8)
        .background(Color.noorBackground.opacity(0.95))
        .overlay(
            Rectangle()
                .fill(LinearGradient(colors: [Color.noorGold.opacity(0.3), Color.noorGold.opacity(0.1), Color.clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color.noorText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(.ultraThinMaterial).shadow(color: Color.black.opacity(0.06), radius: 4, y: 2))
    }
}

struct PathLayer: View {
    let levels: [LevelProgress]
    
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            guard levels.count > 1 else { return }
            for index in 0..<(levels.count - 1) {
                let isPathUnlocked = levels[index].isCompleted
                let startY = (LayoutConfig.verticalSpacing / 2) + (CGFloat(index) * LayoutConfig.verticalSpacing)
                let startX = centerX + (CGFloat(sin(Double(index) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude)
                let endY = startY + LayoutConfig.verticalSpacing
                let endX = centerX + (CGFloat(sin(Double(index + 1) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude)
                
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                let controlY = (startY + endY) / 2
                path.addCurve(to: CGPoint(x: endX, y: endY), control1: CGPoint(x: startX, y: controlY), control2: CGPoint(x: endX, y: controlY))
                
                if isPathUnlocked {
                    context.stroke(path, with: .color(Color.noorGold), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    context.stroke(path, with: .color(Color.noorGold.opacity(0.3)), style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                } else {
                    context.stroke(path, with: .color(Color.noorSecondary.opacity(0.3)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [10, 14]))
                }
            }
        }
    }
}

struct FloatingDecoElement: View {
    let icon: String
    let size: CGFloat
    let xPos: CGFloat
    let yPos: CGFloat
    let delay: Double
    @State private var floating: Bool = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size, weight: .light))
            .foregroundColor(Color.noorGold.opacity(0.25))
            .offset(x: xPos, y: yPos + (floating ? -8 : 8))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { floating = true }
                }
            }
    }
}

struct ComingSoonNode: View {
    let index: Int
    let isFrench: Bool
    @State private var pulse: CGFloat = 1.0
    
    var xOffset: CGFloat {
        CGFloat(sin(Double(index) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude
    }
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color.noorBackground, Color.noorBackground.opacity(0.8)],
                        center: .center, startRadius: 0,
                        endRadius: LayoutConfig.buttonSize / 2 + 15
                    ))
                    .frame(width: LayoutConfig.buttonSize + 30, height: LayoutConfig.buttonSize + 30)
                    .allowsHitTesting(false)
                
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize)
                        .offset(y: 5)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.noorSecondary.opacity(0.2), Color.noorSecondary.opacity(0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.noorGold.opacity(0.3), Color.orange.opacity(0.15)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.noorGold.opacity(0.5), Color.orange.opacity(0.3)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .scaleEffect(pulse)
                }
                
                VStack(spacing: 3) {
                    Text(isFrench ? "Bientôt" : "Coming Soon")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.noorGold.opacity(0.7))
                    Text(isFrench ? "Nouveaux niveaux" : "New levels")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color.noorSecondary.opacity(0.5))
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.noorGold.opacity(0.15), lineWidth: 1)
                        )
                )
                .offset(y: 80)
                .zIndex(1)
                .allowsHitTesting(false)
            }
            .offset(x: xOffset)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = 1.12
            }
        }
    }
}

struct LevelNode: View {
    let levelNumber: Int
    let title: String
    let subtitle: String
    let state: LevelState
    let index: Int
    let onTap: () -> Void
    
    var xOffset: CGFloat {
        CGFloat(sin(Double(index) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude
    }
    
    private let decoIcons = ["star.fill", "sparkle", "moon.stars.fill", "book.fill", "graduationcap.fill"]
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                if state == .completed && index % 2 == 0 {
                    FloatingDecoElement(icon: decoIcons[index % decoIcons.count], size: 12, xPos: xOffset > 0 ? -55 : 55, yPos: -15, delay: Double(index) * 0.2).allowsHitTesting(false)
                }
                
                Circle()
                    .fill(RadialGradient(colors: [Color.noorBackground, Color.noorBackground.opacity(0.8)], center: .center, startRadius: 0, endRadius: LayoutConfig.buttonSize / 2 + 15))
                    .frame(width: LayoutConfig.buttonSize + 30, height: LayoutConfig.buttonSize + 30)
                    .allowsHitTesting(false)
                
                Button(action: onTap) {
                    if state == .current {
                        CurrentLevelButton()
                    } else {
                        StandardLevelButton(state: state)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .tapScale()
                .frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize)
                .contentShape(Circle())
                
                LevelInfoCard(title: title, subtitle: subtitle, isCurrent: state == .current)
                    .offset(y: state == .current ? 95 : 80)
                    .zIndex(1)
                    .allowsHitTesting(false)
            }
            .offset(x: xOffset)
            Spacer()
        }
    }
}

struct CurrentLevelButton: View {
    @State private var outerRingRotation: Double = 0
    @State private var innerRingRotation: Double = 0
    @State private var glowOpacity: Double = 0.6
    @State private var particleOffset: CGFloat = 0
    @State private var auroraPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(gradient: Gradient(colors: [Color.noorGold.opacity(0.35), Color.noorGold.opacity(0.15), Color.orange.opacity(0.05), Color.clear]), center: .center, startRadius: 30, endRadius: 250)).frame(width: 500, height: 500).scaleEffect(auroraPulse).blur(radius: 40).opacity(glowOpacity * 0.6).allowsHitTesting(false)
            Circle().fill(RadialGradient(gradient: Gradient(colors: [Color.noorGold.opacity(0.25), Color.noorGold.opacity(0.08), Color.clear]), center: .center, startRadius: 40, endRadius: 90)).frame(width: 180, height: 180).blur(radius: 20).opacity(glowOpacity).allowsHitTesting(false)
            Circle().strokeBorder(AngularGradient(gradient: Gradient(colors: [Color.noorGold.opacity(0), Color.noorGold.opacity(0.6), Color.orange.opacity(0.4), Color.noorGold.opacity(0)]), center: .center), lineWidth: 2).frame(width: 140, height: 140).rotationEffect(.degrees(outerRingRotation)).allowsHitTesting(false)
            NoorineMascot().frame(width: 95, height: 95)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { outerRingRotation = 360 }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { glowOpacity = 0.9; particleOffset = 5 }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { auroraPulse = 1.15 }
        }
    }
}

struct StandardLevelButton: View {
    let state: LevelState
    @State private var starRotation: Double = 0
    var iconName: String {
        switch state { case .locked: return "lock.fill"; case .completed: return "checkmark"; case .current: return "" }
    }
    
    var body: some View {
        ZStack {
            Circle().fill(state == .completed ? Color.noorGold.opacity(0.35) : Color.black.opacity(0.08)).frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize).offset(y: 5).blur(radius: state == .completed ? 3 : 0)
            Circle().fill(state == .completed ? LinearGradient(colors: [Color.noorGold, Color.orange.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.noorSecondary.opacity(0.25), Color.noorSecondary.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize).overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: state == .completed ? 3 : 2)).shadow(color: state == .completed ? Color.noorGold.opacity(0.4) : Color.clear, radius: 12, y: 4)
            Image(systemName: iconName).font(.system(size: state == .completed ? 28 : 20, weight: .bold)).foregroundColor(state == .completed ? .white : Color.noorSecondary.opacity(0.4))
        }
    }
}

struct LevelInfoCard: View {
    let title: String
    let subtitle: String
    let isCurrent: Bool
    @State private var glowPulse: Bool = false
    
    var body: some View {
        VStack(spacing: 3) {
            Text(LocalizedStringKey(title)).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(Color.noorText)
            Text(LocalizedStringKey(subtitle)).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(Color.noorSecondary)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(
            ZStack {
                if isCurrent { RoundedRectangle(cornerRadius: 14).fill(Color.noorGold.opacity(0.15)).blur(radius: 8).scaleEffect(glowPulse ? 1.1 : 1.0) }
                RoundedRectangle(cornerRadius: 14).fill(Color.noorBackground).overlay(RoundedRectangle(cornerRadius: 14).stroke(isCurrent ? LinearGradient(colors: [Color.noorGold.opacity(0.6), Color.orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isCurrent ? 1.5 : 1)).shadow(color: isCurrent ? Color.noorGold.opacity(0.2) : Color.black.opacity(0.06), radius: 6, y: 3)
            }
        )
        .onAppear { if isCurrent { withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { glowPulse = true } } }
    }
}

#Preview {
    HomeView().environmentObject(DataManager.shared)
}