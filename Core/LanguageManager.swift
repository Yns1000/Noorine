import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case english = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        }
    }
    
    var courseLabel: String {
        switch self {
        case .french: return "Cours d'arabe pour francophones"
        case .english: return "Arabic course for English speakers"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let userDefaultsKey = "selectedLanguage"
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: userDefaultsKey)
        }
    }
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .french
        }
    }
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
