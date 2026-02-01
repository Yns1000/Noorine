import Foundation
import UserNotifications
import SwiftUI

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
