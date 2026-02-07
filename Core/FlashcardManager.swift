import SwiftUI
import Combine

final class FlashcardManager: ObservableObject {
    static let shared = FlashcardManager()
    
    @Published private(set) var allCards: [Flashcard] = []
    
    private let srs = SRSEngine.shared
    
    private init() {
        let baseCards = DataLoader.loadFlashcards()
        allCards = mergeCourseWords(into: baseCards)
    }
    
    var dueCards: [Flashcard] {
        let dueIds = Set(srs.getDueCards(from: allCards.map { $0.id }))
        return allCards.filter { dueIds.contains($0.id) }
    }
    
    var stats: SRSStats {
        srs.getStats()
    }
    
    func getPracticeCards(limit: Int = 20, allowedArabic: Set<String> = []) -> [Flashcard] {
        let pool = filteredCards(allowedArabic: allowedArabic)
        let dueIds = Set(srs.getDueCards(from: pool.map { $0.id }))
        let due = pool.filter { dueIds.contains($0.id) }
        let newCards = pool.filter { srs.getIntervalDays(for: $0.id) == 0 }
        
        let reviewFirst = due.filter { !newCards.contains($0) }
        let combined = Array((reviewFirst + newCards).prefix(limit))
        
        return combined.shuffled()
    }
    
    func recordResponse(_ response: SRSResponse, for card: Flashcard) {
        srs.processResponse(response, for: card.id)
        objectWillChange.send()
    }
    
    func getNextReview(for card: Flashcard) -> Date? {
        srs.getNextReviewDate(for: card.id)
    }
    
    func getInterval(for card: Flashcard) -> Int {
        srs.getIntervalDays(for: card.id)
    }
    
    func isDue(_ card: Flashcard) -> Bool {
        srs.isDue(card.id)
    }
    
    func reset() {
        srs.reset()
        objectWillChange.send()
    }

    func filteredCards(allowedArabic: Set<String>) -> [Flashcard] {
        guard !allowedArabic.isEmpty else { return allCards }
        return allCards.filter { allowedArabic.contains($0.arabic) }
    }

    func dueCards(allowedArabic: Set<String>) -> [Flashcard] {
        let pool = filteredCards(allowedArabic: allowedArabic)
        let dueIds = Set(srs.getDueCards(from: pool.map { $0.id }))
        return pool.filter { dueIds.contains($0.id) }
    }
    
    private func mergeCourseWords(into base: [Flashcard]) -> [Flashcard] {
        var byArabic: [String: Flashcard] = [:]
        for card in base {
            byArabic[card.arabic] = card
        }
        
        for word in CourseContent.words {
            if byArabic[word.arabic] == nil {
                let card = Flashcard(
                    arabic: word.arabic,
                    transliteration: word.transliteration,
                    french: word.translationFr,
                    english: word.translationEn,
                    example: word.translationFr,
                    exampleEnglish: word.translationEn,
                    exampleArabic: word.arabic
                )
                byArabic[word.arabic] = card
            }
        }
        
        return Array(byArabic.values).sorted { $0.arabic < $1.arabic }
    }
}
