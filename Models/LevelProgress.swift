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
        let letters = ArabicLetter.letters(forLevel: levelNumber)
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
    
    static let defaultLevels: [(number: Int, title: String, subtitle: String)] = [
        (1, "L'Alphabet (1-7)", "أ ب ت ث ج ح خ"),
        (2, "L'Alphabet (8-14)", "د ذ ر ز س ش ص"),
        (3, "L'Alphabet (15-21)", "ض ط ظ ع غ ف ق"),
        (4, "L'Alphabet (22-28)", "ك ل م ن ه و ي")
    ]
}

enum LevelState {
    case locked
    case current
    case completed
}
