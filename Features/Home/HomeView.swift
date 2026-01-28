import SwiftUI

// MARK: - Layout Configuration
struct LayoutConfig {
    static let buttonSize: CGFloat = 76
    static let verticalSpacing: CGFloat = 140
    static let amplitude: CGFloat = 70
    static let waveFrequency: Double = 0.85
    static let headerHeight: CGFloat = 90
}

// MARK: - Main Home View
struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLevel: LevelProgress?
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        PathLayer(levels: dataManager.levels)
                            .frame(width: UIScreen.main.bounds.width)
                            .frame(height: CGFloat(dataManager.levels.count) * LayoutConfig.verticalSpacing + 50)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(dataManager.levels.enumerated()), id: \.element.levelNumber) { index, level in
                                LevelNode(
                                    levelNumber: level.levelNumber,
                                    title: level.title,
                                    subtitle: level.subtitle,
                                    state: dataManager.levelState(for: level.levelNumber),
                                    index: index
                                )
                                .frame(height: LayoutConfig.verticalSpacing)
                                .onTapGesture {
                                    let state = dataManager.levelState(for: level.levelNumber)
                                    if state != .locked {
                                        selectedLevel = level
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .safeAreaInset(edge: .top) {
                HomeHeader(
                    xp: dataManager.userProgress?.xpTotal ?? 0,
                    streak: dataManager.userProgress?.streakDays ?? 0
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedLevel) { level in
                LevelDetailView(levelNumber: level.levelNumber, title: level.title)
            }
        }
    }
}

// MARK: - Premium Background
struct PremiumBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.noorGold.opacity(0.12), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animateGradient ? 50 : -50, y: animateGradient ? -100 : -50)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.06), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animateGradient ? -80 : -30, y: animateGradient ? 400 : 500)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Path Layer
struct PathLayer: View {
    let levels: [LevelProgress]
    
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            
            for index in 0..<(levels.count - 1) {
                let isPathUnlocked = levels[index].isCompleted
                
                let startY = (LayoutConfig.verticalSpacing / 2) + (CGFloat(index) * LayoutConfig.verticalSpacing)
                let startX = centerX + (CGFloat(sin(Double(index) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude)
                
                let endY = startY + LayoutConfig.verticalSpacing
                let endX = centerX + (CGFloat(sin(Double(index + 1) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude)
                
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                
                let controlY = (startY + endY) / 2
                path.addCurve(
                    to: CGPoint(x: endX, y: endY),
                    control1: CGPoint(x: startX, y: controlY),
                    control2: CGPoint(x: endX, y: controlY)
                )
                
                if isPathUnlocked {
                    context.stroke(
                        path,
                        with: .color(Color.noorGold),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                    )
                    context.stroke(
                        path,
                        with: .color(Color.noorGold.opacity(0.3)),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                    )
                } else {
                    context.stroke(
                        path,
                        with: .color(Color.noorSecondary.opacity(0.3)),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [10, 14])
                    )
                }
            }
        }
    }
}

// MARK: - Level Node
struct LevelNode: View {
    let levelNumber: Int
    let title: String
    let subtitle: String
    let state: LevelState
    let index: Int
    
    var xOffset: CGFloat {
        CGFloat(sin(Double(index) * LayoutConfig.waveFrequency)) * LayoutConfig.amplitude
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.noorBackground)
                    .frame(width: LayoutConfig.buttonSize + 20, height: LayoutConfig.buttonSize + 20)
                
                if state == .current {
                    CurrentLevelButton()
                } else {
                    StandardLevelButton(state: state)
                }
                
                LevelInfoCard(title: title, subtitle: subtitle, isCurrent: state == .current)
                    .offset(y: state == .current ? 80 : 68)
            }
            .offset(x: xOffset)
            
            Spacer()
        }
    }
}

// MARK: - Current Level Button
struct CurrentLevelButton: View {
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.noorGold.opacity(0.3), lineWidth: 3)
                .frame(width: 110, height: 110)
                .scaleEffect(pulseScale)
                .opacity(2 - pulseScale)
            
            NoorineMascot()
                .frame(width: 95, height: 95)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                pulseScale = 1.4
            }
        }
    }
}

// MARK: - Standard Level Button
struct StandardLevelButton: View {
    let state: LevelState
    
    var iconName: String {
        switch state {
        case .locked: return "lock.fill"
        case .completed: return "checkmark"
        case .current: return ""
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(state == .completed ? Color.noorGold.opacity(0.4) : Color.black.opacity(0.1))
                .frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize)
                .offset(y: 5)
            
            Circle()
                .fill(
                    state == .completed
                        ? LinearGradient(
                            colors: [Color.noorGold, Color.noorGold.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.noorSecondary.opacity(0.3), Color.noorSecondary.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .frame(width: LayoutConfig.buttonSize, height: LayoutConfig.buttonSize)
                .overlay(
                    Circle()
                        .stroke(
                            state == .completed ? Color.white.opacity(0.5) : Color.noorSecondary.opacity(0.2),
                            lineWidth: 2
                        )
                )
            
            Image(systemName: iconName)
                .font(.system(size: state == .completed ? 26 : 22, weight: .bold))
                .foregroundColor(state == .completed ? .white : Color.noorSecondary.opacity(0.5))
        }
    }
}

// MARK: - Level Info Card
struct LevelInfoCard: View {
    let title: String
    let subtitle: String
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color.noorText)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color.noorSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        )
    }
}

// MARK: - Header
struct HomeHeader: View {
    let xp: Int
    let streak: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                StatBadge(icon: "flame.fill", value: "\(streak)", iconColor: .orange)
                
                Spacer()
                
                StatBadge(icon: "star.fill", value: "\(xp)", iconColor: .noorGold)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 2) {
                Text("NOORINE")
                    .font(.system(size: 22, weight: .black, design: .serif))
                    .tracking(4)
                    .foregroundColor(Color.noorText)
                
                Text("نورين")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.noorGold)
            }
            .padding(.bottom, 4)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .background(
            Color.noorBackground.opacity(0.95)
        )
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.noorGold.opacity(0.3), Color.noorGold.opacity(0.1), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Stat Badge Component
struct StatBadge: View {
    let icon: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color.noorText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
        )
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(DataManager.shared)
}
