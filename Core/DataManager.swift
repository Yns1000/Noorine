import Foundation
import SwiftData
import Combine

/// Gestionnaire central des données de l'application
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var modelContext: ModelContext?
    
    @Published var userProgress: UserProgress?
    @Published var levels: [LevelProgress] = []
    
    private init() {}
    
    /// Configure le contexte SwiftData
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateUserProgress()
        loadOrCreateLevels()
    }
    
    // MARK: - User Progress
    
    private func loadOrCreateUserProgress() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserProgress>()
        if let existing = try? context.fetch(descriptor).first {
            userProgress = existing
        } else {
            let newProgress = UserProgress()
            context.insert(newProgress)
            userProgress = newProgress
            try? context.save()
        }
    }
    
    // MARK: - Levels
    
    private func loadOrCreateLevels() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<LevelProgress>(sortBy: [SortDescriptor(\.levelNumber)])
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            levels = existing
        } else {
            // Créer les 4 niveaux par défaut
            for levelData in LevelProgress.defaultLevels {
                let level = LevelProgress(
                    levelNumber: levelData.number,
                    title: levelData.title,
                    subtitle: levelData.subtitle
                )
                context.insert(level)
                levels.append(level)
            }
            try? context.save()
        }
    }
    
    // MARK: - Actions
    
    /// Marque une lettre comme maîtrisée dans un niveau
    func completeLetter(letterId: Int, inLevel levelNumber: Int) {
        guard let context = modelContext,
              let level = levels.first(where: { $0.levelNumber == levelNumber }),
              !level.completedLetterIds.contains(letterId) else { return }
        
        level.completedLetterIds.append(letterId)
        userProgress?.letterMastered()
        
        // Vérifie si le niveau est complété
        let totalLetters = ArabicLetter.letters(forLevel: levelNumber).count
        if level.completedLetterIds.count >= totalLetters {
            level.isCompleted = true
            userProgress?.addXP(50) // Bonus de niveau complété
        }
        
        try? context.save()
        objectWillChange.send()
    }
    
    /// Récupère l'état d'un niveau
    func levelState(for levelNumber: Int) -> LevelState {
        guard let level = levels.first(where: { $0.levelNumber == levelNumber }) else {
            return .locked
        }
        
        if level.isCompleted {
            return .completed
        }
        
        // Le premier niveau est toujours débloqué
        if levelNumber == 1 {
            return .current
        }
        
        // Un niveau est débloqué si le précédent est complété
        if let previousLevel = levels.first(where: { $0.levelNumber == levelNumber - 1 }),
           previousLevel.isCompleted {
            return .current
        }
        
        return .locked
    }
    
    /// Vérifie si une lettre est maîtrisée
    func isLetterMastered(letterId: Int, inLevel levelNumber: Int) -> Bool {
        levels.first(where: { $0.levelNumber == levelNumber })?.completedLetterIds.contains(letterId) ?? false
    }
    
    /// Récupère le niveau actuel (premier non complété)
    var currentLevelNumber: Int {
        for level in levels.sorted(by: { $0.levelNumber < $1.levelNumber }) {
            if !level.isCompleted {
                return level.levelNumber
            }
        }
        return levels.count
    }
}
