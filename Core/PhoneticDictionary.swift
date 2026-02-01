import Foundation

class PhoneticDictionary {
    static let shared = PhoneticDictionary()
    
    private init() {}
    
    private let variants: [String: [String]] = [
        "alif": ["alif", "alef", "elif", "alice", "a", "ah", "1000", "mille", "alf", "alpha", "aleph", "at", "up"],
        "ā": ["alif", "alef", "elif", "alice", "a", "ah", "1000", "mille", "alf", "alpha"],
        
        "ba": ["ba", "bah", "baa", "bar", "bas", "bad", "bag", "b", "bah"],
        "bā": ["ba", "bah", "baa", "bar", "b"],
        
        "ta": ["ta", "tah", "taa", "tar", "tea", "tap", "top", "t", "tall", "toe", "tah"],
        "tā": ["ta", "tah", "taa", "tar", "t"],
        "ṭā": ["ta", "taa", "tah", "t", "top"],
        "thā": ["tha", "thah", "th", "fa", "sa"],
        
        "jim": ["jim", "jeem", "gym", "j", "jean", "gin", "gem", "jam", "james", "jimmy"],
        "jīm": ["jim", "jeem", "gym", "j", "jean"],
        
        "ha": ["ha", "hah", "haa", "h", "hot", "hat", "heart", "hu", "he", "her", "huh"],
        "ḥā": ["ha", "hah", "haa", "h"],
        "hā": ["ha", "hah", "h"],
        
        "kha": ["kha", "khah", "kh", "k", "ca", "car", "ka", "caw", "cow"],
        "khā": ["kha", "khah", "kh", "k", "car"],
        
        "dal": ["dal", "daal", "del", "d", "dad", "deal", "doll", "dial", "dahl"],
        "dāl": ["dal", "daal", "del", "d"],
        
        "dhal": ["dhal", "dhaal", "zal", "the", "that", "those", "zall", "val"],
        "dhāl": ["dhal", "dhaal", "zal", "the"],
        
        "ra": ["ra", "rah", "raa", "r", "raw", "row", "run", "rat"],
        "rā": ["ra", "rah", "raa", "r"],
        
        "zay": ["zay", "zai", "z", "zed", "zee", "zei", "say"],
        "zāy": ["zay", "zai", "z", "zed"],
        "za": ["za", "zaa", "zah", "z", "the", "that", "zar", "pizza"],
        "ẓā": ["za", "zaa", "zah", "z"],
        
        "sin": ["sin", "seen", "scene", "s", "cine", "sun", "son", "thin", "sign"],
        "sīn": ["sin", "seen", "scene", "s"],
        
        "shin": ["shin", "sheen", "sh", "she", "chin", "shine", "sheep"],
        "shīn": ["shin", "sheen", "sh", "she"],
        
        "sad": ["sad", "saad", "s", "sod", "saw", "sud", "so", "sad"],
        "ṣād": ["sad", "saad", "s", "sod"],
        
        "dad": ["dad", "daad", "d", "dod", "dot", "dark", "that"],
        "ḍād": ["dad", "daad", "d", "dod"],
        
        "ayn": ["ayn", "ain", "ein", "eye", "ann", "ine", "i", "an", "iron"],
        "ʿayn": ["ayn", "ain", "ein", "eye"],
        
        "ghayn": ["ghayn", "ghain", "rain", "r", "gain", "gone", "gun", "grain"],
        
        "fa": ["fa", "fah", "faa", "f", "far", "fat", "for"],
        "fā": ["fa", "fah", "faa", "f"],
        
        "qaf": ["qaf", "qaph", "cough", "k", "kaf", "calf", "cuff", "quaff"],
        "qāf": ["qaf", "qaph", "cough", "k"],
        
        "kaf": ["kaf", "kaff", "calf", "k", "cap", "car", "cat", "cuff"],
        "kāf": ["kaf", "kaff", "calf", "k"],
        
        "lam": ["lam", "laam", "lamb", "l", "lum", "lime", "long", "lamb"],
        "lām": ["lam", "laam", "lamb", "l"],
        
        "mim": ["mim", "meem", "meme", "m", "me", "mum", "mem"],
        "mīm": ["mim", "meem", "meme", "m"],
        
        "nun": ["nun", "noon", "n", "none", "no", "non", "moon"],
        "nūn": ["nun", "noon", "n"],
        
        "waw": ["waw", "wow", "w", "war", "one", "whoa", "wall"],
        "wāw": ["waw", "wow", "w"],
        
        "ya": ["ya", "yaa", "yeah", "y", "yes", "you", "year"],
        "yā": ["ya", "yaa", "yeah", "y"]
    ]
    
    func isMatch(heard: String, target: ArabicLetter) -> Bool {
        let cleanHeard = cleanString(heard)
        if cleanHeard.isEmpty { return false }
        
        let cleanIsolated = cleanString(target.isolated)
        let cleanName = cleanString(target.name)
        let cleanTranslit = cleanString(target.transliteration)
        
        if cleanHeard.contains(cleanIsolated) { return true }
        if cleanHeard == cleanName { return true }
        if cleanHeard == cleanTranslit { return true }
        
        if let list = variants[cleanTranslit] {
            for variant in list {
                if cleanHeard.contains(variant) { return true }
            }
        }
        
        let translitWithoutAccents = target.transliteration.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        if let list = variants[translitWithoutAccents] {
            for variant in list {
                if cleanHeard.contains(variant) { return true }
            }
        }
        
        return false
    }
    
    private func cleanString(_ input: String) -> String {
        return input
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}
