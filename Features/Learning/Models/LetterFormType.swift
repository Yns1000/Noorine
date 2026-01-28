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
    
    func getForm(from letter: ArabicLetter) -> String {
        switch self {
        case .isolated: return letter.isolated
        case .initial: return letter.initial
        case .medial: return letter.medial
        case .final: return letter.final
        }
    }
}
