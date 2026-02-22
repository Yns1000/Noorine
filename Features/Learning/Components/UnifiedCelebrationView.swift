import SwiftUI

enum CelebrationType {
    case letterMastery
    case levelComplete
    case wordAssembly
    case sentenceBuilder
    case speedQuiz
    case dailyChallenge
    case dictation
    case phraseLevel
    case vowelMastery
    case checkpoint

    var accentColor: Color {
        switch self {
        case .speedQuiz: return .orange
        case .dailyChallenge: return .noorGold
        default: return .noorGold
        }
    }
}

struct CelebrationData {
    let type: CelebrationType
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var score: Int?
    var total: Int?
    var xpEarned: Int
    var showStars: Bool
    var maxCombo: Int?
    
    init(
        type: CelebrationType,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        score: Int? = nil,
        total: Int? = nil,
        xpEarned: Int = 10,
        showStars: Bool = true,
        maxCombo: Int? = nil
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.score = score
        self.total = total
        self.xpEarned = xpEarned
        self.showStars = showStars
        self.maxCombo = maxCombo
    }
    
    var starCount: Int {
        guard let score = score, let total = total, total > 0 else { return 3 }
        let ratio = Double(score) / Double(total)
        if ratio >= 1.0 { return 3 }
        if ratio >= 0.5 { return 2 }
        return 1
    }
}

struct UnifiedCelebrationView: View {
    let data: CelebrationData
    let onDismiss: () -> Void
    var onNext: (() -> Void)? = nil
    var nextButtonTitle: LocalizedStringKey? = nil
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var starsAnimated = false
    @State private var mascotBounce: CGFloat = 0
    @State private var showConfetti = false
    @State private var xpCountUp: Int = 0
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.14, blue: 0.18), Color(red: 0.08, green: 0.09, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showConfetti {
                ConfettiParticles()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                mascotSection
                
                Spacer().frame(height: 32)
                
                textSection
                
                Spacer().frame(height: 24)
                
                if data.showStars {
                    starsSection
                }
                
                Spacer().frame(height: 28)
                
                xpCard
                
                if let combo = data.maxCombo, combo >= 3 {
                    comboBadge(combo)
                        .padding(.top, 16)
                }
                
                Spacer()
                
                continueButton
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3)) {
                    showConfetti = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                starsAnimated = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.3)) {
                mascotBounce = -8
            }
            animateXPCount()
        }
    }
    
    private func animateXPCount() {
        let target = data.xpEarned
        let duration = 0.8
        let steps = 20
        let interval = duration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                xpCountUp = Int(Double(target) * Double(i) / Double(steps))
            }
        }
    }
    
    private var mascotSection: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.noorGold.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                NoorineMascot()
                    .frame(width: 140, height: 140)
                    .offset(y: mascotBounce)
            }
        }
    }
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text(data.title)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var starsSection: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < data.starCount ? "star.fill" : "star")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(
                        i < data.starCount
                            ? LinearGradient(colors: [.noorGold, .orange], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(starsAnimated && i < data.starCount ? 1.2 : 0.8)
                    .rotationEffect(.degrees(starsAnimated && i < data.starCount ? 0 : -15))
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.5)
                            .delay(Double(i) * 0.15),
                        value: starsAnimated
                    )
            }
        }
    }
    
    private var xpCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.noorGold, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                
                Text("XP")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isEnglish ? "Experience earned" : "Expérience gagnée")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("+\(xpCountUp)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
                    )
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(colors: [.noorGold.opacity(0.4), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                )
        )
        .padding(.horizontal, 32)
    }
    
    private func comboBadge(_ combo: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text(isEnglish ? "Max combo: x\(combo)" : "Combo max : x\(combo)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(20)
    }
    
    private var continueButton: some View {
        Button(action: {
            if let onNext = onNext {
                onNext()
            } else {
                onDismiss()
            }
        }) {
            HStack(spacing: 10) {
                Text(nextButtonTitle ?? LocalizedStringKey(isEnglish ? "Continue" : "Continuer"))
                    .font(.system(size: 20, weight: .bold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.noorDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(colors: [.noorGold, .orange], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(30)
            .shadow(color: .noorGold.opacity(0.5), radius: 16, y: 8)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
}

struct ConfettiParticles: View {
    @State private var particles: [(id: Int, x: CGFloat, delay: Double)] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    ConfettiParticle(
                        startX: particle.x,
                        screenHeight: geo.size.height,
                        delay: particle.delay
                    )
                }
            }
        }
        .onAppear {
            particles = (0..<12).map { i in
                (id: i, x: CGFloat.random(in: 0.1...0.9), delay: Double.random(in: 0...0.4))
            }
        }
    }
}

struct ConfettiParticle: View {
    let startX: CGFloat
    let screenHeight: CGFloat
    let delay: Double
    
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    private let colors: [Color] = [.noorGold, .orange, .yellow, .white]
    
    var body: some View {
        GeometryReader { geo in
            Image(systemName: ["star.fill", "sparkle", "circle.fill"].randomElement()!)
                .font(.system(size: CGFloat.random(in: 8...16)))
                .foregroundColor(colors.randomElement()!)
                .position(x: geo.size.width * startX, y: yOffset)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 2.5).delay(delay)) {
                        yOffset = screenHeight + 50
                        rotation = Double.random(in: 180...540)
                    }
                    withAnimation(.easeIn(duration: 2).delay(delay + 1.5)) {
                        opacity = 0
                    }
                }
        }
    }
}

#Preview {
    UnifiedCelebrationView(
        data: CelebrationData(
            type: .letterMastery,
            title: "Bravo !",
            subtitle: "Tu as maîtrisé cette lettre",
            score: 4,
            total: 4,
            xpEarned: 10
        ),
        onDismiss: {},
        onNext: {},
        nextButtonTitle: "Lettre suivante"
    )
}
