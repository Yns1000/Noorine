import Foundation

struct PracticePool {
    let letters: [ArabicLetter]
    let vowels: [ArabicVowel]
    let words: [ArabicWord]
    let phrases: [ArabicPhrase]
}

extension DataManager {
    func practicePool(language: AppLanguage) -> PracticePool {
        let accessibleLevelIds = Set(
            levels
                .filter { levelState(for: $0.levelNumber) != .locked }
                .map { $0.levelNumber }
        )
        
        let levelDefs = CourseContent.getLevels(language: language)
            .filter { accessibleLevelIds.contains($0.id) }
        
        var letterIds = Set<Int>()
        var vowelIds = Set<Int>()
        var wordIds = Set<Int>()
        var phraseIds = Set<Int>()
        
        for level in levelDefs {
            switch level.type {
            case .alphabet, .quiz, .speaking:
                letterIds.formUnion(level.contentIds)
            case .vowels:
                vowelIds.formUnion(level.contentIds)
            case .wordBuild:
                wordIds.formUnion(level.contentIds)
            case .phrases:
                phraseIds.formUnion(level.contentIds)
            case .solarLunar:
                break
            }
        }
        
        if !phraseIds.isEmpty {
            let phraseWordIds = CourseContent.phrases
                .filter { phraseIds.contains($0.id) }
                .flatMap { $0.wordIds }
            wordIds.formUnion(phraseWordIds)
        }
        
        let letters = letterIds.isEmpty
            ? Array(CourseContent.letters.prefix(3))
            : CourseContent.letters.filter { letterIds.contains($0.id) }
        let vowels = CourseContent.vowels.filter { vowelIds.contains($0.id) }
        let words = CourseContent.words.filter { wordIds.contains($0.id) }
        let phrases = CourseContent.phrases.filter { phraseIds.contains($0.id) }
        
        return PracticePool(
            letters: letters,
            vowels: vowels,
            words: words,
            phrases: phrases
        )
    }
}
