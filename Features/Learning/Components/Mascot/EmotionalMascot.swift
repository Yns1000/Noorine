import SwiftUI

struct EmotionalMascot: View {
    enum Mood {
        case neutral
        case happy
        case sad
        case thinking
    }
    
    let mood: Mood
    let size: CGFloat
    var showAura: Bool = true
    
    @State private var isBlinking = false
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if showAura {
                NoorineAura(size: size)
            }
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [moodColor, moodColor.opacity(0.6)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: moodColor.opacity(0.5), radius: size * 0.25)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: 2).padding(2)
                    )
                
                Group {
                    HStack(spacing: size * 0.2) {
                        eyeView
                        eyeView
                    }
                    .offset(y: mood == .sad ? -size * 0.08 : -size * 0.12)
                    
                    mouthView
                        .offset(y: mood == .sad ? size * 0.22 : (mood == .happy ? size * 0.025 : size * 0.08))
                    
                    Circle()
                        .fill(Color(red: 0.75, green: 0.35, blue: 0.1))
                        .frame(width: size * 0.07, height: size * 0.07)
                        .offset(x: -size * 0.24, y: size * 0.04)
                }
            }
            .offset(y: bounceOffset)
        }
        .onAppear {
            startBlinking()
            if mood == .happy {
                startBouncing()
            }
        }
        .onChange(of: mood) { newMood in
            if newMood == .happy {
                startBouncing()
            }
        }
    }
    
    private var moodColor: Color {
        switch mood {
        case .neutral: return .noorGold
        case .happy: return .noorGold
        case .sad: return .orange.opacity(0.7)
        case .thinking: return .noorGold.opacity(0.8)
        }
    }
    
    @ViewBuilder
    private var eyeView: some View {
        Group {
            if mood == .sad {
                Ellipse()
                    .frame(width: size * 0.08, height: size * 0.06)
                    .foregroundColor(Color.white.opacity(0.9))
            } else {
                Ellipse()
                    .frame(width: size * 0.075, height: size * 0.1)
                    .foregroundColor(Color.white.opacity(0.9))
                    .scaleEffect(y: isBlinking ? 0.1 : 1.0)
            }
        }
    }
    
    @ViewBuilder
    private var mouthView: some View {
        switch mood {
        case .neutral, .thinking:
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.25, height: 2)
        case .happy:
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.42, height: size * 0.42)
        case .sad:
            Circle()
                .trim(from: 0.6, to: 0.9)
                .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.35, height: size * 0.35)
        }
    }
    
    private func startBlinking() {
        guard mood != .sad else { return }
        
        let randomInterval = Double.random(in: 2.0...4.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomInterval) {
            withAnimation(.easeInOut(duration: 0.15)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBlinking = false
                }
                startBlinking()
            }
        }
    }
    
    private func startBouncing() {
        withAnimation(.easeInOut(duration: 0.3)) {
            bounceOffset = -8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                bounceOffset = 0
            }
        }
    }
}
