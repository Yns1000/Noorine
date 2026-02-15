import Foundation
import SwiftData
import Combine
import SwiftUI
import WidgetKit

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var modelContext: ModelContext?
    
    @Published var userProgress: UserProgress?
    @Published var levels: [LevelProgress] = []
    @Published var isAppReady: Bool = false
    @Published var progressTick: Int = 0
    @Published var practiceUnlocked: Bool = false
    
    @Published var mistakeCount: Int = 0
    @Published var requestedLevelId: Int?
    
    @Published var mistakes: [MistakeItem] = []
    
    private init() {}
    
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateUserProgress()
        loadOrCreateLevels()
        loadMistakes()
        CourseContent.validateAndLog()
        syncHapticPreference()
        syncToWidget()
        syncWordOfDay()
    }

    func syncHapticPreference() {
        HapticManager.shared.isEnabled = userProgress?.hapticsEnabled ?? true
    }
    
    func refreshCourseContent() {
        CourseContent.reload()
        loadOrCreateLevels()
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
        if let existing = try? context.fetch(descriptor) {
            levels = existing
            
            let allDefinedLevels = CourseContent.getLevels(language: .french)
            for levelDef in allDefinedLevels {
                if let existingLevel = levels.first(where: { $0.levelNumber == levelDef.id }) {
                    if existingLevel.title != levelDef.titleKey || 
                       existingLevel.subtitle != levelDef.subtitle ||
                       existingLevel.type != levelDef.type.rawValue {
                        
                        existingLevel.title = levelDef.titleKey
                        existingLevel.subtitle = levelDef.subtitle
                        existingLevel.type = levelDef.type.rawValue
                    }
                } else {
                    let newLevel = LevelProgress(
                        levelNumber: levelDef.id,
                        title: levelDef.titleKey,
                        subtitle: levelDef.subtitle,
                        type: levelDef.type.rawValue
                    )
                    context.insert(newLevel)
                    levels.append(newLevel)
                }
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
            userProgress?.addXP(GameConstants.XP.allLettersCompleted)
        }
        
        try? context.save()
        progressTick += 1
        syncToWidget()
    }
    
    func completeLevel(levelNumber: Int) {
        guard let context = modelContext,
              let level = levels.first(where: { $0.levelNumber == levelNumber }),
              !level.isCompleted else { return }
        
        level.isCompleted = true
        userProgress?.addXP(GameConstants.XP.levelCompleted)
        try? context.save()
        progressTick += 1
        syncToWidget()
    }
    
    func unlockAllLevels() {
        guard let context = modelContext else { return }
        for level in levels {
            level.isCompleted = true
        }
        try? context.save()
        progressTick += 1
    }
    
    func addDailyChallengeXP(amount: Int) {
        userProgress?.addXP(amount)
        userProgress?.lastDailyChallengeDate = Date()
        try? modelContext?.save()
        syncToWidget()
    }
    
    func dismissDailyChallenge() {
        userProgress?.lastDailyChallengeDismissedDate = Date()
        try? modelContext?.save()
    }
    
    func isDailyChallengeCompletedToday() -> Bool {
        guard let progress = userProgress,
              let lastDate = progress.lastDailyChallengeDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
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
        
        if let lastDate = progress.lastDailyChallengeDate, Calendar.current.isDateInToday(lastDate) {
            return false
        }
        
        if let dismissed = progress.lastDailyChallengeDismissedDate, Calendar.current.isDateInToday(dismissed) {
            return false
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
        userProgress?.lastDailyChallengeDismissedDate = nil
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
        progressTick += 1
    }
    
    
    private func loadMistakes() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<MistakeItem>()
        if let items = try? context.fetch(descriptor) {
            mistakes = items
            cleanupOldMasteredItems()
        }
    }
    
    func addMistake(itemId: String, type: String, formType: String? = nil) {
        guard let context = modelContext else { return }
        
        if let existing = mistakes.first(where: { $0.itemId == itemId && $0.itemType == type && $0.formType == formType }) {
            if existing.isInGracePeriod() {
                return
            }
            existing.correctionCount = 0
            existing.lastMistakeDate = Date()
            existing.masteredDate = nil
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
        
        if item.correctionCount >= GameConstants.Mistakes.correctionsToMaster {
            item.masteredDate = Date()
            try? context.save()
            return true
        } else {
            try? context.save()
            return false
        }
    }
    
    func getMistakeCount() -> Int {
        return mistakes.filter { !$0.isMastered }.count
    }
    
    func getActiveMistakes() -> [MistakeItem] {
        return mistakes.filter { !$0.isMastered }
    }

    func removeMistake(_ item: MistakeItem) {
        guard let context = modelContext else { return }
        context.delete(item)
        if let index = mistakes.firstIndex(where: { $0.id == item.id }) {
            mistakes.remove(at: index)
        }
        try? context.save()
    }
    
    func cleanupOldMasteredItems() {
        guard let context = modelContext else { return }
        
        let itemsToRemove = mistakes.filter { item in
            guard let mastered = item.masteredDate else { return false }
            return Date().timeIntervalSince(mastered) > TimeInterval(GameConstants.Mistakes.masteredCleanupHours * 60 * 60)
        }
        
        for item in itemsToRemove {
            context.delete(item)
            if let index = mistakes.firstIndex(where: { $0.id == item.id }) {
                mistakes.remove(at: index)
            }
        }
        
        if !itemsToRemove.isEmpty {
            try? context.save()
        }
    }

    func syncToWidget() {
        guard let progress = userProgress else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        let todayXP = progress.dailyXP[todayKey] ?? 0

        SharedDataStore.sync(
            streakDays: progress.streakDays,
            xpTotal: progress.xpTotal,
            currentWeekXP: progress.currentWeekXP(),
            todayXP: todayXP,
            userName: progress.name.isEmpty ? "Apprenti" : progress.name
        )

        WidgetCenter.shared.reloadAllTimelines()
        
        manageStreakActivity()
    }
    
    func manageStreakActivity() {
        guard let progress = userProgress else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        let isStreakSafeToday: Bool
        if let lastDate = progress.lastActivityDate {
            isStreakSafeToday = calendar.isDateInToday(lastDate)
        } else {
            isStreakSafeToday = false
        }
        
        if isStreakSafeToday {
            if #available(iOS 16.2, *) {
                LiveActivityManager.shared.stopStreakActivity()
            }
        } else {            
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today)) {
                if #available(iOS 16.2, *) {
                    LiveActivityManager.shared.startStreakActivity(streak: progress.streakDays, deadline: tomorrow)
                }
            }
        }
    }

    func syncWordOfDay() {
        let words = CourseContent.words
        guard !words.isEmpty else { return }

        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % words.count
        let word = words[index]

        SharedDataStore.syncWordOfDay(
            arabic: word.arabic,
            transliteration: word.transliteration,
            translationFr: word.translationFr,
            translationEn: word.translationEn
        )
    }
}
