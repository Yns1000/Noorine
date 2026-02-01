import Foundation

class DataLoader {
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
}