import Foundation

/// Représente une lettre de l'alphabet arabe avec ses 4 formes
struct ArabicLetter: Identifiable, Codable {
    let id: Int
    let name: String           // Nom arabe (ex: "أَلِف")
    let transliteration: String // Translittération (ex: "Alif")
    let isolated: String       // Forme isolée
    let initial: String        // Forme initiale
    let medial: String         // Forme médiane
    let final: String          // Forme finale
    let order: Int             // Position dans l'alphabet (1-28)
    
    /// Les 28 lettres de l'alphabet arabe
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
    
    /// Récupère une lettre par son ID
    static func letter(byId id: Int) -> ArabicLetter? {
        alphabet.first { $0.id == id }
    }
    
    /// Récupère les lettres pour un niveau donné (7 lettres par niveau)
    static func letters(forLevel levelNumber: Int) -> [ArabicLetter] {
        let startIndex = (levelNumber - 1) * 7
        let endIndex = min(startIndex + 7, alphabet.count)
        guard startIndex < alphabet.count else { return [] }
        return Array(alphabet[startIndex..<endIndex])
    }
}
