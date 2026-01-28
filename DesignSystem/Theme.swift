import SwiftUI

extension Color {
    // MARK: - Core Brand Colors
    
    /// Or lumineux (Le cœur de la marque)
    static let noorGold = Color(red: 1.0, green: 0.84, blue: 0.40)
    
    /// Or plus chaud pour les accents
    static let noorGoldDark = Color(red: 0.92, green: 0.72, blue: 0.25)
    
    /// Bleu nuit profond (Utilisé pour des éléments graphiques fixes)
    static let noorDark = Color(red: 0.08, green: 0.12, blue: 0.18)
    
    // MARK: - Adaptive Colors
    
    /// Fond adaptatif (Crème le jour, Bleu nuit très sombre la nuit)
    static var noorBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1) 
                : UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1)
        })
    }
    
    /// Texte adaptatif (Bleu nuit le jour, Crème la nuit)
    static var noorText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.95, green: 0.90, blue: 0.80, alpha: 1) 
                : UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1)
        })
    }
    
    /// Gris secondaire adaptatif
    static var noorSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.6, green: 0.65, blue: 0.7, alpha: 1) 
                : UIColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)
        })
    }
    
    // MARK: - Status Colors
    
    /// Vert succès
    static let noorSuccess = Color(red: 0.35, green: 0.78, blue: 0.55)
    
    /// Orange avertissement
    static let noorWarning = Color(red: 1.0, green: 0.65, blue: 0.35)
    
    /// Rouge erreur
    static let noorError = Color(red: 0.95, green: 0.40, blue: 0.45)
}

// MARK: - Gradient Helpers
extension LinearGradient {
    /// Gradient doré premium
    static var noorGoldGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorGold, Color.noorGoldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Gradient de fond mystique
    static var noorMysticGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorDark, Color.noorDark.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
