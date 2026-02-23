import ActivityKit
import WidgetKit
import SwiftUI

private let noorGold = Color(red: 0.85, green: 0.65, blue: 0.2)
private let noorGoldStrong = Color(red: 0.72, green: 0.52, blue: 0.08)

struct NoorineWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoorineLessonAttributes.self) { context in
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(noorGold.opacity(0.15))
                            .frame(width: 56, height: 56)
                        
                        contentView(for: context.state.currentLetterArabic)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(noorGoldStrong)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.lessonTitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(context.state.currentLetterName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("+\(context.state.xpEarned) XP")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(noorGold.opacity(0.15))
                    .foregroundColor(noorGoldStrong)
                    .clipShape(Capsule())
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(LinearGradient(
                                colors: [noorGold, noorGoldStrong],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, geo.size.width * CGFloat(context.state.progress)), height: 10)
                    }
                }
                .frame(height: 10)
            }
            .padding(20)
            .activityBackgroundTint(Color(.systemBackground).opacity(0.95))
            .activitySystemActionForegroundColor(noorGold)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ZStack {
                        Circle()
                            .fill(noorGold.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        contentView(for: context.state.currentLetterArabic)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(noorGold)
                    }
                    .padding(.leading, 4)
                    .padding(.top, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(noorGold)
                        Text("+\(context.state.xpEarned) XP")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 4)
                    .padding(.top, 12)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        HStack {
                            Text(context.state.lessonTitle)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(context.state.progress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(noorGold)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(noorGold)
                                    .frame(width: max(0, geo.size.width * CGFloat(context.state.progress)), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                contentView(for: context.state.currentLetterArabic)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(noorGold)
            } compactTrailing: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(noorGold)
            } minimal: {
                contentView(for: context.state.currentLetterArabic)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(noorGold)
            }
            .widgetURL(URL(string: "noorine://lesson?level=\(context.attributes.levelNumber)"))
        }
    }

    @ViewBuilder
    private func contentView(for text: String) -> some View {
        if text.hasPrefix("icon:") {
            let iconName = String(text.dropFirst(5))
            Image(systemName: iconName)
        } else {
            Text(text)
        }
    }
}

struct NoorineStreakLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoorineStreakAttributes.self) { context in
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(WidgetLocalization.protectStreak)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
                }

                Spacer()

                VStack(spacing: -2) {
                    Text("\(context.state.streakLength)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text(WidgetLocalization.streakHeader.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
            .padding(20)
            .activityBackgroundTint(Color(.systemBackground).opacity(0.95))
            .activitySystemActionForegroundColor(Color.orange)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                    .padding(.leading, 4)
                    .padding(.top, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.streakLength)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        Text(WidgetLocalization.streakHeader.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(WidgetLocalization.saveFlame)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                            Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }

            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                    Text("\(context.state.streakLength)")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                }
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.red)
                    .frame(maxWidth: 64)
            } minimal: {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
    }
}