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
                        
                        Text("L'APPRENTISSAGE ÉCLAIRÉ")
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
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}
