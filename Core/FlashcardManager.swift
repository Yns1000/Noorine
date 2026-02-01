import SwiftUI
import Combine

class FlashcardManager: ObservableObject {
    static let shared = FlashcardManager()
    
    @Published var knownCardIds: Set<String> = []
    @Published var reviewCardIds: Set<String> = []
    
    private var allCardsCache: [Flashcard] = []
    
    private let knownKey = "flashcards_known_ids"
    private let reviewKey = "flashcards_review_ids"
    
    init() {
        self.allCardsCache = DataLoader.loadFlashcards()
        loadProgress()
    }
    
    func loadProgress() {
        if let savedKnown = UserDefaults.standard.array(forKey: knownKey) as? [String] {
            knownCardIds = Set(savedKnown)
        }
        if let savedReview = UserDefaults.standard.array(forKey: reviewKey) as? [String] {
            reviewCardIds = Set(savedReview)
        }
    }
    
    func saveProgress() {
        UserDefaults.standard.set(Array(knownCardIds), forKey: knownKey)
        UserDefaults.standard.set(Array(reviewCardIds), forKey: reviewKey)
    }
    
    func getPracticeCards() -> [Flashcard] {
        let allCards = getAllCards()
        
        let unknownCards = allCards.filter { !knownCardIds.contains($0.id) }
        
        let reviewCards = unknownCards.filter { reviewCardIds.contains($0.id) }
        let newCards = unknownCards.filter { !reviewCardIds.contains($0.id) }
        
        return reviewCards.shuffled() + newCards.shuffled()
    }
    
    func getAllCards() -> [Flashcard] {
        if allCardsCache.isEmpty {
            allCardsCache = DataLoader.loadFlashcards()
        }
        return allCardsCache
    }
    
    func markAsKnown(_ card: Flashcard) {
        knownCardIds.insert(card.id)
        reviewCardIds.remove(card.id)
        saveProgress()
    }
    
    func markAsReview(_ card: Flashcard) {
        reviewCardIds.insert(card.id)
        knownCardIds.remove(card.id)
        saveProgress()
    }
    
    func isKnown(_ card: Flashcard) -> Bool {
        return knownCardIds.contains(card.id)
    }
    
    func needsReview(_ card: Flashcard) -> Bool {
        return reviewCardIds.contains(card.id)
    }
    
    func resetProgress() {
        knownCardIds.removeAll()
        reviewCardIds.removeAll()
        saveProgress()
    }
}