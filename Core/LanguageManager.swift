import SwiftUI
import Combine // <-- C'est l'import qui manquait pour corriger l'erreur

// Définit les langues disponibles dans l'app
enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case english = "en"
    
    var id: String { rawValue }
    
    // Le nom affiché dans le menu
    var displayName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        }
    }
    
    // Le label spécifique pour ton contexte d'apprentissage
    var courseLabel: String {
        switch self {
        case .french: return "Français → Arabe"
        case .english: return "English → Arabic"
        }
    }
}

class LanguageManager: ObservableObject {
    // On sauvegarde le choix de l'utilisateur dans le téléphone (persistant)
    @AppStorage("user_language") private var storedLanguage: String?
    
    // La variable que les vues vont écouter pour se mettre à jour
    @Published var currentLanguage: AppLanguage
    
    init() {
        // 1. On vérifie si l'utilisateur a déjà choisi une langue manuellement
        if let stored = UserDefaults.standard.string(forKey: "user_language"),
           let lang = AppLanguage(rawValue: stored) {
            self.currentLanguage = lang
        } else {
            // 2. Sinon, on détecte la langue du téléphone (iOS)
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            if systemLang.contains("fr") {
                self.currentLanguage = .french
            } else {
                self.currentLanguage = .english // Par défaut international
            }
        }
    }
    
    // Fonction pour changer la langue
    func setLanguage(_ lang: AppLanguage) {
        withAnimation {
            currentLanguage = lang
            storedLanguage = lang.rawValue // Sauvegarde auto grâce à @AppStorage
            UserDefaults.standard.set(lang.rawValue, forKey: "user_language")
        }
    }
}
