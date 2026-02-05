import SwiftUI
import Combine

final class FlashcardManager: ObservableObject {
    static let shared = FlashcardManager()
    
    @Published private(set) var allCards: [Flashcard] = []
    
    private let srs = SRSEngine.shared
    
    private init() {
        allCards = DataLoader.loadFlashcards()
    }
    
    var dueCards: [Flashcard] {
        let dueIds = Set(srs.getDueCards(from: allCards.map { $0.id }))
        return allCards.filter { dueIds.contains($0.id) }
    }
    
    var stats: SRSStats {
        srs.getStats()
    }
    
    func getPracticeCards(limit: Int = 20) -> [Flashcard] {
        let due = dueCards
        let newCards = allCards.filter { card in
            srs.getIntervalDays(for: card.id) == 0
        }
        
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
}
