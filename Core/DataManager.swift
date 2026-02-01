import Foundation
import SwiftData
import Combine
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var modelContext: ModelContext?
    
    @Published var userProgress: UserProgress?
    @Published var levels: [LevelProgress] = []
    @Published var isAppReady: Bool = false
    
    @Published var mistakes: [MistakeItem] = []
    
    private init() {}
    
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateUserProgress()
        loadOrCreateLevels()
        loadMistakes()
    }
        
    private func loadOrCreateUserProgress() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserProgress>()
        if let existing = try? context.fetch(descriptor).first {
            userProgress = existing
            
            existing.checkWeeklyReset()
            existing.checkAchievements()
            
            if existing.xpTotal > 0 && existing.dailyXP.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let key = formatter.string(from: Date())
                existing.dailyXP[key] = existing.xpTotal
                
                let weekday = Calendar.current.component(.weekday, from: Date())
                if !existing.weeklyActivityIndices.contains(weekday) {
                    existing.weeklyActivityIndices.append(weekday)
                }
                
                try? context.save()
            }
        } else {
            let newProgress = UserProgress()
            context.insert(newProgress)
            userProgress = newProgress
            try? context.save()
        }
        
    }
    
    func updateUserName(_ name: String) {
        userProgress?.name = name
        try? modelContext?.save()
    }
    
    
    private func loadOrCreateLevels() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<LevelProgress>(sortBy: [SortDescriptor(\.levelNumber)])
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            levels = existing
        } else {
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
    
    
    func completeLetter(letterId: Int, inLevel levelNumber: Int) {
        guard let context = modelContext,
              let level = levels.first(where: { $0.levelNumber == levelNumber }),
              !level.completedLetterIds.contains(letterId) else { return }
        
        level.completedLetterIds.append(letterId)
        userProgress?.letterMastered()
        
        let totalLetters = ArabicLetter.letters(forLevel: levelNumber).count
        if level.completedLetterIds.count >= totalLetters {
            level.isCompleted = true
            userProgress?.addXP(50)
        }
        
        try? context.save()
    }
    
    func addDailyChallengeXP(amount: Int) {
        userProgress?.addXP(amount)
        userProgress?.lastDailyChallengeDate = Date()
        try? modelContext?.save()
    }
    
    func getMasteredLetters() -> [ArabicLetter] {
        let completedLevelsNumbers = levels.filter { $0.isCompleted }.map { $0.levelNumber }
        var letters: [ArabicLetter] = []
        for levelNum in completedLevelsNumbers {
            letters.append(contentsOf: ArabicLetter.letters(forLevel: levelNum))
        }
        return letters
    }
    
    func canShowDailyChallenge() -> Bool {
        guard let progress = userProgress else { return false }
        
        let hasStarted = progress.xpTotal > 0 || levels.contains(where: { $0.isCompleted })
        guard hasStarted else { return false }
        
        if let lastDate = progress.lastDailyChallengeDate {
            return !Calendar.current.isDateInToday(lastDate)
        }
        
        return true
    }
    
    func levelState(for levelNumber: Int) -> LevelState {
        guard let level = levels.first(where: { $0.levelNumber == levelNumber }) else {
            return .locked
        }
        
        if level.isCompleted {
            return .completed
        }
        
        if levelNumber == 1 {
            return .current
        }
        
        if let previousLevel = levels.first(where: { $0.levelNumber == levelNumber - 1 }),
           previousLevel.isCompleted {
            return .current
        }
        
        return .locked
    }
    
    func isLetterMastered(letterId: Int, inLevel levelNumber: Int) -> Bool {
        levels.first(where: { $0.levelNumber == levelNumber })?.completedLetterIds.contains(letterId) ?? false
    }
    
    var currentLevelNumber: Int {
        for level in levels.sorted(by: { $0.levelNumber < $1.levelNumber }) {
            if !level.isCompleted {
                return level.levelNumber
            }
        }
        return levels.count
    }
    
    
    func devResetName() {
        userProgress?.name = "Apprenti"
        try? modelContext?.save()
    }
    
    func devResetDailyChallenge() {
        userProgress?.lastDailyChallengeDate = nil
        try? modelContext?.save()
    }
    
    func devResetAllProgress() {
        if let progress = userProgress {
            progress.xpTotal = 0
            progress.streakDays = 0
            progress.lastActivityDate = nil
            progress.totalLettersMastered = 0
            progress.weeklyActivityIndices = []
            progress.dailyXP = [:]
            progress.lastDailyChallengeDate = nil
            progress.achievements = []
        }
        
        for level in levels {
            level.isCompleted = false
            level.completedLetterIds = []
        }
        
        try? modelContext?.save()
    }
    
    
    private func loadMistakes() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<MistakeItem>()
        if let items = try? context.fetch(descriptor) {
            mistakes = items
        }
    }
    
    func addMistake(itemId: String, type: String, formType: String? = nil) {
        guard let context = modelContext else { return }
        
        if let existing = mistakes.first(where: { $0.itemId == itemId && $0.itemType == type && $0.formType == formType }) {
            existing.correctionCount = 0
            existing.lastMistakeDate = Date()
        } else {
            let mistake = MistakeItem(itemId: itemId, itemType: type, formType: formType)
            context.insert(mistake)
            mistakes.append(mistake)
        }
        
        try? context.save()
    }
    
    func recordMistakeSuccess(item: MistakeItem) -> Bool {
        guard let context = modelContext else { return false }
        
        item.correctionCount += 1
        
        if item.correctionCount >= 2 {
            context.delete(item)
            if let index = mistakes.firstIndex(where: { $0.id == item.id }) {
                mistakes.remove(at: index)
            }
            try? context.save()
            return true
        } else {
            try? context.save()
            return false
        }
    }
    
    func getMistakeCount() -> Int {
        return mistakes.count
    }
}
