import Foundation

enum LetterFormType: String, CaseIterable {
    case isolated = "Isolée"
    case initial = "Initiale"
    case medial = "Médiane"
    case final = "Finale"
    
    var description: String {
        switch self {
        case .isolated: return "Seule"
        case .initial: return "Début de mot"
        case .medial: return "Milieu de mot"
        case .final: return "Fin de mot"
        }
    }
    
    func localizedName(language: AppLanguage) -> String {
        switch language {
        case .english:
            switch self {
            case .isolated: return "Isolated"
            case .initial: return "Initial"
            case .medial: return "Medial"
            case .final: return "Final"
            }
        case .french:
            return self.rawValue
        }
    }
    
    func localizedDescription(language: AppLanguage) -> String {
        switch language {
        case .english:
            switch self {
            case .isolated: return "Alone"
            case .initial: return "Start of word"
            case .medial: return "Middle of word"
            case .final: return "End of word"
            }
        case .french:
            return self.description
        }
    }
    
    var strokeKey: String {
        switch self {
        case .isolated: return "isolated"
        case .initial: return "initial"
        case .medial: return "medial"
        case .final: return "final"
        }
    }

    func getForm(from letter: ArabicLetter) -> String {
        switch self {
        case .isolated: return letter.isolated
        case .initial: return letter.initial
        case .medial: return letter.medial
        case .final: return letter.final
        }
    }
    
    static func availableForms(for letterId: Int) -> [LetterFormType] {
        if letterId == 29 {
            return [.isolated, .final]
        }
        return LetterFormType.allCases
    }
}
