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
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.noorGold.opacity(0.15), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 15)
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.noorGold.opacity(0.3), lineWidth: 2)
            
            VStack(spacing: 16) {
                EmotionalMascot(mood: dynamicMascotMood, size: 65, showAura: false)
                    .animation(.spring(response: 0.3), value: dynamicMascotMood)
                    .padding(.top, 50)
                
                Spacer()
                
                Text(languageManager.currentLanguage == .english ? card.english : card.french)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.noorText)
                
                Divider()
                    .frame(width: 60)
                    .padding(.vertical, 8)
                
                
                highlightedArabicText(for: card)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                highlightedTranslationText(for: card)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 12))
                    Text(LocalizedStringKey("Appuyer pour retourner"))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.noorSecondary.opacity(0.6))
                .padding(.bottom, 24)
            }
        }
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
        
        var attributedString = AttributedString(text)
        attributedString.font = .system(size: 24, weight: .bold, design: .rounded)
        attributedString.foregroundColor = .noorText
        
        if let range = attributedString.range(of: targetWord, options: [.diacriticInsensitive]) {
            attributedString[range].foregroundColor = .noorGold
        }
        
        return Text(attributedString)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
