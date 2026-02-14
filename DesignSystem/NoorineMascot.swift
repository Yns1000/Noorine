import SwiftUI
import Foundation

struct NoorineAura: View {
    let size: CGFloat
    @State private var rotation = 0.0
    
    var body: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(colors: [.noorGold.opacity(0), .noorGold.opacity(0.5), .noorGold.opacity(0)]),
                    center: .center
                ),
                lineWidth: 1.5
            )
            .frame(width: size * 3.25, height: size * 3.25)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct NoorineFace: View {
    let size: CGFloat
    var mood: EmotionalMascot.Mood = .happy
    var isBlinking: Bool = false
    
    var body: some View {
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
}

struct NoorineMascot: View {
    var size: CGFloat = 80
    var showAura: Bool = true
    @State private var isBlinking = false
    
    var body: some View {
        ZStack {
            if showAura {
                NoorineAura(size: size)
            }
            NoorineFace(size: size, isBlinking: isBlinking)
        }
        .onAppear {
            startBlinking()
        }
    }
    
    private func startBlinking() {
        let randomInterval = Double.random(in: 2.0...4.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomInterval) {
            withAnimation(.easeInOut(duration: 0.15)) {
                self.isBlinking = true 
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) { 
                    self.isBlinking = false 
                }
                startBlinking()
            }
        }
    }
}


enum IconStyle {
    case light, dark, tinted
}

struct ArabicBackground: View {
    let style: IconStyle
    let letters = ["أ", "ب", "ت", "ث", "ج", "ح", "خ", "د", "ذ", "ر", "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق", "ك", "ل", "م", "ن", "ه", "و", "ي"]
    
    var body: some View {
        ZStack {
            ForEach(0..<6) { row in
                ForEach(0..<6) { col in
                    let x = CGFloat(col) * 180 + 60
                    let y = CGFloat(row) * 180 + 60
                    
                    let dist = sqrt(pow(x - 512, 2) + pow(y - 512, 2))
                    
                    if dist > 380 {
                        Text(letters[(row * 6 + col) % letters.count])
                            .font(.system(size: CGFloat((row + col) % 2 == 0 ? 90 : 60), weight: .black, design: .serif))
                            .foregroundColor(letterColor.opacity(0.18))
                            .rotationEffect(.degrees(Double(row * 40 + col * 20)))
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
    
    private var letterColor: Color {
        switch style {
        case .light: return .black
        case .dark: return .white
        case .tinted: return .white
        }
    }
}

struct MascotExportView: View {
    let style: IconStyle
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ArabicBackground(style: style)
            
            if style == .tinted {
                TintedMascotFace(size: 850)
            } else if style == .dark {
                NoorineFace(size: 800)
                    .shadow(color: .noorGold.opacity(0.8), radius: 100)
            } else {
                NoorineFace(size: 800)
            }
        }
        .frame(width: 1024, height: 1024)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .light: return Color(red: 0.98, green: 0.97, blue: 0.94)
        case .dark: return Color(red: 0.02, green: 0.02, blue: 0.05)
        case .tinted: return .black
        }
    }
}

struct TintedMascotFace: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white, Color(white: 0.85)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
            
            Circle()
                .stroke(Color(white: 0.95), lineWidth: size * 0.015)
                .frame(width: size - 4, height: size - 4)
            
            HStack(spacing: size * 0.2) {
                Ellipse()
                    .fill(Color.black)
                    .frame(width: size * 0.075, height: size * 0.1)
                Ellipse()
                    .fill(Color.black)
                    .frame(width: size * 0.075, height: size * 0.1)
            }
            .offset(y: -size * 0.12)
            
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.black, style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(y: size * 0.025)
            
            Circle()
                .fill(Color(white: 0.25))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: -size * 0.24, y: size * 0.04)
        }
    }
}

#Preview {
    ZStack {
        Color.noorBackground.ignoresSafeArea()
        VStack(spacing: 50) {
            EmotionalMascot(mood: .happy, size: 80)
            NoorineMascot()
        }
    }
}
