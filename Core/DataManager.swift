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
    @Published var isDhilly: Bool = UserDefaults.standard.bool(forKey: "isDhilly")
    
    func setDhilly() {
        isDhilly = true
        UserDefaults.standard.set(true, forKey: "isDhilly")
    }
    
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
    
    func shouldShowWeeklySummary() -> Bool {
        guard let progress = userProgress else { return false }
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let isMondayOrSundayEvening = weekday == 2 || (weekday == 1 && calendar.component(.hour, from: now) >= 20)
        guard isMondayOrSundayEvening else { return false }

        if let last = progress.lastWeeklySummaryDate {
            let lastMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: last))
            let currentMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            if lastMonday == currentMonday { return false }
        }

        let lastWeekXP = getLastWeekXP()
        return lastWeekXP > 0
    }

    func markWeeklySummarySeen() {
        userProgress?.lastWeeklySummaryDate = Date()
        try? modelContext?.save()
    }

    func getLastWeekXP() -> Int {
        guard let progress = userProgress else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total = 0
        for dayOffset in 1...7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                total += progress.dailyXP[formatter.string(from: date)] ?? 0
            }
        }
        return total
    }

    func getLastWeekActiveDays() -> Int {
        guard let progress = userProgress else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var count = 0
        for dayOffset in 1...7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                if (progress.dailyXP[formatter.string(from: date)] ?? 0) > 0 { count += 1 }
            }
        }
        return count
    }

    func getLastWeekDayActivity() -> [Bool] {
        guard let progress = userProgress else { return Array(repeating: false, count: 7) }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var result: [Bool] = []
        for dayOffset in (1...7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                result.append((progress.dailyXP[formatter.string(from: date)] ?? 0) > 0)
            } else {
                result.append(false)
            }
        }
        return result
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
            for checkpoint in GameConstants.Checkpoint.afterLevels {
                if levelNumber > checkpoint && levelNumber <= (GameConstants.Checkpoint.afterLevels.first(where: { $0 > checkpoint }) ?? 999) {
                    if !isCheckpointCompleted(afterLevel: checkpoint) {
                        let allBeforeCheckpoint = levels.filter { $0.levelNumber <= checkpoint }
                        if allBeforeCheckpoint.allSatisfy({ $0.isCompleted }) {
                            return .locked
                        }
                    }
                }
            }
            return .current
        }

        return .locked
    }

    func checkpointBlockingLevel(for levelNumber: Int) -> Int? {
        for checkpoint in GameConstants.Checkpoint.afterLevels {
            if levelNumber > checkpoint && !isCheckpointCompleted(afterLevel: checkpoint) {
                let allBefore = levels.filter { $0.levelNumber <= checkpoint }
                if allBefore.allSatisfy({ $0.isCompleted }) {
                    return checkpoint
                }
            }
        }
        return nil
    }

    func isCheckpointAvailable(afterLevel: Int) -> Bool {
        let levelsInBlock = levels.filter { $0.levelNumber <= afterLevel }
        return levelsInBlock.allSatisfy { $0.isCompleted } && !isCheckpointCompleted(afterLevel: afterLevel)
    }

    func isCheckpointCompleted(afterLevel: Int) -> Bool {
        userProgress?.completedCheckpoints.contains(afterLevel) ?? false
    }

    func completeCheckpoint(afterLevel: Int) {
        guard var checkpoints = userProgress?.completedCheckpoints else { return }
        if !checkpoints.contains(afterLevel) {
            checkpoints.append(afterLevel)
            userProgress?.completedCheckpoints = checkpoints
            userProgress?.addXP(GameConstants.Checkpoint.xpReward)
            try? modelContext?.save()
            progressTick += 1
            syncToWidget()
        }
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
            progress.name = ""
            progress.notificationsEnabled = true
        }
        
        for level in levels {
            level.isCompleted = false
            level.completedLetterIds = []
        }
        
        SRSEngine.shared.reset()
        
        for mistake in mistakes {
            modelContext?.delete(mistake)
        }
        mistakes.removeAll()
        
        try? modelContext?.save()
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.synchronize()
        
        print("Application data wiped. Exiting...")
        exit(0)
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

    func weakAreas() -> [(type: String, itemIds: [String], count: Int)] {
        let active = getActiveMistakes()
        var grouped: [String: [String]] = [:]
        for mistake in active {
            grouped[mistake.itemType, default: []].append(mistake.itemId)
        }
        return grouped.map { (type: $0.key, itemIds: Array(Set($0.value)), count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func completedLevels() -> [LevelProgress] {
        levels.filter { $0.isCompleted }.sorted { $0.levelNumber < $1.levelNumber }
    }

    func removeMistake(_ item: MistakeItem) {
        guard let context = modelContext else { return }
        context.delete(item)
        if let index = mistakes.firstIndex(where: { $0.id == item.id }) {
            mistakes.remove(at: index)
        }
        try? context.save()
    }
    
    func getWeakLetterIds() -> [Int] {
        let active = getActiveMistakes()
        let letterMistakes = active.filter { $0.itemType == "letter" }
        var freq: [Int: Int] = [:]
        for m in letterMistakes {
            if let id = Int(m.itemId) { freq[id, default: 0] += 1 }
        }
        return freq.sorted { $0.value > $1.value }.map { $0.key }
    }

    func getWeakWordIds() -> [Int] {
        let active = getActiveMistakes()
        let wordMistakes = active.filter { $0.itemType == "word" }
        var freq: [Int: Int] = [:]
        for m in wordMistakes {
            if let id = Int(m.itemId) { freq[id, default: 0] += 1 }
        }
        return freq.sorted { $0.value > $1.value }.map { $0.key }
    }

    func getPracticeRecommendation(isEnglish: Bool) -> PracticeRecommendation? {
        let active = getActiveMistakes()
        guard active.count >= 3 else { return nil }

        let weakLetterIds = getWeakLetterIds()
        let weakWordIds = getWeakWordIds()

        let weakLetters = weakLetterIds.prefix(3).compactMap { id in
            CourseContent.letters.first { $0.id == id }
        }
        let weakWords = weakWordIds.prefix(3).compactMap { id in
            CourseContent.words.first { $0.id == id }
        }

        let suggestedTool: String
        let letterCount = active.filter { $0.itemType == "letter" }.count
        let wordCount = active.filter { $0.itemType == "word" }.count
        if letterCount >= wordCount { suggestedTool = "mistakes" }
        else { suggestedTool = "flashcards" }

        let arabicItems = weakLetters.map { $0.isolated } + weakWords.prefix(2).map { $0.arabic }
        let itemsStr = arabicItems.prefix(3).joined(separator: ", ")

        let message: String
        if isEnglish {
            message = "Work on \(itemsStr) — they need practice!"
        } else {
            message = "Entraîne-toi sur \(itemsStr) — ça mérite du travail !"
        }

        return PracticeRecommendation(
            weakLetters: Array(weakLetters),
            weakWords: Array(weakWords),
            suggestedTool: suggestedTool,
            message: message
        )
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
        } else if progress.streakDays > 0 {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today)) {
                if #available(iOS 16.2, *) {
                    LiveActivityManager.shared.startStreakActivity(streak: progress.streakDays, deadline: tomorrow)
                }
            }
        } else {
            if #available(iOS 16.2, *) {
                LiveActivityManager.shared.stopStreakActivity()
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
