import Foundation
import SwiftData

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

    private var modelContext: ModelContext?
    private let legacyStorageKey = "srs_cards_data"

    private init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
        migrateFromUserDefaultsIfNeeded()
    }

    func getCard(for id: String) -> SRSCard {
        if let existing = fetchCard(id: id) {
            return existing
        }
        let newCard = SRSCard(cardId: id)
        modelContext?.insert(newCard)
        try? modelContext?.save()
        return newCard
    }

    func processResponse(_ response: SRSResponse, for cardId: String) {
        let card = getCard(for: cardId)

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

        try? modelContext?.save()
    }

    func isDue(_ cardId: String) -> Bool {
        guard let card = fetchCard(id: cardId) else { return true }
        return card.nextReviewDate <= Date()
    }

    func getDueCards(from cardIds: [String]) -> [String] {
        cardIds.filter { isDue($0) }
    }

    func getNextReviewDate(for cardId: String) -> Date? {
        fetchCard(id: cardId)?.nextReviewDate
    }

    func getIntervalDays(for cardId: String) -> Int {
        fetchCard(id: cardId)?.interval ?? 0
    }

    func getStats() -> SRSStats {
        guard let context = modelContext else {
            return SRSStats(totalCards: 0, dueToday: 0, learning: 0, mature: 0)
        }
        
        let now = Date()
        
        let totalDescriptor = FetchDescriptor<SRSCard>()
        let totalCount = (try? context.fetchCount(totalDescriptor)) ?? 0
        
        let dueDescriptor = FetchDescriptor<SRSCard>(predicate: #Predicate { $0.nextReviewDate <= now })
        let dueCount = (try? context.fetchCount(dueDescriptor)) ?? 0
        
        let learningDescriptor = FetchDescriptor<SRSCard>(predicate: #Predicate { $0.repetitions < 2 })
        let learningCount = (try? context.fetchCount(learningDescriptor)) ?? 0
        
        let matureDescriptor = FetchDescriptor<SRSCard>(predicate: #Predicate { $0.interval >= 21 })
        let matureCount = (try? context.fetchCount(matureDescriptor)) ?? 0

        return SRSStats(
            totalCards: totalCount,
            dueToday: dueCount,
            learning: learningCount,
            mature: matureCount
        )
    }

    func reset() {
        let allCards = fetchAllCards()
        for card in allCards {
            modelContext?.delete(card)
        }
        try? modelContext?.save()
    }

    private func fetchCard(id: String) -> SRSCard? {
        guard let context = modelContext else { return nil }
        let predicate = #Predicate<SRSCard> { $0.cardId == id }
        var descriptor = FetchDescriptor<SRSCard>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private func fetchAllCards() -> [SRSCard] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<SRSCard>()
        return (try? context.fetch(descriptor)) ?? []
    }

    private func migrateFromUserDefaultsIfNeeded() {
        guard let context = modelContext,
              let data = UserDefaults.standard.data(forKey: legacyStorageKey) else { return }

        struct LegacySRSCard: Codable {
            let cardId: String
            var easeFactor: Double
            var interval: Int
            var repetitions: Int
            var nextReviewDate: Date
            var lastReviewDate: Date?
        }

        guard let legacy = try? JSONDecoder().decode([String: LegacySRSCard].self, from: data) else { return }

        for (_, old) in legacy {
            let card = SRSCard(
                cardId: old.cardId,
                easeFactor: old.easeFactor,
                interval: old.interval,
                repetitions: old.repetitions,
                nextReviewDate: old.nextReviewDate,
                lastReviewDate: old.lastReviewDate
            )
            context.insert(card)
        }

        try? context.save()
        UserDefaults.standard.removeObject(forKey: legacyStorageKey)
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
