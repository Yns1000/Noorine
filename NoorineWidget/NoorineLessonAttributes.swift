import Foundation
import ActivityKit

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

struct NoorineStreakAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var streakLength: Int
        var deadline: Date
    }
}
