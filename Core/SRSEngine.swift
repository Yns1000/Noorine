import Foundation

struct SRSCard: Codable, Identifiable {
    let cardId: String
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?
    
    var id: String { cardId }
    
    static func new(cardId: String) -> SRSCard {
        SRSCard(
            cardId: cardId,
            easeFactor: 2.5,
            interval: 0,
            repetitions: 0,
            nextReviewDate: Date(),
            lastReviewDate: nil
        )
    }
}

enum SRSResponse: Int {
    case again = 0
    case hard = 1
    case good = 2
    case easy = 3
    
    var label: String {
        switch self {
        case .again: return "again"
        case .hard: return "hard"
        case .good: return "good"
        case .easy: return "easy"
        }
    }
}

final class SRSEngine {
    static let shared = SRSEngine()
    
    private let storageKey = "srs_cards_data"
    private var cards: [String: SRSCard] = [:]
    
    private init() {
        loadCards()
    }
    
    func getCard(for id: String) -> SRSCard {
        if let existing = cards[id] {
            return existing
        }
        let newCard = SRSCard.new(cardId: id)
        cards[id] = newCard
        saveCards()
        return newCard
    }
    
    func processResponse(_ response: SRSResponse, for cardId: String) {
        var card = getCard(for: cardId)
        
        let quality = response.rawValue
        
        if quality < 2 {
            card.repetitions = 0
            card.interval = 1
        } else {
            if card.repetitions == 0 {
                card.interval = 1
            } else if card.repetitions == 1 {
                card.interval = 6
            } else {
                card.interval = Int(Double(card.interval) * card.easeFactor)
            }
            card.repetitions += 1
        }
        
        let easeModifier: Double
        switch response {
        case .again: easeModifier = -0.3
        case .hard: easeModifier = -0.15
        case .good: easeModifier = 0.0
        case .easy: easeModifier = 0.15
        }
        
        card.easeFactor = max(1.3, card.easeFactor + easeModifier)
        card.lastReviewDate = Date()
        card.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: card.interval,
            to: Date()
        ) ?? Date()
        
        cards[cardId] = card
        saveCards()
    }
    
    func isDue(_ cardId: String) -> Bool {
        guard let card = cards[cardId] else { return true }
        return card.nextReviewDate <= Date()
    }
    
    func getDueCards(from cardIds: [String]) -> [String] {
        cardIds.filter { isDue($0) }
    }
    
    func getNextReviewDate(for cardId: String) -> Date? {
        cards[cardId]?.nextReviewDate
    }
    
    func getIntervalDays(for cardId: String) -> Int {
        cards[cardId]?.interval ?? 0
    }
    
    func getStats() -> SRSStats {
        let now = Date()
        let dueCount = cards.values.filter { $0.nextReviewDate <= now }.count
        let learningCount = cards.values.filter { $0.repetitions < 2 }.count
        let matureCount = cards.values.filter { $0.interval >= 21 }.count
        
        return SRSStats(
            totalCards: cards.count,
            dueToday: dueCount,
            learning: learningCount,
            mature: matureCount
        )
    }
    
    func reset() {
        cards.removeAll()
        saveCards()
    }
    
    private func loadCards() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: SRSCard].self, from: data) else {
            return
        }
        cards = decoded
    }
    
    private func saveCards() {
        guard let encoded = try? JSONEncoder().encode(cards) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

struct SRSStats {
    let totalCards: Int
    let dueToday: Int
    let learning: Int
    let mature: Int
    
    var masteryPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(mature) / Double(totalCards) * 100
    }
}
