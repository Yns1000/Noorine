import SwiftUI

struct ModernCardView: View {
    let card: Flashcard
    let isTop: Bool
    var onSwipeRight: () -> Void
    var onSwipeLeft: () -> Void
    var onListen: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var isFlipped = false
    @State private var degrees: Double = 0
    @State private var selectedDiacritic: DiacriticInfo? = nil
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    
    private var swipeProgress: CGFloat { min(abs(offset.width) / 150, 1.0) }
    private var isSwipingRight: Bool { offset.width > 0 }
    
    private var dynamicMascotMood: EmotionalMascot.Mood {
        if swipeProgress > 0.3 {
            return isSwipingRight ? .happy : .thinking
        }
        return .happy
    }
    
    var body: some View {
        ZStack {
            cardBack
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            cardFront
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 320, height: 420)
        .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
        .offset(x: offset.width, y: offset.height * 0.3)
        .rotationEffect(.degrees(Double(offset.width / 25)))
        .scaleEffect(isTop ? 1.0 : 0.92)
        .opacity(isTop ? 1.0 : 0.0)
        .gesture(
            isTop ? DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        withAnimation(.spring(response: 0.3)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        onSwipeRight()
                    } else if offset.width < -100 {
                        withAnimation(.spring(response: 0.3)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        onSwipeLeft()
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
            : nil
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                degrees += 180
                isFlipped.toggle()
            }
            HapticManager.shared.impact(.light)
        }
    }
    
    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 15)
            
            if isTop && swipeProgress > 0.1 {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSwipingRight ? Color.green : Color.orange, lineWidth: 4)
                    .opacity(Double(swipeProgress))
            }
            
            VStack(spacing: 0) {
                EmotionalMascot(mood: dynamicMascotMood, size: 65, showAura: false)
                    .animation(.spring(response: 0.3), value: dynamicMascotMood)
                    .padding(.top, 50)
                
                Spacer()
                
                Text(card.arabic)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.noorText)
                
                Text(card.transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .padding(.top, 8)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 12))
                    Text(LocalizedStringKey("Appuyer pour révéler"))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.6))
                .padding(.bottom, 24)
            }
            
            if isTop && swipeProgress > 0.2 {
                VStack {
                    HStack {
                        if !isSwipingRight {
                            swipeLabel(text: "À revoir", color: .orange, icon: "arrow.counterclockwise")
                                .opacity(Double(swipeProgress))
                        }
                        Spacer()
                        if isSwipingRight {
                            swipeLabel(text: "Je connais", color: .green, icon: "checkmark")
                                .opacity(Double(swipeProgress))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    Spacer()
                }
            }
        }
    }
    
    private var cardBack: some View {
        let diacritics = DiacriticHelper.detectDiacritics(in: card.exampleArabic)
        let isEnglish = languageManager.currentLanguage == .english
        
        return ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.noorGold.opacity(0.12), Color.orange.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 15)
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.noorGold.opacity(0.3), lineWidth: 2)
            
            VStack(spacing: 14) {
                EmotionalMascot(mood: dynamicMascotMood, size: 50, showAura: false)
                    .animation(.spring(response: 0.3), value: dynamicMascotMood)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                
                Text(isEnglish ? card.english : card.french)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                highlightedArabicText(for: card)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                
                highlightedTranslationText(for: card)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                
                if !diacritics.isEmpty {
                    VStack(spacing: 10) {
                        Text(isEnglish ? "Tap a sign to learn" : "Appuie sur un signe")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(diacritics) { info in
                                diacriticPillButton(info: info, isSelected: selectedDiacritic?.name == info.name)
                            }
                        }
                        .padding(.horizontal, 14)
                        
                        if let selected = selectedDiacritic {
                            diacriticExplanationView(info: selected, isEnglish: isEnglish)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 6)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 10))
                    Text(LocalizedStringKey("Appuyer pour retourner"))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.4))
                .padding(.bottom, 14)
            }
            .padding(.horizontal, 10)
        }
    }
    
    private let diacriticPurple = Color(red: 0.6, green: 0.3, blue: 0.85)
    
    private func diacriticPillButton(info: DiacriticInfo, isSelected: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                if selectedDiacritic?.name == info.name {
                    selectedDiacritic = nil
                } else {
                    selectedDiacritic = info
                }
            }
            HapticManager.shared.impact(.light)
        } label: {
            VStack(spacing: 2) {
                Text(info.character)
                    .font(.system(size: 16))
                Text(info.name)
                    .font(.system(size: 7, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : diacriticPurple)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? diacriticPurple : diacriticPurple.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(diacriticPurple.opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func diacriticExplanationView(info: DiacriticInfo, isEnglish: Bool) -> some View {
        HStack(spacing: 10) {
            Text(info.character)
                .font(.system(size: 28))
                .frame(width: 40, height: 40)
                .background(diacriticPurple.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(info.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(diacriticPurple)
                    Text(info.nameAr)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Text(isEnglish ? info.explanation : info.explanationFr)
                    .font(.system(size: 11))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 4)
    }
    
    private func swipeLabel(text: LocalizedStringKey, color: Color, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func highlightedTranslationText(for card: Flashcard) -> some View {
        let isEnglish = languageManager.currentLanguage == .english
        let fullText = isEnglish ? card.exampleEnglish : card.example
        let translationTarget = isEnglish ? card.english : card.french
        let transliterationTarget = card.transliteration
        
        var attributedString = AttributedString(fullText)
        attributedString.font = .system(size: 15, weight: .medium)
        attributedString.foregroundColor = .noorSecondary
        
        if let range = attributedString.range(of: translationTarget, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributedString[range].foregroundColor = .noorGold
            attributedString[range].font = .system(size: 15, weight: .bold)
        } else if let range = attributedString.range(of: transliterationTarget, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributedString[range].foregroundColor = .noorGold
            attributedString[range].font = .system(size: 15, weight: .bold)
        } else {
            let cleanTrans = transliterationTarget.folding(options: .diacriticInsensitive, locale: .current)
            if let range = attributedString.range(of: cleanTrans, options: [.caseInsensitive, .diacriticInsensitive]) {
                attributedString[range].foregroundColor = .noorGold
                attributedString[range].font = .system(size: 15, weight: .bold)
            }
        }
        
        return Text(attributedString)
    }
    
    private func highlightedArabicText(for card: Flashcard) -> some View {
        let text = card.exampleArabic
        let targetWord = card.arabic
        
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652,
            0x064B, 0x064C, 0x064D, 0x0670
        ]
        
        let targetRange = text.range(of: targetWord, options: .diacriticInsensitive)
        
        var result = Text("")
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
            
            var charText = Text(charStr)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            
            if isInTarget {
                charText = charText.foregroundColor(.noorGold)
            } else {
                charText = charText.foregroundColor(.noorText)
            }
            
            if hasDiacritic {
                charText = charText.underline(true, color: diacriticPurple)
            }
            
            result = result + charText
            index += 1
        }
        
        return result
            .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func highlightedArabicTextWithDiacritics(for card: Flashcard) -> some View {
        let text = card.exampleArabic
        let targetWord = card.arabic
        let diacriticColor = Color(red: 0.7, green: 0.2, blue: 0.9)
        
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652,
            0x064B, 0x064C, 0x064D, 0x0670
        ]
        
        var result = Text("")
        var currentWord = ""
        var isInTargetWord = false
        
        for char in text {
            currentWord.append(char)
            
            if text.range(of: targetWord, options: .diacriticInsensitive) != nil {
                if currentWord.contains(targetWord.prefix(1)) {
                    isInTargetWord = currentWord.lowercased().hasPrefix(targetWord.lowercased().prefix(currentWord.count))
                }
            }
            
            var charColor: Color = .noorText
            var hasDiacritic = false
            
            for scalar in char.unicodeScalars {
                if diacriticScalars.contains(scalar.value) {
                    hasDiacritic = true
                    break
                }
            }
            
            if hasDiacritic {
                charColor = diacriticColor
            } else if let range = text.range(of: targetWord, options: .diacriticInsensitive),
                      text.distance(from: text.startIndex, to: range.lowerBound) <= text.distance(from: text.startIndex, to: text.index(text.startIndex, offsetBy: currentWord.count - 1)),
                      text.distance(from: text.startIndex, to: text.index(text.startIndex, offsetBy: currentWord.count - 1)) < text.distance(from: text.startIndex, to: range.upperBound) {
                charColor = .noorGold
            }
            
            result = result + Text(String(char))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(charColor)
        }
        
        return result
            .environment(\.layoutDirection, .rightToLeft)
    }
}
