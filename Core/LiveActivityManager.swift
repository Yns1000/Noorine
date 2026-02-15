import Foundation
import ActivityKit
import SwiftUI

struct NoorineLessonAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentLetterName: String
        var currentLetterArabic: String
        var progress: Double
        var xpEarned: Int
        var lessonTitle: String
    }

    var levelNumber: Int
    var totalItems: Int
}

@available(iOS 16.2, *)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<NoorineLessonAttributes>? = nil

    func startLessonActivity(levelNumber: Int, totalItems: Int, lessonTitle: String) {
        print("LiveActivityManager: Requesting to start activity for \(lessonTitle)")
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("LiveActivityManager: Activities are NOT enabled in settings")
            return
        }

        let attributes = NoorineLessonAttributes(
            levelNumber: levelNumber,
            totalItems: totalItems
        )

        let initialState = NoorineLessonAttributes.ContentState(
            currentLetterName: "",
            currentLetterArabic: "icon:star.fill",
            progress: 0,
            xpEarned: 0,
            lessonTitle: lessonTitle
        )

        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("LiveActivityManager: Activity started successfully! ID: \(currentActivity?.id ?? "unknown")")
        } catch {
            print("LiveActivityManager: Start failed: \(error)")
        }
    }

    func updateProgress(
        letterName: String,
        letterArabic: String,
        progress: Double,
        xpEarned: Int,
        lessonTitle: String
    ) {
        Task {
            let updatedState = NoorineLessonAttributes.ContentState(
                currentLetterName: letterName,
                currentLetterArabic: letterArabic,
                progress: progress,
                xpEarned: xpEarned,
                lessonTitle: lessonTitle
            )
            let content = ActivityContent(state: updatedState, staleDate: nil)
            await currentActivity?.update(content)
        }
    }

    func endLessonActivity(xpEarned: Int) {
        Task {
            let finalState = NoorineLessonAttributes.ContentState(
                currentLetterName: "Terminé !",
                currentLetterArabic: "icon:checkmark.circle.fill",
                progress: 1.0,
                xpEarned: xpEarned,
                lessonTitle: "Leçon terminée"
            )
            let content = ActivityContent(state: finalState, staleDate: nil)
            await currentActivity?.end(content, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }

    func cancelActivity() {
        Task {
            let finalState = NoorineLessonAttributes.ContentState(
                currentLetterName: "Annulé",
                currentLetterArabic: "icon:xmark.circle.fill",
                progress: 0,
                xpEarned: 0,
                lessonTitle: "Leçon interrompue"
            )
            let content = ActivityContent(state: finalState, staleDate: nil)
            await currentActivity?.end(content, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
        
    private var streakActivity: Activity<NoorineStreakAttributes>? = nil

    func startStreakActivity(streak: Int, deadline: Date) {
        if streakActivity != nil { return }
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = NoorineStreakAttributes()
        let initialState = NoorineStreakAttributes.ContentState(
            streakLength: streak,
            deadline: deadline
        )
        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            streakActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("LiveActivityManager: Streak Activity started! ID: \(streakActivity?.id ?? "unknown")")
            
            Task {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                if streakActivity != nil {
                    print("LiveActivityManager: Auto-dismissing streak activity after 60s")
                    await streakActivity?.end(nil, dismissalPolicy: .immediate)
                    streakActivity = nil
                }
            }
        } catch {
            print("LiveActivityManager: Streak Start failed: \(error)")
        }
    }
    
    func stopStreakActivity() {
        Task {
            await streakActivity?.end(nil, dismissalPolicy: .immediate)
            streakActivity = nil
        }
    }
}

struct NoorineStreakAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var streakLength: Int
        var deadline: Date
    }
}
