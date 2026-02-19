import Foundation

struct StrokeGuide: Codable, Equatable, Hashable {
    let points: [[Double]]
    let type: String
}

struct LetterStrokeData: Codable, Equatable, Hashable {
    let isolated: [StrokeGuide]?
    let initial: [StrokeGuide]?
    let medial: [StrokeGuide]?
    let final: [StrokeGuide]?

    func guides(for formType: String) -> [StrokeGuide]? {
        switch formType {
        case "isolated": return isolated
        case "initial": return initial
        case "medial": return medial
        case "final": return final
        default: return nil
        }
    }
}

struct ArabicLetter: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let transliteration: String
    let isolated: String
    let initial: String
    let medial: String
    let final: String
    let order: Int
    let strokes: LetterStrokeData?

    init(id: Int, name: String, transliteration: String, isolated: String, initial: String, medial: String, final: String, order: Int, strokes: LetterStrokeData? = nil) {
        self.id = id; self.name = name; self.transliteration = transliteration
        self.isolated = isolated; self.initial = initial; self.medial = medial; self.final = final
        self.order = order; self.strokes = strokes
    }
    
    var pronunciationTip: String {
        switch id {
        case 1: return "pronunciation_tip_alif"
        case 2: return "pronunciation_tip_ba"
        case 3: return "pronunciation_tip_ta"
        case 4: return "pronunciation_tip_tha"
        case 5: return "pronunciation_tip_jim"
        case 6: return "pronunciation_tip_ha"
        case 7: return "pronunciation_tip_kha"
        case 8: return "pronunciation_tip_dal"
        case 9: return "pronunciation_tip_dhal"
        case 10: return "pronunciation_tip_ra"
        case 11: return "pronunciation_tip_zay"
        case 12: return "pronunciation_tip_sin"
        case 13: return "pronunciation_tip_shin"
        case 14: return "pronunciation_tip_sad"
        case 15: return "pronunciation_tip_dad"
        case 16: return "pronunciation_tip_ta_emphatic"
        case 17: return "pronunciation_tip_za"
        case 18: return "pronunciation_tip_ayn"
        case 19: return "pronunciation_tip_ghayn"
        case 20: return "pronunciation_tip_fa"
        case 21: return "pronunciation_tip_qaf"
        case 22: return "pronunciation_tip_kaf"
        case 23: return "pronunciation_tip_lam"
        case 24: return "pronunciation_tip_mim"
        case 25: return "pronunciation_tip_nun"
        case 26: return "pronunciation_tip_ha_light"
        case 27: return "pronunciation_tip_waw"
        case 28: return "pronunciation_tip_ya"
        default: return "pronunciation_tip_default"
        }
    }
    
    static var alphabet: [ArabicLetter] {
        CourseContent.letters
    }
    
    static func letter(byId id: Int) -> ArabicLetter? {
        alphabet.first { $0.id == id }
    }
    
    static func letters(forLevel levelNumber: Int) -> [ArabicLetter] {
        guard let levelDef = CourseContent.getLevels(language: AppLanguage.english).first(where: { $0.id == levelNumber }),
              levelDef.type == LevelType.alphabet else {
            return []
        }
        
        return levelDef.contentIds.compactMap { letter(byId: $0) }
    }
    
    static let nonConnectingIds: Set<Int> = [1, 8, 9, 10, 11, 27, 30]
    
    static let solarLetterIds: Set<Int> = [3, 4, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 23, 25]
    
    var connectsToLeft: Bool {
        !ArabicLetter.nonConnectingIds.contains(id)
    }
    
    var isSolar: Bool {
        ArabicLetter.solarLetterIds.contains(id)
    }
    
    var isLunar: Bool {
        !isSolar
    }
    
    var letterCategory: LetterCategory {
        isSolar ? .solar : .lunar
    }
    
    enum LetterCategory {
        case solar
        case lunar
        
        var nameKey: String {
            switch self {
            case .solar: return "Lettre Solaire"
            case .lunar: return "Lettre Lunaire"
            }
        }
        
        var icon: String {
            switch self {
            case .solar: return "sun.max.fill"
            case .lunar: return "moon.fill"
            }
        }
    }
    
    static func determineLetterForm(
        letter: ArabicLetter,
        index: Int,
        totalLetters: Int,
        previousLetter: ArabicLetter?
    ) -> String {
        let isFirst = (index == 0)
        let isLast = (index == totalLetters - 1)
        
        let connectedFromRight = !isFirst && (previousLetter?.connectsToLeft ?? false)
        let connectsToNext = !isLast && letter.connectsToLeft
        
        switch (connectedFromRight, connectsToNext) {
        case (false, false):
            return letter.isolated
        case (false, true):
            return letter.initial
        case (true, true):
            return letter.medial
        case (true, false):
            return letter.final
        }
    }
}
import Foundation


enum LevelType: String, Codable {
    case alphabet
    case vowels
    case wordBuild
    case quiz
    case solarLunar
    case phrases
    case speaking
}

struct LevelDefinition: Identifiable {
    let id: Int
    let type: LevelType
    let titleKey: String
    let subtitle: String
    let contentIds: [Int]
    
    var number: Int { id }
}

struct ArabicWord: Identifiable, Codable, Hashable {
    let id: Int
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationFr: String
    let componentLetterIds: [Int]
    let rootId: String?

    init(id: Int, arabic: String, transliteration: String, translationEn: String, translationFr: String, componentLetterIds: [Int], rootId: String? = nil) {
        self.id = id; self.arabic = arabic; self.transliteration = transliteration
        self.translationEn = translationEn; self.translationFr = translationFr
        self.componentLetterIds = componentLetterIds; self.rootId = rootId
    }
}

struct ArabicRoot: Identifiable, Codable {
    let id: String
    let letters: String
    let meaningEn: String
    let meaningFr: String
    let wordIds: [Int]
    let culturalNoteEn: String?
    let culturalNoteFr: String?

    init(id: String, letters: String, meaningEn: String, meaningFr: String, wordIds: [Int], culturalNoteEn: String? = nil, culturalNoteFr: String? = nil) {
        self.id = id; self.letters = letters; self.meaningEn = meaningEn; self.meaningFr = meaningFr
        self.wordIds = wordIds; self.culturalNoteEn = culturalNoteEn; self.culturalNoteFr = culturalNoteFr
    }
}

struct ArabicPhrase: Identifiable, Codable {
    let id: Int
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationFr: String
    let wordIds: [Int]
    let category: PhraseCategory
    let audioName: String?
    
    enum PhraseCategory: String, Codable {
        case greeting
        case introduction
        case question
        case statement
        case response
    }
}

enum ArabicVowelType: String, Codable {
    case fatha
    case kasra
    case damma
    case sukun
    case shadda
    case tanwinFatha
    case tanwinKasra
    case tanwinDamma
}

struct ArabicVowel: Identifiable, Codable {
    let id: Int
    let type: ArabicVowelType
    let name: String
    let symbol: String
    let transliteration: String
    let soundName: String
    let examples: [VowelExample]
    let descriptionEn: String?
    let descriptionFr: String?

    init(id: Int, type: ArabicVowelType, name: String, symbol: String, transliteration: String, soundName: String, examples: [VowelExample], descriptionEn: String? = nil, descriptionFr: String? = nil) {
        self.id = id; self.type = type; self.name = name; self.symbol = symbol
        self.transliteration = transliteration; self.soundName = soundName
        self.examples = examples; self.descriptionEn = descriptionEn; self.descriptionFr = descriptionFr
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        type = try container.decode(ArabicVowelType.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        transliteration = try container.decode(String.self, forKey: .transliteration)
        soundName = try container.decode(String.self, forKey: .soundName)
        examples = try container.decode([VowelExample].self, forKey: .examples)
        descriptionEn = try container.decodeIfPresent(String.self, forKey: .descriptionEn)
        descriptionFr = try container.decodeIfPresent(String.self, forKey: .descriptionFr)
    }
}

struct VowelExample: Codable {
    let letterId: Int
    let combination: String
    let transliteration: String
    let audioName: String
}


struct CourseContent {
        
    private static var loaded: DataLoader.CourseContentJSON? = DataLoader.loadCourseContent()
    
    static func reload() {
        loaded = DataLoader.loadCourseContent()
    }
    
    static var letters: [ArabicLetter] {
        loaded?.letters ?? fallbackLetters
    }
    
    static var vowels: [ArabicVowel] {
        loaded?.vowels ?? fallbackVowels
    }
    
    static var words: [ArabicWord] {
        loaded?.words ?? fallbackWords
    }
    
    static var roots: [ArabicRoot] {
        loaded?.roots ?? []
    }

    static func root(byId id: String) -> ArabicRoot? {
        roots.first { $0.id == id }
    }

    static func wordsForRoot(_ rootId: String) -> [ArabicWord] {
        words.filter { $0.rootId == rootId }
    }

    static var phrases: [ArabicPhrase] {
        loaded?.phrases ?? fallbackPhrases
    }
    
    static func getLevels(language: AppLanguage) -> [LevelDefinition] {
        let key = language == .french ? "fr" : "en"
        if let jsonLevels = loaded?.levels[key] {
            return jsonLevels.map { json in
                LevelDefinition(
                    id: json.id,
                    type: LevelType(rawValue: json.type) ?? .alphabet,
                    titleKey: json.titleKey,
                    subtitle: json.subtitle,
                    contentIds: json.contentIds
                )
            }
        }
        return fallbackLevels(language: language)
    }

    struct ValidationIssue: Identifiable {
        enum Severity: String {
            case error
            case warning
        }

        let id = UUID()
        let severity: Severity
        let message: String
    }

    static func validateAndLog() {
        let issues = validate()
        guard !issues.isEmpty else { return }

        print("CourseContent validation: \(issues.count) issue(s)")
        for issue in issues {
            print("[\(issue.severity.rawValue.uppercased())] \(issue.message)")
        }
    }

    static func validate() -> [ValidationIssue] {
        guard let json = loaded else {
            return [
                ValidationIssue(
                    severity: .error,
                    message: "course_content.json could not be loaded. Using fallback content."
                )
            ]
        }

        var issues: [ValidationIssue] = []

        func duplicateIds(in ids: [Int]) -> [Int] {
            var seen = Set<Int>()
            var duplicates = Set<Int>()
            for id in ids {
                if seen.contains(id) {
                    duplicates.insert(id)
                } else {
                    seen.insert(id)
                }
            }
            return Array(duplicates).sorted()
        }

        func checkIds(_ ids: [Int], in allowed: Set<Int>, context: String) {
            let missing = ids.filter { !allowed.contains($0) }
            guard !missing.isEmpty else { return }
            let list = missing.map(String.init).joined(separator: ", ")
            issues.append(ValidationIssue(severity: .error, message: "\(context) references missing ids: \(list)"))
        }

        let letterIds = Set(json.letters.map { $0.id })
        let vowelIds = Set(json.vowels.map { $0.id })
        let wordIds = Set(json.words.map { $0.id })
        let phraseList = json.phrases ?? []
        let phraseIds = Set(phraseList.map { $0.id })

        let letterDuplicates = duplicateIds(in: json.letters.map { $0.id })
        if !letterDuplicates.isEmpty {
            issues.append(ValidationIssue(severity: .error, message: "Duplicate letter ids: \(letterDuplicates)"))
        }

        let vowelDuplicates = duplicateIds(in: json.vowels.map { $0.id })
        if !vowelDuplicates.isEmpty {
            issues.append(ValidationIssue(severity: .error, message: "Duplicate vowel ids: \(vowelDuplicates)"))
        }

        let wordDuplicates = duplicateIds(in: json.words.map { $0.id })
        if !wordDuplicates.isEmpty {
            issues.append(ValidationIssue(severity: .error, message: "Duplicate word ids: \(wordDuplicates)"))
        }

        let phraseDuplicates = duplicateIds(in: phraseList.map { $0.id })
        if !phraseDuplicates.isEmpty {
            issues.append(ValidationIssue(severity: .error, message: "Duplicate phrase ids: \(phraseDuplicates)"))
        }

        for word in json.words {
            checkIds(word.componentLetterIds, in: letterIds, context: "Word \(word.id)")
        }

        for vowel in json.vowels {
            if vowel.examples.isEmpty {
                issues.append(ValidationIssue(severity: .warning, message: "Vowel \(vowel.id) has no examples."))
            }
            for example in vowel.examples {
                if !letterIds.contains(example.letterId) {
                    issues.append(
                        ValidationIssue(
                            severity: .error,
                            message: "Vowel \(vowel.id) example references missing letter id \(example.letterId)."
                        )
                    )
                }
            }
        }

        if phraseList.isEmpty {
            issues.append(ValidationIssue(severity: .warning, message: "No phrases defined. Phrase levels will be empty."))
        }

        for phrase in phraseList {
            if phrase.arabic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(ValidationIssue(severity: .error, message: "Phrase \(phrase.id) has empty Arabic text."))
            }
            if !phrase.wordIds.isEmpty {
                checkIds(phrase.wordIds, in: wordIds, context: "Phrase \(phrase.id) wordIds")
            }
        }

        if json.levels["fr"] == nil {
            issues.append(ValidationIssue(severity: .warning, message: "levels.fr is missing."))
        }
        if json.levels["en"] == nil {
            issues.append(ValidationIssue(severity: .warning, message: "levels.en is missing."))
        }

        if let fr = json.levels["fr"], let en = json.levels["en"] {
            let frIds = fr.map { $0.id }
            let enIds = en.map { $0.id }
            if frIds != enIds {
                issues.append(
                    ValidationIssue(
                        severity: .warning,
                        message: "levels.fr and levels.en ids differ. Keep them in sync for consistent progression."
                    )
                )
            }
        }

        for (lang, levels) in json.levels {
            let levelIds = levels.map { $0.id }
            let levelDuplicates = duplicateIds(in: levelIds)
            if !levelDuplicates.isEmpty {
                issues.append(
                    ValidationIssue(
                        severity: .error,
                        message: "Duplicate level ids in levels[\(lang)]: \(levelDuplicates)"
                    )
                )
            }

            for level in levels {
                guard let levelType = LevelType(rawValue: level.type) else {
                    issues.append(
                        ValidationIssue(
                            severity: .error,
                            message: "Level \(level.id) in levels[\(lang)] has unknown type '\(level.type)'."
                        )
                    )
                    continue
                }

                let contentDuplicates = duplicateIds(in: level.contentIds)
                if !contentDuplicates.isEmpty {
                    issues.append(
                        ValidationIssue(
                            severity: .warning,
                            message: "Level \(level.id) in levels[\(lang)] has duplicate contentIds: \(contentDuplicates)"
                        )
                    )
                }

                if level.contentIds.isEmpty && levelType != .solarLunar {
                    issues.append(
                        ValidationIssue(
                            severity: .warning,
                            message: "Level \(level.id) in levels[\(lang)] has empty contentIds."
                        )
                    )
                }

                switch levelType {
                case .alphabet, .quiz, .speaking:
                    checkIds(level.contentIds, in: letterIds, context: "Level \(level.id) alphabet")
                case .vowels:
                    checkIds(level.contentIds, in: vowelIds, context: "Level \(level.id) vowels")
                case .wordBuild:
                    checkIds(level.contentIds, in: wordIds, context: "Level \(level.id) wordBuild")
                case .phrases:
                    checkIds(level.contentIds, in: phraseIds, context: "Level \(level.id) phrases")
                case .solarLunar:
                    if !level.contentIds.isEmpty {
                        issues.append(
                            ValidationIssue(
                                severity: .warning,
                                message: "Level \(level.id) in levels[\(lang)] is solarLunar but contentIds is not empty."
                            )
                        )
                    }
                }
            }
        }

        return issues
    }
    
    
    private static let fallbackLetters: [ArabicLetter] = [
        ArabicLetter(id: 1, name: "أَلِف", transliteration: "Alif", isolated: "ا", initial: "ا", medial: "ـا", final: "ـا", order: 1),
        ArabicLetter(id: 2, name: "بَاء", transliteration: "Bā'", isolated: "ب", initial: "بـ", medial: "ـبـ", final: "ـب", order: 2),
        ArabicLetter(id: 3, name: "تَاء", transliteration: "Tā'", isolated: "ت", initial: "تـ", medial: "ـتـ", final: "ـت", order: 3),
        ArabicLetter(id: 4, name: "ثَاء", transliteration: "Thā'", isolated: "ث", initial: "ثـ", medial: "ـثـ", final: "ـث", order: 4),
        ArabicLetter(id: 5, name: "جِيم", transliteration: "Jīm", isolated: "ج", initial: "جـ", medial: "ـجـ", final: "ـج", order: 5),
        ArabicLetter(id: 6, name: "حَاء", transliteration: "Ḥā'", isolated: "ح", initial: "حـ", medial: "ـحـ", final: "ـح", order: 6),
        ArabicLetter(id: 7, name: "خَاء", transliteration: "Khā'", isolated: "خ", initial: "خـ", medial: "ـخـ", final: "ـخ", order: 7),
        ArabicLetter(id: 8, name: "دَال", transliteration: "Dāl", isolated: "د", initial: "د", medial: "ـد", final: "ـد", order: 8),
        ArabicLetter(id: 9, name: "ذَال", transliteration: "Dhāl", isolated: "ذ", initial: "ذ", medial: "ـذ", final: "ـذ", order: 9),
        ArabicLetter(id: 10, name: "رَاء", transliteration: "Rā'", isolated: "ر", initial: "ر", medial: "ـر", final: "ـر", order: 10),
        ArabicLetter(id: 11, name: "زَاي", transliteration: "Zāy", isolated: "ز", initial: "ز", medial: "ـز", final: "ـز", order: 11),
        ArabicLetter(id: 12, name: "سِين", transliteration: "Sīn", isolated: "س", initial: "سـ", medial: "ـسـ", final: "ـس", order: 12),
        ArabicLetter(id: 13, name: "شِين", transliteration: "Shīn", isolated: "ش", initial: "شـ", medial: "ـشـ", final: "ـش", order: 13),
        ArabicLetter(id: 14, name: "صَاد", transliteration: "Ṣād", isolated: "ص", initial: "صـ", medial: "ـصـ", final: "ـص", order: 14),
        ArabicLetter(id: 15, name: "ضَاد", transliteration: "Ḍād", isolated: "ض", initial: "ضـ", medial: "ـضـ", final: "ـض", order: 15),
        ArabicLetter(id: 16, name: "طَاء", transliteration: "Ṭā'", isolated: "ط", initial: "طـ", medial: "ـطـ", final: "ـط", order: 16),
        ArabicLetter(id: 17, name: "ظَاء", transliteration: "Ẓā'", isolated: "ظ", initial: "ظـ", medial: "ـظـ", final: "ـظ", order: 17),
        ArabicLetter(id: 18, name: "عَين", transliteration: "'Ayn", isolated: "ع", initial: "عـ", medial: "ـعـ", final: "ـع", order: 18),
        ArabicLetter(id: 19, name: "غَين", transliteration: "Ghayn", isolated: "غ", initial: "غـ", medial: "ـغـ", final: "ـغ", order: 19),
        ArabicLetter(id: 20, name: "فَاء", transliteration: "Fā'", isolated: "ف", initial: "فـ", medial: "ـفـ", final: "ـف", order: 20),
        ArabicLetter(id: 21, name: "قَاف", transliteration: "Qāf", isolated: "ق", initial: "قـ", medial: "ـقـ", final: "ـق", order: 21),
        ArabicLetter(id: 22, name: "كَاف", transliteration: "Kāf", isolated: "ك", initial: "كـ", medial: "ـكـ", final: "ـك", order: 22),
        ArabicLetter(id: 23, name: "لَام", transliteration: "Lām", isolated: "ل", initial: "لـ", medial: "ـلـ", final: "ـل", order: 23),
        ArabicLetter(id: 24, name: "مِيم", transliteration: "Mīm", isolated: "م", initial: "مـ", medial: "ـمـ", final: "ـم", order: 24),
        ArabicLetter(id: 25, name: "نُون", transliteration: "Nūn", isolated: "ن", initial: "نـ", medial: "ـنـ", final: "ـن", order: 25),
        ArabicLetter(id: 26, name: "هَاء", transliteration: "Hā'", isolated: "ه", initial: "هـ", medial: "ـهـ", final: "ـه", order: 26),
        ArabicLetter(id: 27, name: "وَاو", transliteration: "Wāw", isolated: "و", initial: "و", medial: "ـو", final: "ـو", order: 27),
        ArabicLetter(id: 28, name: "يَاء", transliteration: "Yā'", isolated: "ي", initial: "يـ", medial: "ـيـ", final: "ـي", order: 28)
    ]
    
    private static let fallbackVowels: [ArabicVowel] = [
        ArabicVowel(
            id: 1, type: .fatha, name: "Fatha", symbol: "َ", transliteration: "a", soundName: "fatha_sound",
            examples: [
                VowelExample(letterId: 2, combination: "بَ", transliteration: "Ba", audioName: "ba_fatha"),
                VowelExample(letterId: 3, combination: "تَ", transliteration: "Ta", audioName: "ta_fatha")
            ]
        ),
        ArabicVowel(
            id: 2, type: .kasra, name: "Kasra", symbol: "ِ", transliteration: "i", soundName: "kasra_sound",
            examples: [
                VowelExample(letterId: 2, combination: "بِ", transliteration: "Bi", audioName: "ba_kasra"),
                VowelExample(letterId: 3, combination: "تِ", transliteration: "Ti", audioName: "ta_kasra")
            ]
        ),
        ArabicVowel(
            id: 3, type: .damma, name: "Damma", symbol: "ُ", transliteration: "u", soundName: "damma_sound",
            examples: [
                VowelExample(letterId: 2, combination: "بُ", transliteration: "Bu", audioName: "ba_damma"),
                VowelExample(letterId: 3, combination: "تُ", transliteration: "Tu", audioName: "ta_damma")
            ]
        ),
        ArabicVowel(
            id: 4, type: .sukun, name: "Sukun", symbol: "ْ", transliteration: "-", soundName: "sukun_sound",
            examples: [
                VowelExample(letterId: 2, combination: "بْ", transliteration: "b", audioName: "ba_sukun"),
                VowelExample(letterId: 23, combination: "لْ", transliteration: "l", audioName: "lam_sukun")
            ]
        ),
        ArabicVowel(
            id: 5, type: .shadda, name: "Shadda", symbol: "ّ", transliteration: "xx", soundName: "shadda_sound",
            examples: [
                VowelExample(letterId: 2, combination: "بَّ", transliteration: "bb", audioName: "ba_shadda"),
                VowelExample(letterId: 24, combination: "مَّ", transliteration: "mm", audioName: "mim_shadda")
            ]
        )
    ]
    
    private static let fallbackWords: [ArabicWord] = [
        ArabicWord(id: 1, arabic: "أَبْ", transliteration: "Ab", translationEn: "Father", translationFr: "Père", componentLetterIds: [1, 2]),
        ArabicWord(id: 2, arabic: "بَاب", transliteration: "Bab", translationEn: "Door", translationFr: "Porte", componentLetterIds: [2, 1, 2]),
        ArabicWord(id: 3, arabic: "أُمّ", transliteration: "Umm", translationEn: "Mother", translationFr: "Mère", componentLetterIds: [1, 24]),
        ArabicWord(id: 4, arabic: "أَخ", transliteration: "Akh", translationEn: "Brother", translationFr: "Frère", componentLetterIds: [1, 7]),
        ArabicWord(id: 5, arabic: "يَد", transliteration: "Yad", translationEn: "Hand", translationFr: "Main", componentLetterIds: [28, 8])
    ]
    
    private static let fallbackPhrases: [ArabicPhrase] = [
        ArabicPhrase(id: 1, arabic: "أَنَا طَالِب", transliteration: "Ana talib", translationEn: "I am a student", translationFr: "Je suis étudiant", wordIds: [], category: .introduction, audioName: nil),
        ArabicPhrase(id: 2, arabic: "هٰذَا كِتَاب", transliteration: "Hadha kitab", translationEn: "This is a book", translationFr: "Ceci est un livre", wordIds: [], category: .statement, audioName: nil),
        ArabicPhrase(id: 3, arabic: "السَّلَامُ عَلَيْكُم", transliteration: "Assalamu alaykum", translationEn: "Peace be upon you", translationFr: "La paix soit sur vous", wordIds: [], category: .greeting, audioName: nil),
        ArabicPhrase(id: 4, arabic: "شُكْرًا", transliteration: "Shukran", translationEn: "Thank you", translationFr: "Merci", wordIds: [], category: .response, audioName: nil),
        ArabicPhrase(id: 5, arabic: "مَا اسْمُكَ؟", transliteration: "Ma ismuka?", translationEn: "What is your name?", translationFr: "Comment t'appelles-tu?", wordIds: [], category: .question, audioName: nil)
    ]
    
    private static func fallbackLevels(language: AppLanguage) -> [LevelDefinition] {
        let vowelTitle = language == .french ? "Les Voyelles Courtes" : "Short Vowels"
        let practiceTitle = language == .french ? "Pratique : Voyelles" : "Practice: Vowels"
        let wordTitle = language == .french ? "Premiers Mots" : "First Words"
        
        func alphabetTitle(range: String) -> String {
            language == .french ? "L'Alphabet (\(range))" : "Alphabet (\(range))"
        }
        
        return [
            LevelDefinition(id: 1, type: .alphabet, titleKey: alphabetTitle(range: "1-4"), subtitle: "أ ب ت ث", contentIds: [1, 2, 3, 4]),
            LevelDefinition(id: 2, type: .vowels, titleKey: vowelTitle, subtitle: "Introduction & Quiz", contentIds: [1, 2, 3]),
            LevelDefinition(id: 3, type: .alphabet, titleKey: alphabetTitle(range: "5-9"), subtitle: "ج ح خ د ذ", contentIds: [5, 6, 7, 8, 9]),
            LevelDefinition(id: 4, type: .vowels, titleKey: practiceTitle, subtitle: "ج - ذ + Harakat", contentIds: [1, 2, 3]),
            LevelDefinition(id: 5, type: .alphabet, titleKey: alphabetTitle(range: "10-14"), subtitle: "ر ز س ش ص", contentIds: [10, 11, 12, 13, 14]),
            LevelDefinition(id: 6, type: .vowels, titleKey: practiceTitle, subtitle: "ر - ص + Harakat", contentIds: [1, 2, 3]),
            LevelDefinition(id: 7, type: .alphabet, titleKey: alphabetTitle(range: "15-19"), subtitle: "ض ط ظ ع غ", contentIds: [15, 16, 17, 18, 19]),
            LevelDefinition(id: 8, type: .vowels, titleKey: practiceTitle, subtitle: "ض - غ + Harakat", contentIds: [1, 2, 3]),
            LevelDefinition(id: 9, type: .alphabet, titleKey: alphabetTitle(range: "20-28"), subtitle: "ف ق ك ل م ن ه و ي", contentIds: Array(20...28)),
            LevelDefinition(id: 10, type: .vowels, titleKey: practiceTitle, subtitle: "ف - ي + Harakat", contentIds: [1, 2, 3]),
            LevelDefinition(id: 11, type: .wordBuild, titleKey: wordTitle, subtitle: "أَبْ - يَد", contentIds: [1, 2, 3, 4, 5])
        ]
    }
    
    static func getLevelTitle(for levelNumber: Int, language: AppLanguage) -> String {
        guard let level = getLevels(language: language).first(where: { $0.id == levelNumber }) else {
            return language == AppLanguage.english ? "Level \(levelNumber)" : "Niveau \(levelNumber)"
        }
        return level.titleKey
    }

    static func getLevelSubtitle(for levelNumber: Int, language: AppLanguage) -> String {
        guard let level = getLevels(language: language).first(where: { $0.id == levelNumber }) else {
            return ""
        }
        return level.subtitle
    }
}
