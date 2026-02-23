import Foundation

struct Dialogue: Identifiable, Codable {
    let id: Int
    let titleEn: String
    let titleFr: String
    let lines: [DialogueLine]
    let category: String
}

struct DialogueLine: Identifiable, Codable {
    let id: Int
    let speaker: String
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationFr: String
    let isUserTurn: Bool
    let options: [String]?
}
