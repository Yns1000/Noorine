import WidgetKit
import SwiftUI

struct WordOfDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordOfDayEntry {
        WordOfDayEntry(
            date: Date(),
            arabic: "كِتَاب",
            transliteration: "Kitab",
            translationFr: "Livre",
            translationEn: "Book"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WordOfDayEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordOfDayEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> WordOfDayEntry {
        WordOfDayEntry(
            date: Date(),
            arabic: SharedDataStore.wordOfDayArabic,
            transliteration: SharedDataStore.wordOfDayTransliteration,
            translationFr: SharedDataStore.wordOfDayTranslationFr,
            translationEn: SharedDataStore.wordOfDayTranslationEn
        )
    }
}

struct WordOfDayEntry: TimelineEntry {
    let date: Date
    let arabic: String
    let transliteration: String
    let translationFr: String
    let translationEn: String
}

struct WordOfDayWidgetView: View {
    var entry: WordOfDayEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            Text("✨ MOT DU JOUR")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(1)

            Text(entry.arabic)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(entry.transliteration)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(entry.translationFr)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.08),
                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(entry.arabic)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(entry.transliteration)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                    Text("MOT DU JOUR")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)
                }

                Text(entry.translationFr)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(entry.translationEn)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.06),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

struct WordOfDayWidget: Widget {
    let kind = "WordOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WordOfDayProvider()) { entry in
            WordOfDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Mot du Jour")
        .description("Un nouveau mot arabe chaque jour")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakDays: 7, todayXP: 35, xpTotal: 1250)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> StreakEntry {
        StreakEntry(
            date: Date(),
            streakDays: SharedDataStore.streakDays,
            todayXP: SharedDataStore.todayXP,
            xpTotal: SharedDataStore.xpTotal
        )
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let todayXP: Int
    let xpTotal: Int
}

struct StreakWidgetView: View {
    var entry: StreakEntry

    private var dailyGoalProgress: Double {
        min(Double(entry.todayXP) / 50.0, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text("SÉRIE")
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text("\(entry.streakDays)")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, Color(red: 0.85, green: 0.65, blue: 0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("jours")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.65, blue: 0.2), .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(CGFloat(dailyGoalProgress) * 80, 4), height: 4)
            }
            .frame(width: 80)

            Text("\(entry.todayXP)/50 XP")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            .orange.opacity(0.06),
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Série Noorine")
        .description("Ta série de jours et progression quotidienne")
        .supportedFamilies([.systemSmall])
    }
}


struct NoorineLiveActivityView: View {
    let state: NoorineLessonAttributes.ContentState

    var body: some View {
        HStack(spacing: 16) {
            Text(state.currentLetterArabic)
                .font(.system(size: 36, weight: .bold))
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(state.lessonTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                ProgressView(value: state.progress)
                    .tint(Color(red: 0.85, green: 0.65, blue: 0.2))
                    .scaleEffect(y: 1.5)

                HStack {
                    Text(state.currentLetterName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+\(state.xpEarned) XP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                }
            }
        }
        .padding(16)
    }
}

@main
struct NoorineWidgets: WidgetBundle {
    var body: some Widget {
        WordOfDayWidget()
        StreakWidget()
    }
}
