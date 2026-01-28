import Foundation
import SwiftData

/// Progression globale de l'utilisateur
@Model
final class UserProgress {
    var xpTotal: Int
    var streakDays: Int
    var lastActivityDate: Date?
    var totalLettersMastered: Int
    
    init(xpTotal: Int = 0, streakDays: Int = 0, lastActivityDate: Date? = nil, totalLettersMastered: Int = 0) {
        self.xpTotal = xpTotal
        self.streakDays = streakDays
        self.lastActivityDate = lastActivityDate
        self.totalLettersMastered = totalLettersMastered
    }
    
    /// Ajoute des XP et met à jour le streak
    func addXP(_ amount: Int) {
        xpTotal += amount
        updateStreak()
    }
    
    /// Met à jour le streak basé sur la date
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                // Même jour, rien à faire
            } else if daysDiff == 1 {
                // Jour suivant, on incrémente le streak
                streakDays += 1
            } else {
                // Plus d'un jour sans activité, reset
                streakDays = 1
            }
        } else {
            // Premier jour
            streakDays = 1
        }
        
        lastActivityDate = Date()
    }
    
    /// Incrémente le compteur de lettres maîtrisées
    func letterMastered() {
        totalLettersMastered += 1
        addXP(10) // 10 XP par lettre
    }
}
