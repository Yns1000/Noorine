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
    
    @State private var sunScale = 0.6
    @State private var contentOpacity = 0.0
    @State private var isTranslated = false
    @State private var arrowProgress: CGFloat = 0.0
    @State private var animateTopLeft = false
    @State private var animateBottomRight = false
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color.noorGold.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: animateTopLeft ? -100 : -200, y: animateTopLeft ? -150 : -250)
                
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 350, height: 350)
                    .blur(radius: 120)
                    .offset(x: animateBottomRight ? 150 : 250, y: animateBottomRight ? 200 : 350)
            }
            .animation(Animation.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animateTopLeft)
            
            VStack(spacing: 30) {
                Spacer()
                
                NoorineMascot()
                    .scaleEffect(sunScale)
                
                VStack(spacing: 5) {
                    Text("NOORINE")
                        .font(.system(size: 44, weight: .bold, design: .serif))
                        .foregroundColor(.noorText)
                        .tracking(8)
                        .padding(.bottom, 10)
                    
                    ZStack {
                        if isTranslated {
                            Text("التعلم المستنير")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.noorGold)
                                .shadow(color: .noorGold.opacity(0.4), radius: 10)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .offset(y: -35)
                        }
                        
                        if isTranslated {
                            HandDrawnArrow()
                                .trim(from: 0, to: arrowProgress)
                                .stroke(Color.noorText.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                                .frame(width: 20, height: 30)
                                .offset(y: -5)
                        }
                        
                        Text(languageManager.currentLanguage == .english ? "ENLIGHTENED LEARNING" : "L'APPRENTISSAGE ÉCLAIRÉ")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.noorText.opacity(0.5))
                            .tracking(4)
                            .offset(y: isTranslated ? 25 : 0)
                            .scaleEffect(isTranslated ? 0.9 : 1.0)
                    }
                    .frame(height: 80)
                }
                
                Spacer()
                Spacer()
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            animateTopLeft = true
            animateBottomRight = true
            
            FeedbackManager.shared.tapMedium()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) {
                    sunScale = 1.0
                    contentOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isTranslated = true
                }
                
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    arrowProgress = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation {
                    dataManager.isAppReady = true
                    isActive = true
                }
            }
        }
    }
}

struct OnboardingView: View {
    @Binding var isActive: Bool
    @State private var name: String = ""
    @State private var showMascot = false
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                if showMascot {
                    VStack(spacing: 20) {
                        EmotionalMascot(mood: .happy, size: 120)
                            .transition(.scale.combined(with: .opacity))
                        
                        TopSpeechBubble(
                            message: LocalizedStringKey(languageManager.currentLanguage == .english ? "Salam! I'm Noorine." : "Salam ! Je m'appelle Noorine."),
                            detail: LocalizedStringKey(languageManager.currentLanguage == .english ? "I'll be your guide to learn Arabic." : "Je serai ton guide pour apprendre l'arabe."),
                            accentColor: .noorGold
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                VStack(spacing: 24) {
                    Text(languageManager.currentLanguage == .english ? "What is your name?" : "Comment t'appelles-tu ?")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.noorText)
                    
                    TextField(languageManager.currentLanguage == .english ? "Your name" : "Ton prénom", text: $name)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        .padding(.horizontal, 40)
                        .submitLabel(.done)
                    
                    Button(action: completeOnboarding) {
                        HStack {
                            Text(languageManager.currentLanguage == .english ? "Start the adventure" : "Commencer l'aventure")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.noorDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(name.isEmpty ? Color.gray.opacity(0.3) : Color.noorGold)
                        .cornerRadius(30)
                        .shadow(color: name.isEmpty ? .clear : .noorGold.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal, 40)
                }
                .opacity(showMascot ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showMascot)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMascot = true
            }
        }
    }
    
    private func completeOnboarding() {
        guard !name.isEmpty else { return }
        
        dataManager.updateUserName(name)
        
        withAnimation {
            isActive = false
        }
    }
}

struct TopSpeechBubble: View {
    let message: LocalizedStringKey
    let detail: LocalizedStringKey
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .center, spacing: 4) {
                Text(message)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(detail)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.14, blue: 0.18))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            TopPointingTriangle()
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                .frame(width: 20, height: 12)
                .overlay(
                    TopPointingTriangle()
                        .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
                        .mask(Rectangle().padding(.top, -2)) 
                )
                .offset(y: -1)
        }
    }
}

struct TopPointingTriangle: Shape {
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
