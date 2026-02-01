import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    var id: String { transliteration }
    let arabic: String
    let transliteration: String
    let french: String
    let english: String
    let example: String
    let exampleEnglish: String
    let exampleArabic: String
}