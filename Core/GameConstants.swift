import Foundation

enum GameConstants {

    enum XP {
        static let letterMastered = 10
        static let allLettersCompleted = 50
        static let levelCompleted = 100
    }

    enum Mistakes {
        static let correctionsToMaster = 2
        static let masteredCleanupHours = 24
    }

    enum Checkpoint {
        static let afterLevels: [Int] = [4, 8, 12, 16]
        static let questionsCount = 6
        static let passThreshold = 4
        static let xpReward = 75
    }
}
