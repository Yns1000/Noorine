import Foundation
import SwiftData
import Combine
import UserNotifications
import AVFoundation
import UIKit
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var modelContext: ModelContext?
    
    @Published var userProgress: UserProgress?
    @Published var levels: [LevelProgress] = []
    @Published var isAppReady: Bool = false
    
    private init() {}
    
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateUserProgress()
        loadOrCreateLevels()
        loadMistakes()
    }
    
    // MARK: - User Progress
    
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
        
        NotificationManager.shared.requestPermissions()
        NotificationManager.shared.scheduleAllNotifications()
    }
    
    func updateUserName(_ name: String) {
        userProgress?.name = name
        try? modelContext?.save()
        objectWillChange.send()
    }
    
    // MARK: - Levels
    
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
    
    // MARK: - Actions
    
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
        objectWillChange.send()
    }
    
    func addDailyChallengeXP(amount: Int) {
        userProgress?.addXP(amount)
        userProgress?.lastDailyChallengeDate = Date()
        try? modelContext?.save()
        objectWillChange.send()
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
    
    // MARK: - Developer Toolbox
    
    func devResetName() {
        userProgress?.name = "Apprenti"
        try? modelContext?.save()
        objectWillChange.send()
        HapticManager.shared.trigger(.success)
    }
    
    func devResetDailyChallenge() {
        userProgress?.lastDailyChallengeDate = nil
        try? modelContext?.save()
        objectWillChange.send()
        HapticManager.shared.trigger(.success)
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
        objectWillChange.send()
        HapticManager.shared.trigger(.success)
    }
    
    // MARK: - Mistakes Management
    
    @Published var mistakes: [MistakeItem] = []
    
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
        objectWillChange.send()
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
            objectWillChange.send()
            HapticManager.shared.trigger(.success)
            return true
        } else {
            try? context.save()
            objectWillChange.send()
            HapticManager.shared.impact(.light)
            return false
        }
    }
    
    func getMistakeCount() -> Int {
        return mistakes.count
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.scheduleAllNotifications()
            } else if let error = error {
                print("Erreur permissions notifications: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard DataManager.shared.userProgress?.notificationsEnabled == true else { return }
        
        scheduleDailyReminder()
        scheduleStreakWarning()
        scheduleInactivityEncouragement()
    }
    
    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = LanguageManager().localizedString("notification_daily_title")
        content.body = LanguageManager().localizedString("notification_daily_body")
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleStreakWarning() {
        let content = UNMutableNotificationContent()
        content.title = LanguageManager().localizedString("notification_streak_title")
        content.body = LanguageManager().localizedString("notification_streak_body")
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_warning", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleInactivityEncouragement() {
        let content3 = UNMutableNotificationContent()
        content3.title = LanguageManager().localizedString("notification_inactivity3_title")
        content3.body = LanguageManager().localizedString("notification_inactivity3_body")
        let trigger3 = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 3600, repeats: false)
        let request3 = UNNotificationRequest(identifier: "inactivity_3d", content: content3, trigger: trigger3)
        
        let content7 = UNMutableNotificationContent()
        content7.title = LanguageManager().localizedString("notification_inactivity7_title")
        content7.body = LanguageManager().localizedString("notification_inactivity7_body")
        let trigger7 = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 3600, repeats: false)
        let request7 = UNNotificationRequest(identifier: "inactivity_7d", content: content7, trigger: trigger7)
        
        UNUserNotificationCenter.current().add(request7)
    }
    
    // MARK: - Test Notifications (Development)
    
    func triggerTestNotification(_ type: TestNotificationType) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        switch type {
        case .dailyReminder:
            content.title = LanguageManager().localizedString("notification_daily_title")
            content.body = LanguageManager().localizedString("notification_daily_body")
        case .streakWarning:
            content.title = LanguageManager().localizedString("notification_streak_title")
            content.body = LanguageManager().localizedString("notification_streak_body")
        case .inactivity3Days:
            content.title = LanguageManager().localizedString("notification_inactivity3_title")
            content.body = LanguageManager().localizedString("notification_inactivity3_body")
        case .inactivity7Days:
            content.title = LanguageManager().localizedString("notification_inactivity7_title")
            content.body = LanguageManager().localizedString("notification_inactivity7_body")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_\(type.rawValue)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test notification error: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled: \(type.rawValue)")
            }
        }
    }
    
    enum TestNotificationType: String, CaseIterable {
        case dailyReminder = "daily_reminder"
        case streakWarning = "streak_warning"
        case inactivity3Days = "inactivity_3d"
        case inactivity7Days = "inactivity_7d"
        
        var displayName: String {
            switch self {
            case .dailyReminder: return LanguageManager().localizedString("Test Rappel Quotidien")
            case .streakWarning: return LanguageManager().localizedString("Test Alerte Flamme")
            case .inactivity3Days: return LanguageManager().localizedString("Test Inactivité 3j")
            case .inactivity7Days: return LanguageManager().localizedString("Test Inactivité 7j")
            }
        }
        
        var icon: String {
            switch self {
            case .dailyReminder: return "bell.fill"
            case .streakWarning: return "flame.fill"
            case .inactivity3Days: return "clock.badge.questionmark"
            case .inactivity7Days: return "calendar.badge.exclamationmark"
            }
        }
        
        var color: Color {
            switch self {
            case .dailyReminder: return .blue
            case .streakWarning: return .orange
            case .inactivity3Days: return .purple
            case .inactivity7Days: return .red
            }
        }
    }
}

class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard DataManager.shared.userProgress?.hapticsEnabled == true else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard DataManager.shared.userProgress?.hapticsEnabled == true else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch {
            print("Erreur initialisation session audio: \(error)")
        }
    }
    
    func playSound(_ name: String) {
        guard DataManager.shared.userProgress?.soundEnabled == true else { return }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ?? 
                Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Erreur lecture son: \(error.localizedDescription)")
        }
    }
    
    func playLetter(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let arabicVoices = voices.filter { $0.language == "ar-SA" }
        
        if let enhancedVoice = arabicVoices.first(where: { $0.quality == .enhanced }) {
            utterance.voice = enhancedVoice
        } else if let maged = arabicVoices.first(where: { $0.name.contains("Maged") }) {
            utterance.voice = maged
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        }
        
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        synthesizer.speak(utterance)
    }
    
    func playSystemSound(_ soundID: SystemSoundID) {
        guard DataManager.shared.userProgress?.soundEnabled == true else { return }
        AudioServicesPlaySystemSound(soundID)
    }
}
