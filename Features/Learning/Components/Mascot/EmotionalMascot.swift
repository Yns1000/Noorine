import SwiftUI

struct EmotionalMascot: View {
    enum Mood {
        case neutral
        case happy
        case sad
        case thinking
        case celebrating
        case encouraging
        case surprised
    }

    let mood: Mood
    let size: CGFloat
    var showAura: Bool = true

    @State private var isBlinking = false
    @State private var bounceOffset: CGFloat = 0
    @State private var breatheScale: CGFloat = 1.0
    @State private var swayOffset: CGFloat = 0
    @State private var winkLeft = false
    @State private var starRotation: Double = 0
    @State private var surpriseScale: CGFloat = 1.0
    @State private var showParticles = false

    var body: some View {
        ZStack {
            if showAura {
                NoorineAura(size: size)
            }

            if mood == .celebrating && showParticles {
                CelebrationParticles(size: size)
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
                        leftEyeView
                        rightEyeView
                    }
                    .offset(y: mood == .sad ? -size * 0.08 : -size * 0.12)
                    .scaleEffect(mood == .surprised ? surpriseScale : 1.0)

                    mouthView
                        .offset(y: mouthOffsetY)

                    Circle()
                        .fill(Color(red: 0.75, green: 0.35, blue: 0.1))
                        .frame(width: size * 0.07, height: size * 0.07)
                        .offset(x: -size * 0.24, y: size * 0.04)
                }
            }
            .offset(x: swayOffset, y: bounceOffset)
            .scaleEffect(breatheScale)
        }
        .onAppear {
            startBlinking()
            startBreathing()
            applyMoodAnimation(mood)
        }
        .onChange(of: mood) { _, newMood in
            applyMoodAnimation(newMood)
        }
    }

    private var moodColor: Color {
        switch mood {
        case .neutral: return .noorGold
        case .happy: return .noorGold
        case .sad: return .orange.opacity(0.7)
        case .thinking: return .noorGold.opacity(0.8)
        case .celebrating: return .noorGold
        case .encouraging: return .noorGold.opacity(0.9)
        case .surprised: return .noorGold
        }
    }

    private var mouthOffsetY: CGFloat {
        switch mood {
        case .sad: return size * 0.22
        case .happy, .celebrating: return size * 0.025
        case .surprised: return size * 0.12
        default: return size * 0.08
        }
    }

    @ViewBuilder
    private var leftEyeView: some View {
        eyeContent(isLeft: true)
    }

    @ViewBuilder
    private var rightEyeView: some View {
        eyeContent(isLeft: false)
    }

    @ViewBuilder
    private func eyeContent(isLeft: Bool) -> some View {
        switch mood {
        case .celebrating:
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.1))
                .foregroundColor(.white)
                .rotationEffect(.degrees(starRotation))
        case .surprised:
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.12, height: size * 0.12)
                .overlay(
                    Circle()
                        .fill(Color.noorDark)
                        .frame(width: size * 0.05, height: size * 0.05)
                )
        case .encouraging:
            if isLeft && winkLeft {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: size * 0.09, height: size * 0.02)
            } else {
                normalEye
            }
        case .sad:
            Ellipse()
                .frame(width: size * 0.08, height: size * 0.06)
                .foregroundColor(Color.white.opacity(0.9))
        default:
            normalEye
        }
    }

    @ViewBuilder
    private var normalEye: some View {
        Ellipse()
            .frame(width: size * 0.075, height: size * 0.1)
            .foregroundColor(Color.white.opacity(0.9))
            .scaleEffect(y: isBlinking ? 0.1 : 1.0)
    }

    @ViewBuilder
    private var mouthView: some View {
        switch mood {
        case .neutral, .thinking:
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.25, height: 2)
        case .happy, .encouraging:
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.42, height: size * 0.42)
        case .celebrating:
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: size * 0.2, height: size * 0.12)
        case .sad:
            Circle()
                .trim(from: 0.6, to: 0.9)
                .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.35, height: size * 0.35)
        case .surprised:
            Circle()
                .stroke(Color.white.opacity(0.85), lineWidth: size * 0.02)
                .frame(width: size * 0.12, height: size * 0.12)
        }
    }

    private func applyMoodAnimation(_ newMood: Mood) {
        switch newMood {
        case .happy:
            startBouncing()
        case .celebrating:
            startCelebrating()
        case .encouraging:
            startSwaying()
            startWinking()
        case .surprised:
            startSurprised()
        default:
            resetAnimations()
        }
    }

    private func startBlinking() {
        guard mood != .sad && mood != .celebrating else { return }

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

    private func startBreathing() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            breatheScale = 1.02
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

    private func startCelebrating() {
        showParticles = true
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            starRotation = 360
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            bounceOffset = -14
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bounceOffset = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showParticles = false
        }
    }

    private func startSwaying() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            swayOffset = 4
        }
    }

    private func startWinking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            winkLeft = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                winkLeft = false
            }
        }
    }

    private func startSurprised() {
        surpriseScale = 1.0
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            surpriseScale = 1.35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                surpriseScale = 1.0
            }
        }
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            bounceOffset = -5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceOffset = 0
            }
        }
    }

    private func resetAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            swayOffset = 0
            bounceOffset = 0
            surpriseScale = 1.0
        }
        winkLeft = false
        showParticles = false
        starRotation = 0
    }
}

private struct CelebrationParticles: View {
    let size: CGFloat

    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, rotation: Double, scale: CGFloat, opacity: Double)] = []
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { p in
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.06))
                    .foregroundColor(.noorGold)
                    .rotationEffect(.degrees(animate ? p.rotation + 180 : p.rotation))
                    .scaleEffect(animate ? 0.2 : p.scale)
                    .opacity(animate ? 0 : p.opacity)
                    .offset(
                        x: animate ? p.x * 2.5 : p.x * 0.3,
                        y: animate ? p.y * 2.5 : p.y * 0.3
                    )
            }
        }
        .onAppear {
            particles = (0..<8).map { i in
                let angle = Double(i) * .pi / 4
                return (
                    id: i,
                    x: CGFloat(cos(angle)) * size * 0.3,
                    y: CGFloat(sin(angle)) * size * 0.3,
                    rotation: Double.random(in: 0...360),
                    scale: CGFloat.random(in: 0.6...1.2),
                    opacity: Double.random(in: 0.7...1.0)
                )
            }
            withAnimation(.easeOut(duration: 1.2)) {
                animate = true
            }
        }
    }
}
