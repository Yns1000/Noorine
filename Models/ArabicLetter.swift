import Foundation

struct ArabicLetter: Identifiable, Codable {
    let id: Int
    let name: String
    let transliteration: String
    let isolated: String
    let initial: String
    let medial: String
    let final: String
    let order: Int
    
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
    
    static let alphabet: [ArabicLetter] = [
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
    
    static func letter(byId id: Int) -> ArabicLetter? {
        alphabet.first { $0.id == id }
    }
    
    static func letters(forLevel levelNumber: Int) -> [ArabicLetter] {
        let startIndex = (levelNumber - 1) * 7
        let endIndex = min(startIndex + 7, alphabet.count)
        guard startIndex < alphabet.count else { return [] }
        return Array(alphabet[startIndex..<endIndex])
    }
}
