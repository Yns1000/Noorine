import SwiftUI

extension Color {    
    static let noorGold = Color(red: 1.0, green: 0.84, blue: 0.40)
    static let noorGoldDark = Color(red: 0.92, green: 0.72, blue: 0.25)
    static let noorDark = Color(red: 0.08, green: 0.12, blue: 0.18)
    
    static var noorBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1) 
                : UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1)
        })
    }
    
    static var noorText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.95, green: 0.90, blue: 0.80, alpha: 1) 
                : UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1)
        })
    }
    
    static var noorSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.6, green: 0.65, blue: 0.7, alpha: 1) 
                : UIColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)
        })
    }
        
    static let noorSuccess = Color(red: 0.35, green: 0.78, blue: 0.55)
    static let noorWarning = Color(red: 1.0, green: 0.65, blue: 0.35)
    static let noorError = Color(red: 0.95, green: 0.40, blue: 0.45)
}


extension LinearGradient {
    static var noorGoldGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorGold, Color.noorGoldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var noorMysticGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorDark, Color.noorDark.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
