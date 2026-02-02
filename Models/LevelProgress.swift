import Foundation
import SwiftData

@Model
final class LevelProgress {
    var levelNumber: Int
    var title: String
    var subtitle: String
    var isCompleted: Bool
    var completedLetterIds: [Int]
    
    init(levelNumber: Int, title: String, subtitle: String, isCompleted: Bool = false, completedLetterIds: [Int] = []) {
        self.levelNumber = levelNumber
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
        self.completedLetterIds = completedLetterIds
    }
    
    var state: LevelState {
        if isCompleted { return .completed }
        if !completedLetterIds.isEmpty || levelNumber == 1 {
            return .current
        }
        return .locked
    }
    
    var masteredCount: Int {
        completedLetterIds.count
    }
    
    var totalLetters: Int {
        ArabicLetter.letters(forLevel: levelNumber).count
    }
    

}

enum LevelState {
    case locked
    case current
    case completed
}
