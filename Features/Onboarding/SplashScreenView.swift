import SwiftUI

struct HandDrawnArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: rect.midX, y: 0)
        let end = CGPoint(x: rect.midX, y: rect.height)

        path.move(to: start)
        path.addCurve(to: end,
                      control1: CGPoint(x: rect.midX + 5, y: rect.height * 0.3),
                      control2: CGPoint(x: rect.midX - 5, y: rect.height * 0.7))
        
        path.move(to: end)
        path.addLine(to: CGPoint(x: rect.midX - 6, y: rect.height - 8))
        
        path.move(to: end)
        path.addLine(to: CGPoint(x: rect.midX + 6, y: rect.height - 8))
        
        return path
    }
}

struct SplashScreenView: View {
    @Binding var isActive: Bool
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    @State private var mascotScale: CGFloat = 0.0
    @State private var mascotOpacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 20
    
    @State private var showArabic = false
    @State private var showTranslation = false
    @State private var arrowProgress: CGFloat = 0.0
    
    @State private var animateBlobs = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var showEasterEggs = false
    
    private let dhillyMessages = [
        "Laurine tu es belle Allahuma barik",
        "En plus t'es trop intelligente ma sha الله",
        "Ai-je dis que tu étais wow ?",
        "Fais attention à ton genou",
        "Tu es vraiment swag subhanAllah"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ZStack {
                    Circle()
                        .fill(Color.noorGold.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: animateBlobs ? -80 : -160, y: animateBlobs ? -120 : -200)
                    
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .offset(x: animateBlobs ? 120 : 200, y: animateBlobs ? 180 : 300)
                    
                    Circle()
                        .fill(Color.noorGold.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .blur(radius: 70)
                        .offset(x: animateBlobs ? 50 : -30, y: animateBlobs ? -50 : 100)
                }
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateBlobs)
                
                if dataManager.isDhilly && showEasterEggs {
                    ForEach(Array(dhillyMessages.enumerated()), id: \.offset) { index, msg in
                        FloatingEasterEgg(message: msg, index: index, screenWidth: geometry.size.width)
                    }
                }
                
                VStack(spacing: 50) {
                    Spacer()
                    
                    EmotionalMascot(mood: mascotMood, size: 130, showAura: false)
                        .scaleEffect(mascotScale)
                        .opacity(mascotOpacity)
                    
                    VStack(spacing: 32) {
                        Text("NOORINE")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.noorText, .noorText.opacity(0.8)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .tracking(10)
                            .overlay(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.3), .clear],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 80)
                                    .offset(x: shimmerOffset)
                                    .mask(
                                        Text("NOORINE")
                                            .font(.system(size: 42, weight: .bold, design: .serif))
                                            .tracking(10)
                                    )
                            )
                            .clipped()
                        
                        ZStack {
                            if showArabic {
                                Text("التعلم المستنير")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.noorGold)
                                    .shadow(color: .noorGold.opacity(0.4), radius: 8)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    .offset(y: -45)
                            }
                            
                            if showArabic {
                                HandDrawnArrow()
                                    .trim(from: 0, to: arrowProgress)
                                    .stroke(Color.noorText.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                                    .frame(width: 20, height: 35)
                                    .offset(y: 5)
                            }
                            
                            if showTranslation {
                                Text(languageManager.currentLanguage == .english ? "ENLIGHTENED LEARNING" : "L'APPRENTISSAGE ÉCLAIRÉ")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.noorText.opacity(0.6))
                                    .tracking(5)
                                    .transition(.opacity.combined(with: .offset(y: 10)))
                                    .offset(y: 45)
                            }
                        }
                        .frame(height: 100)
                    }
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .onAppear {
            animateBlobs = true
            FeedbackManager.shared.tapMedium()
            
            NotificationManager.shared.requestPermissions()
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                mascotScale = 1.0
                mascotOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                mascotMood = .happy
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    titleOpacity = 1.0
                    titleOffset = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.linear(duration: 1.2)) {
                    shimmerOffset = 250
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                mascotMood = .celebrating
                withAnimation(.easeIn(duration: 0.8)) {
                    showArabic = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    arrowProgress = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeIn(duration: 0.8)) {
                    showTranslation = true
                }
            }
            
            if dataManager.isDhilly {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeIn(duration: 1.0)) {
                        showEasterEggs = true
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    dataManager.isAppReady = true
                    isActive = true
                }
            }
        }
    }
}

struct FloatingEasterEgg: View {
    let message: String
    let index: Int
    let screenWidth: CGFloat
    
    @State private var opacity: Double = 0
    @State private var floatOffset: CGFloat = 0
    
    private var position: (x: CGFloat, y: CGFloat) {
        let offset = screenWidth * 0.28
        let positions: [(CGFloat, CGFloat)] = [
            (-offset, -280),
            (offset, -240),
            (-offset - 10, -120),
            (offset + 10, -90),
            (0, -350)
        ]
        return positions[index % positions.count]
    }
    
    private var rotation: Double {
        let rotations: [Double] = [-12, 8, -6, 10, -8]
        return rotations[index % rotations.count]
    }

    var body: some View {
        Text(message)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(.noorGold.opacity(0.6))
            .multilineTextAlignment(.center)
            .fixedSize()
            .rotationEffect(.degrees(rotation))
            .offset(x: position.x, y: position.y + floatOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8).delay(Double(index) * 0.4)) {
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(Double(index) * 0.3)) {
                    floatOffset = index % 2 == 0 ? -8 : 8
                }
            }
    }
}

struct OnboardingView: View {
    @Binding var isActive: Bool
    @State private var name: String = ""
    @State private var showEasterEggConfirm = false
    @State private var showEasterEggMessage = false
    @State private var easterEggOpacity = 0.0
    @State private var easterEggScale = 0.8
    @State private var animateBlobs = false
    @State private var buttonShimmer: CGFloat = -200
    @State private var contentOpacity = 0.0
    
    @FocusState private var isInputFocused: Bool
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color.noorGold.opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 90)
                    .offset(x: animateBlobs ? -80 : -160, y: animateBlobs ? -120 : -200)
                
                Circle()
                    .fill(Color.orange.opacity(0.08))
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: animateBlobs ? 120 : 200, y: animateBlobs ? 180 : 300)
            }
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateBlobs)
            
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 40) {
                            Spacer()
                                .frame(height: geometry.size.height * 0.08)
                            
                            VStack(spacing: 16) {
                                IntroSpeechBubble(
                                    message: languageManager.currentLanguage == .english ? "Salam! I'm Noorine." : "Salam ! Je m'appelle Noorine.",
                                    detail: languageManager.currentLanguage == .english ? "I'll be your guide to learn Arabic." : "Je serai ton guide pour apprendre l'arabe.",
                                    accentColor: .noorGold
                                )
                                
                                EmotionalMascot(mood: .encouraging, size: 120, showAura: false)
                            }
                            
                            VStack(spacing: 30) {
                                Text(languageManager.currentLanguage == .english ? "What is your name?" : "Comment t'appelles-tu ?")
                                    .font(.system(size: 26, weight: .bold, design: .serif))
                                    .foregroundColor(.noorText)
                                
                                TextField(languageManager.currentLanguage == .english ? "Your name" : "Ton prénom", text: $name)
                                    .focused($isInputFocused)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(.noorText)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 12)
                                    .background(
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .fill(isInputFocused ? Color.noorGold : Color.noorSecondary.opacity(0.3))
                                                .frame(height: isInputFocused ? 2 : 1)
                                        }
                                    )
                                    .padding(.horizontal, 40)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        isInputFocused = false
                                    }
                                    .onChange(of: isInputFocused) { _, isFocused in
                                        if isFocused {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    proxy.scrollTo("continueButton", anchor: .center)
                                                }
                                            }
                                        }
                                    }
                            }
                            
                            ZStack {
                                if showEasterEggConfirm {
                                    VStack(spacing: 20) {
                                        Text("Dhilly ? 👀")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(.noorGold)
                                        
                                        HStack(spacing: 20) {
                                            Button(action: {
                                                isInputFocused = false
                                                withAnimation(.easeInOut) {
                                                    showEasterEggConfirm = false
                                                }
                                            }) {
                                                Text("Non")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.noorSecondary)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 14)
                                                    .background(Color(.secondarySystemGroupedBackground))
                                                    .cornerRadius(20)
                                            }
                                            
                                            Button(action: {
                                                isInputFocused = false
                                                FeedbackManager.shared.tapMedium()
                                                dataManager.setDhilly()
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                                    showEasterEggConfirm = false
                                                    showEasterEggMessage = true
                                                    easterEggOpacity = 1.0
                                                    easterEggScale = 1.0
                                                }
                                            }) {
                                                Text("Oui c'est moi !")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.noorDark)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 14)
                                                    .background(Color.noorGold)
                                                    .cornerRadius(20)
                                                    .shadow(color: .noorGold.opacity(0.3), radius: 8, y: 4)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 40)
                                    .transition(.opacity)
                                    
                                } else if !showEasterEggMessage {
                                    Button(action: completeOnboarding) {
                                        HStack(spacing: 12) {
                                            Text(languageManager.currentLanguage == .english ? "Start the adventure" : "Commencer l'aventure")
                                            Image(systemName: "arrow.right")
                                        }
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.noorDark)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .fill(name.isEmpty ? Color.gray.opacity(0.3) : Color.noorGold)
                                                
                                                if !name.isEmpty {
                                                    RoundedRectangle(cornerRadius: 30)
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [.clear, .white.opacity(0.3), .clear],
                                                                startPoint: .leading, endPoint: .trailing
                                                            )
                                                        )
                                                        .offset(x: buttonShimmer)
                                                        .mask(RoundedRectangle(cornerRadius: 30))
                                                }
                                            }
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: name.isEmpty ? .clear : .noorGold.opacity(0.4), radius: 12, y: 6)
                                    }
                                    .disabled(name.isEmpty)
                                    .padding(.horizontal, 40)
                                    .transition(.opacity)
                                }
                            }
                            .frame(height: 100)
                            .id("continueButton")
                            
                            Spacer()
                                .frame(height: isInputFocused ? 250 : 100)
                        }
                        .frame(minHeight: geometry.size.height)
                        .opacity(contentOpacity)
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
            
            if showEasterEggMessage {
                easterEggOverlay
            }
        }
        .onAppear {
            animateBlobs = true
            
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                contentOpacity = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                buttonShimmer = 400
            }
        }
    }
    
    private var easterEggOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)
                    
                    VStack(spacing: 8) {
                        NoorineFace(size: 100)
                        
                        Text("(oui c'est toi la mascotte)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.noorGold.opacity(0.6))
                    }
                    
                    Text("بِسْمِ ٱللّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.noorGold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        Text("Laurine !")
                            .font(.system(size: 32, weight: .black, design: .serif))
                            .foregroundStyle(
                                LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("Cette application a été conçue pour toi de base lol parce que tu le mérites.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Text("(et ce message ne s'affiche que pour toi, parce que je suis trop malin)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.noorGold.opacity(0.6))
                            .multilineTextAlignment(.center)
                        
                        Text("Tu es une fille belle (oui j'insiste meme par appli), intelligente, gentille, et sûrement appréciée d'Allah سُبْحَانَهُ وَتَعَالَىٰ.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Divider()
                            .background(Color.noorGold.opacity(0.3))
                            .padding(.horizontal, 40)
                        
                        Text("Je te souhaite tout le meilleur du monde. Pardonne-moi pour mes manquements.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                        
                        Text("J'espère que tu apprendras plein de choses en arabe avec cette appli. C'est un petit cadeau pour ce RAMADAN.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.noorGold.opacity(0.4))
                                .frame(width: 40, height: 1)
                            Text("Sny")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(.noorGold.opacity(0.7))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        isInputFocused = false
                        dataManager.updateUserName(name)
                        withAnimation {
                            isActive = false
                        }
                    }) {
                        Text("Bismillah, on commence")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(30)
                            .shadow(color: .noorGold.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    
                    Spacer().frame(height: 60)
                }
            }
        }
        .opacity(easterEggOpacity)
        .scaleEffect(easterEggScale)
        .transition(.opacity)
    }
    
    private func completeOnboarding() {
        isInputFocused = false
        guard !name.isEmpty else { return }
        
        if name.lowercased().trimmingCharacters(in: .whitespaces) == "laurine" {
            withAnimation(.easeInOut) {
                showEasterEggConfirm = true
            }
            return
        }
        
        dataManager.updateUserName(name)
        
        withAnimation {
            isActive = false
        }
    }
}

struct IntroSpeechBubble: View {
    let message: LocalizedStringKey
    let detail: LocalizedStringKey
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .center, spacing: 6) {
                Text(message)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(detail)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.95))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
            .zIndex(1)
            
            IntroSpeechBubbleTail()
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.95))
                .frame(width: 24, height: 14)
                .overlay(
                    IntroSpeechBubbleTail()
                        .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                        .mask(Rectangle().padding(.bottom, -2))
                )
                .offset(y: -2)
                .zIndex(0)
        }
        .padding(.horizontal, 30)
    }
}

struct IntroSpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}