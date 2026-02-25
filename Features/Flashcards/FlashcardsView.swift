import SwiftUI

struct FlashcardsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject private var manager = FlashcardManager.shared
    
    @State private var cards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showLibrary = false
    @State private var sessionStats = SessionStats()
    @State private var showCompletion = false
    @State private var cardOffset: CGSize = .zero
    @State private var selectedDiacritic: DiacriticInfo? = nil
    
    private var currentCard: Flashcard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                Spacer()
                
                if showCompletion {
                    completionView
                } else if let card = currentCard {
                    cardStack(card)
                } else {
                    emptyStateView
                }
                
                Spacer()
                
                if currentCard != nil && !showCompletion {
                    responseButtons
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadCards() }
        .sheet(isPresented: $showLibrary) {
            FlashcardLibraryView { selected in
                jumpToCard(selected)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
                            .shadow(color: .black.opacity(0.06), radius: 8)
                    )
            }
            
            Spacer()
            
            progressView
            
            Spacer()
            
            Button(action: { showLibrary = true }) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
                            .shadow(color: .black.opacity(0.06), radius: 8)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var progressView: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Text("\(currentIndex + 1)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.noorGold)
                Text("/")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.noorSecondary)
                Text("\(cards.count)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.noorText)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(width: 120, height: 6)
        }
    }
    
    private var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }
    
    private func cardStack(_ card: Flashcard) -> some View {
        ZStack {
            SRSCardView(
                card: card,
                isFlipped: $isFlipped,
                selectedDiacritic: $selectedDiacritic,
                isEnglish: isEnglish
            )
            .offset(x: cardOffset.width, y: cardOffset.height * 0.2)
            .rotationEffect(.degrees(Double(cardOffset.width / 30)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        cardOffset = value.translation
                    }
                    .onEnded { value in
                        handleSwipe(value.translation)
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
                HapticManager.shared.impact(.light)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func handleSwipe(_ translation: CGSize) {
        if translation.width > 120 {
            withAnimation(.spring(response: 0.3)) {
                cardOffset = CGSize(width: 500, height: 0)
            }
            handleResponse(.easy)
        } else if translation.width < -120 {
            withAnimation(.spring(response: 0.3)) {
                cardOffset = CGSize(width: -500, height: 0)
            }
            handleResponse(.again)
        } else {
            withAnimation(.spring()) {
                cardOffset = .zero
            }
        }
    }
    
    private var responseButtons: some View {
        VStack(spacing: 16) {
            if isFlipped {
                Button(action: {
                    if let card = currentCard {
                        audioManager.playLetter(card.arabic)
                        HapticManager.shared.impact(.light)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(isEnglish ? "Listen" : "Écouter")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.noorGold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color.noorGold.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .transition(.opacity)

                HStack(spacing: 10) {
                    SRSButton(response: .again, interval: "< 1m", isEnglish: isEnglish) {
                        handleResponse(.again)
                    }
                    SRSButton(response: .hard, interval: "< 10m", isEnglish: isEnglish) {
                        handleResponse(.hard)
                    }
                    SRSButton(response: .good, interval: intervalText(.good), isEnglish: isEnglish) {
                        handleResponse(.good)
                    }
                    SRSButton(response: .easy, interval: intervalText(.easy), isEnglish: isEnglish) {
                        handleResponse(.easy)
                    }
                }
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 20) {
                    CircleButton(icon: "speaker.wave.2.fill", color: .noorGold) {
                        if let card = currentCard {
                            audioManager.playLetter(card.arabic)
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.bottom, 30)
        .animation(.spring(response: 0.4), value: isFlipped)
    }
    
    private func intervalText(_ response: SRSResponse) -> String {
        guard let card = currentCard else { return "" }
        let interval = manager.getInterval(for: card)
        let d = isEnglish ? "d" : "j"
        
        switch response {
        case .again: return "< 1m"
        case .hard: return "< 10m"
        case .good:
            return interval == 0 ? "1\(d)" : "\(max(1, interval))\(d)"
        case .easy:
            return interval == 0 ? "4\(d)" : "\(max(4, interval * 2))\(d)"
        }
    }
    
    private func handleResponse(_ response: SRSResponse) {
        guard let card = currentCard else { return }
        
        manager.recordResponse(response, for: card)
        
        switch response {
        case .again, .hard:
            sessionStats.reviewCount += 1
            FeedbackManager.shared.tapMedium()
        case .good:
            sessionStats.goodCount += 1
            FeedbackManager.shared.tapLight()
        case .easy:
            sessionStats.easyCount += 1
            FeedbackManager.shared.success()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4)) {
                cardOffset = .zero
                isFlipped = false
                selectedDiacritic = nil
                
                if currentIndex < cards.count - 1 {
                    currentIndex += 1
                } else {
                    showCompletion = true
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            EmotionalMascot(mood: .encouraging, size: 100, showAura: true)
            
            VStack(spacing: 8) {
                Text(isEnglish ? "All caught up!" : "Tout est à jour !")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(isEnglish ? "No cards to review right now" : "Aucune carte à réviser pour l'instant")
                    .font(.subheadline)
                    .foregroundColor(.noorSecondary)
            }
            
            Button(action: { dismiss() }) {
                Text(isEnglish ? "Back" : "Retour")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorGold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(Color.noorGold.opacity(0.12))
                    )
            }
        }
        .padding(40)
    }
    
    private var completionView: some View {
        VStack(spacing: 28) {
            EmotionalMascot(mood: .celebrating, size: 100, showAura: true)
            
            VStack(spacing: 8) {
                Text(isEnglish ? "Session Complete!" : "Session terminée !")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Text(isEnglish ? "\(cards.count) cards reviewed" : "\(cards.count) cartes révisées")
                    .font(.subheadline)
                    .foregroundColor(.noorSecondary)
            }
            
            HStack(spacing: 20) {
                FlashcardStatBadge(value: sessionStats.easyCount, label: isEnglish ? "Easy" : "Facile", color: .green)
                FlashcardStatBadge(value: sessionStats.goodCount, label: isEnglish ? "Good" : "Bien", color: .blue)
                FlashcardStatBadge(value: sessionStats.reviewCount, label: isEnglish ? "Review" : "Revoir", color: .orange)
            }
            
            Button(action: { dismiss() }) {
                Text(isEnglish ? "Finish" : "Terminer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing))
                    )
            }
            .padding(.top, 8)
        }
        .padding(32)
    }
    
    private func loadCards() {
        let pool = dataManager.practicePool(language: languageManager.currentLanguage)
        let allowedArabic = Set(pool.words.map { $0.arabic })
        cards = manager.getPracticeCards(limit: 20, allowedArabic: allowedArabic)
        currentIndex = 0
        isFlipped = false
        showCompletion = false
        sessionStats = SessionStats()
        cardOffset = .zero
        selectedDiacritic = nil
    }
    
    private func jumpToCard(_ card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            withAnimation { currentIndex = index }
        } else {
            cards.append(card)
            withAnimation { currentIndex = cards.count - 1 }
        }
        isFlipped = false
        selectedDiacritic = nil
    }
}

struct SRSCardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool
    @Binding var selectedDiacritic: DiacriticInfo?
    let isEnglish: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    private let diacriticPurple = Color(red: 0.6, green: 0.3, blue: 0.85)
    
    var body: some View {
        ZStack {
            cardBack
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            cardFront
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(height: 440)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
    }
    
    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            
            VStack(spacing: 0) {
                EmotionalMascot(mood: .thinking, size: 60, showAura: false)
                    .padding(.top, 32)

                Spacer()

                Text(card.arabic)
                    .font(.system(size: 80))
                    .foregroundColor(.noorText)
                
                Text(card.transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .padding(.top, 8)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 12))
                    Text(isEnglish ? "Tap to reveal" : "Appuyer pour révéler")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.6))
                .padding(.bottom, 24)
            }
        }
    }
    
    private var cardBack: some View {
        let diacritics = DiacriticHelper.detectDiacritics(in: card.exampleArabic)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.noorGold.opacity(0.08), Color.orange.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.noorGold.opacity(0.2), lineWidth: 1)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    EmotionalMascot(mood: .happy, size: 60, showAura: false)
                        .padding(.top, 20)
                    
                    Text(isEnglish ? card.english : card.french)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.noorText)
                    
                    highlightedArabicText()
                        .padding(.horizontal, 16)
                    
                    highlightedTranslationText()
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    if !diacritics.isEmpty {
                        diacriticsSection(diacritics)
                    }
                    
                    Spacer(minLength: 20)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 10))
                        Text(isEnglish ? "Tap to flip" : "Appuyer pour retourner")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.noorSecondary.opacity(0.5))
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
    private func diacriticsSection(_ diacritics: [DiacriticInfo]) -> some View {
        VStack(spacing: 10) {
            Divider().padding(.horizontal, 24)
            
            Text(isEnglish ? "Tap a sign to learn" : "Appuie sur un signe")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            FlowLayout(spacing: 8) {
                ForEach(diacritics) { info in
                    DiacriticPill(
                        info: info,
                        isSelected: selectedDiacritic?.name == info.name,
                        color: diacriticPurple
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDiacritic = selectedDiacritic?.name == info.name ? nil : info
                        }
                        HapticManager.shared.impact(.light)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            if let selected = selectedDiacritic {
                DiacriticExplanation(info: selected, isEnglish: isEnglish, color: diacriticPurple)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }
    
    private func highlightedArabicText() -> some View {
        let text = card.exampleArabic
        let targetWord = card.arabic
        
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652,
            0x064B, 0x064C, 0x064D, 0x0670
        ]
        
        let targetRange = text.range(of: targetWord, options: .diacriticInsensitive)
        
        var attributed = AttributedString()
        var index = 0
        
        for char in text {
            let charStr = String(char)
            let hasDiacritic = char.unicodeScalars.contains { diacriticScalars.contains($0.value) }
            
            let isInTarget: Bool
            if let range = targetRange {
                let charIndex = text.index(text.startIndex, offsetBy: index)
                isInTarget = charIndex >= range.lowerBound && charIndex < range.upperBound
            } else {
                isInTarget = false
            }
            
            var charAttr = AttributedString(charStr)
            charAttr.font = .system(size: 24, weight: .bold)
            
            if hasDiacritic {
                charAttr.foregroundColor = diacriticPurple
                charAttr.underlineStyle = .single
                charAttr.underlineColor = UIColor(diacriticPurple)
            } else {
                charAttr.foregroundColor = isInTarget ? .noorGold : .noorText
            }
            
            attributed.append(charAttr)
            index += 1
        }
        
        return Text(attributed)
            .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func highlightedTranslationText() -> some View {
        let fullText = isEnglish ? card.exampleEnglish : card.example
        let target = isEnglish ? card.english : card.french
        
        var attributed = AttributedString(fullText)
        attributed.font = .system(size: 15, weight: .medium)
        attributed.foregroundColor = .noorSecondary
        
        if let range = attributed.range(of: target, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributed[range].foregroundColor = .noorGold
            attributed[range].font = .system(size: 15, weight: .bold)
        }
        
        return Text(attributed)
    }
}

struct DiacriticPill: View {
    let info: DiacriticInfo
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(info.character)
                    .font(.system(size: 18))
                Text(info.name)
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : color.opacity(0.12))
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct DiacriticExplanation: View {
    let info: DiacriticInfo
    let isEnglish: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(info.character)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(info.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                    Text(info.nameAr)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Text(isEnglish ? info.explanation : info.explanationFr)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(14)
    }
}

struct SRSButton: View {
    let response: SRSResponse
    let interval: String
    let isEnglish: Bool
    let action: () -> Void
    
    private var config: (color: Color, icon: String, label: String) {
        switch response {
        case .again: return (.red, "arrow.counterclockwise", isEnglish ? "Again" : "Revoir")
        case .hard: return (.orange, "tortoise.fill", isEnglish ? "Hard" : "Difficile")
        case .good: return (.blue, "hand.thumbsup.fill", isEnglish ? "Good" : "Bien")
        case .easy: return (.green, "bolt.fill", isEnglish ? "Easy" : "Facile")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: config.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(config.color)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(config.color.opacity(0.12)))
                
                Text(LocalizedStringKey(config.label))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.noorText)
                
                Text(interval)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .tapScale()
    }
}

struct CircleButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        .shadow(color: color.opacity(0.4), radius: 12, y: 6)
                )
        }
    }
}

struct FlashcardStatBadge: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.noorSecondary)
        }
    }
}

struct SessionStats {
    var reviewCount = 0
    var goodCount = 0
    var easyCount = 0
}
