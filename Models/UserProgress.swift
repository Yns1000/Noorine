import Foundation
import SwiftData

@Model
final class UserProgress {
    var name: String = ""
    var xpTotal: Int
    var streakDays: Int
    var lastActivityDate: Date?
    var totalLettersMastered: Int
    var weeklyActivityIndices: [Int] = []
    var dailyXP: [String: Int] = [:]
    var installationDate: Date = Date()
    var achievements: [String] = []
    var lastResetDate: Date?
    var notificationsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
    var lastDailyChallengeDate: Date?
    
    init(name: String = "", xpTotal: Int = 0, streakDays: Int = 0, lastActivityDate: Date? = nil, totalLettersMastered: Int = 0, weeklyActivityIndices: [Int] = [], dailyXP: [String: Int] = [:], installationDate: Date = Date(), achievements: [String] = [], lastResetDate: Date? = nil, notificationsEnabled: Bool = true, hapticsEnabled: Bool = true, soundEnabled: Bool = true) {
        self.name = name
        self.xpTotal = xpTotal
        self.streakDays = streakDays
        self.lastActivityDate = lastActivityDate
        self.totalLettersMastered = totalLettersMastered
        self.weeklyActivityIndices = weeklyActivityIndices
        self.dailyXP = dailyXP
        self.installationDate = installationDate
        self.achievements = achievements
        self.lastResetDate = lastResetDate
        self.notificationsEnabled = notificationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.lastDailyChallengeDate = nil
    }
    
    enum AchievementID: String, CaseIterable {
        case beginner = "beginner"
        case persistent = "persistent"
        case expert = "expert"
        case alphabetic = "alphabetic"
        case weeklyHero = "weeklyHero"
        case scholar = "scholar"
        case committed = "committed"
        case sage = "sage"
    }
    
    func checkAchievements() {
        if xpTotal > 0 { unlock(.beginner) }
        if streakDays >= 3 { unlock(.persistent) }
        if streakDays >= 7 { unlock(.committed) }
        if xpTotal >= 100 { unlock(.expert) }
        if xpTotal >= 500 { unlock(.scholar) }
        if xpTotal >= 1000 { unlock(.sage) }
        if totalLettersMastered >= 10 { unlock(.alphabetic) }
        if currentWeekXP() >= 50 { unlock(.weeklyHero) }
    }
    
    private func unlock(_ id: AchievementID) {
        if !achievements.contains(id.rawValue) {
            achievements.append(id.rawValue)
        }
    }
    
    func checkWeeklyReset() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let currentMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return }
        
        if let lastReset = lastResetDate {
            let lastResetMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastReset))
            
            if lastResetMonday != currentMonday {
                performWeeklyReset(on: currentMonday)
            }
        } else {
            performWeeklyReset(on: currentMonday)
        }
    }
    
    private func performWeeklyReset(on monday: Date) {
        weeklyActivityIndices = []
        lastResetDate = monday
    }
    
    func addXP(_ amount: Int) {
        xpTotal += amount
        
        let dateKey = formatDate(Date())
        dailyXP[dateKey, default: 0] += amount
        
        updateStreak()
        checkAchievements()
    }
    
    func currentWeekXP() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var total = 0
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let key = formatDate(date)
                total += dailyXP[key] ?? 0
            }
        }
        return total
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let todayDate = Date()
        let today = calendar.startOfDay(for: todayDate)
        
        let weekday = calendar.component(.weekday, from: todayDate)
        if !weeklyActivityIndices.contains(weekday) {
            if let lastDate = lastActivityDate {
                let lastWeek = calendar.component(.weekOfYear, from: lastDate)
                let currentWeek = calendar.component(.weekOfYear, from: todayDate)
                if lastWeek != currentWeek {
                    weeklyActivityIndices = []
                }
            }
            weeklyActivityIndices.append(weekday)
        }
        
        if let lastDate = lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
            } else if daysDiff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        
        lastActivityDate = Date()
    }
    
    func letterMastered() {
        totalLettersMastered += 1
        addXP(10)
    }
}

@Model
final class MistakeItem {
    var itemId: String
    var itemType: String
    var formType: String?
    var correctionCount: Int
    var lastMistakeDate: Date
    
    init(itemId: String, itemType: String, formType: String? = nil, correctionCount: Int = 0, lastMistakeDate: Date = Date()) {
        self.itemId = itemId
        self.itemType = itemType
        self.formType = formType
        self.correctionCount = correctionCount
        self.lastMistakeDate = lastMistakeDate
    }
}
