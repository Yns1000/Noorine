import Foundation

class DataLoader {
#if os(iOS)
    static func loadFlashcards() -> [Flashcard] {
        guard let url = Bundle.main.url(forResource: "flashcards", withExtension: "json") else {
            print("Error: flashcards.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Flashcard].self, from: data)
        } catch {
            print("Error decoding flashcards: \(error)")
            return []
        }
    }
#endif


    struct CourseContentJSON: Codable {
        let letters: [ArabicLetter]
        let vowels: [ArabicVowel]
        let words: [ArabicWord]
        let roots: [ArabicRoot]?
        let phrases: [ArabicPhrase]?
        let levels: [String: [LevelDefinitionJSON]]
    }
    
    struct LevelDefinitionJSON: Codable {
        let id: Int
        let type: String
        let titleKey: String
        let subtitle: String
        let contentIds: [Int]
    }
    
    static func loadCourseContent() -> CourseContentJSON? {
        guard let url = Bundle.main.url(forResource: "course_content", withExtension: "json") else {
            print("Error: course_content.json not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(CourseContentJSON.self, from: data)
        } catch {
            print("Error decoding course_content.json: \(error)")
            return nil
        }
    }
}
