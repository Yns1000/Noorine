import ActivityKit
import WidgetKit
import SwiftUI

struct NoorineWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoorineLessonAttributes.self) { context in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.2))
                    Text(WidgetLocalization.lessonHeader)
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    contentView(for: context.state.currentLetterArabic)
                        .font(.system(size: 36, weight: .bold))
                        .frame(width: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.lessonTitle)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        ProgressView(value: context.state.progress)
                            .tint(Color(red: 0.85, green: 0.65, blue: 0.2))
                            .scaleEffect(y: 1.5)

                        HStack {
                            Text(context.state.currentLetterName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("+\(context.state.xpEarned) XP")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                        }
                    }
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(UIColor.secondarySystemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    contentView(for: context.state.currentLetterArabic)
                        .font(.system(size: 28, weight: .bold))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(context.state.xpEarned) XP")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        Text(context.state.lessonTitle)
                            .font(.system(size: 13, weight: .semibold))

                        ProgressView(value: context.state.progress)
                            .tint(Color(red: 0.85, green: 0.65, blue: 0.2))
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                contentView(for: context.state.currentLetterArabic)
                    .font(.system(size: 16, weight: .bold))
            } compactTrailing: {
                Text("+\(context.state.xpEarned)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
            } minimal: {
                contentView(for: context.state.currentLetterArabic)
                    .font(.system(size: 14, weight: .bold))
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text(WidgetLocalization.streakHeader)
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(WidgetLocalization.protectStreak)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(context.state.streakLength)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.orange)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("\(context.state.streakLength)")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                    .padding(.leading)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                        .font(.body.monospacedDigit())
                        .foregroundColor(.red)
                        .padding(.trailing)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text(WidgetLocalization.saveFlame)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                }
                
            } compactLeading: {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(context.state.streakLength)")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                }
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                    .multilineTextAlignment(.trailing)
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.red)
                    .frame(maxWidth: 64)
            } minimal: {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }
}
