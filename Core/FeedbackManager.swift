import UIKit

final class FeedbackManager {
    static let shared = FeedbackManager()
    
    private init() {}
    
    func success() {
        HapticManager.shared.trigger(.success)
    }
    
    func error() {
        HapticManager.shared.trigger(.error)
    }
    
    func warning() {
        HapticManager.shared.trigger(.warning)
    }
    
    func tapLight() {
        HapticManager.shared.impact(.light)
    }
    
    func tapMedium() {
        HapticManager.shared.impact(.medium)
    }
}
