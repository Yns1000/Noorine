import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notifications : Permission accordée")
                self.scheduleAllNotifications()
            } else if let error = error {
                print("Erreur permissions notifications: \(error.localizedDescription)")
            }
        }
    }
    
    
    func scheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard DataManager.shared.userProgress?.notificationsEnabled == true else { return }
        
        let userName = DataManager.shared.userProgress?.name ?? ""
        let nameToUse = userName.isEmpty ? (LanguageManager.shared.currentLanguage == .english ? "friend" : "l'ami") : userName
        
        for dayOffset in 1...20 {
            scheduleDailyMix(dayOffset: dayOffset, userName: nameToUse)
        }
        
        scheduleInactivityEncouragement(userName: nameToUse)
        
        print("Scheduled 20 days of personalized notifications for \(nameToUse)")
    }
    
    private func scheduleDailyMix(dayOffset: Int, userName: String) {
        let morningContent = NotificationLibrary.morning.randomElement()!
        scheduleNotification(
            identifier: "morning_\(dayOffset)",
            content: morningContent,
            dayOffset: dayOffset,
            hour: 9,
            minute: Int.random(in: 0...30),
            userName: userName
        )
        
        if dayOffset % 2 == 0 {
            let eveningContent = NotificationLibrary.evening.randomElement()!
            scheduleNotification(
                identifier: "evening_\(dayOffset)",
                content: eveningContent,
                dayOffset: dayOffset,
                hour: 18,
                minute: Int.random(in: 30...59),
                userName: userName
            )
        }
        
        let streakContent = NotificationLibrary.streakWarning.randomElement()!
        scheduleNotification(
            identifier: "streak_\(dayOffset)",
            content: streakContent,
            dayOffset: dayOffset,
            hour: 21,
            minute: 30,
            userName: userName
        )

        if DataManager.shared.isDhilly {
            let dhillyContent = NotificationLibrary.dhillySpecial.randomElement()!
            scheduleNotification(
                identifier: "dhilly_\(dayOffset)",
                content: dhillyContent,
                dayOffset: dayOffset,
                hour: Int.random(in: 13...16),
                minute: Int.random(in: 0...59),
                userName: userName
            )
        }
    }
    
    private func scheduleInactivityEncouragement(userName: String) {
        let content3 = NotificationLibrary.inactivity3Days.randomElement()!
        scheduleNotification(identifier: "inactivity_3d", content: content3, dayOffset: 3, hour: 11, minute: 0, userName: userName)
        
        let content7 = NotificationLibrary.inactivity7Days.randomElement()!
        scheduleNotification(identifier: "inactivity_7d", content: content7, dayOffset: 7, hour: 16, minute: 0, userName: userName)
    }
    
    private func scheduleNotification(identifier: String, content: NotificationContent, dayOffset: Int, hour: Int, minute: Int, userName: String) {
        let notifContent = UNMutableNotificationContent()
        notifContent.title = personalized(content.title, name: userName)
        notifContent.body = personalized(content.body, name: userName)
        notifContent.sound = .default
        
        var dateComponents = DateComponents()
        if let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
            dateComponents.year = components.year
            dateComponents.month = components.month
            dateComponents.day = components.day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func personalized(_ text: String, name: String) -> String {
        return text.replacingOccurrences(of: "[name]", with: name)
    }
        
    func triggerTestNotification(_ type: TestNotificationType) {
        let userName = DataManager.shared.userProgress?.name ?? "TestUser"
        let content: NotificationContent
        
        switch type {
        case .dailyReminder: content = NotificationLibrary.morning.randomElement()!
        case .streakWarning: content = NotificationLibrary.streakWarning.randomElement()!
        case .inactivity3Days: content = NotificationLibrary.inactivity3Days.randomElement()!
        case .inactivity7Days: content = NotificationLibrary.inactivity7Days.randomElement()!
        case .dhillySpecial: content = NotificationLibrary.dhillySpecial.randomElement()!
        }
        
        let notifContent = UNMutableNotificationContent()
        notifContent.title = personalized(content.title, name: userName)
        notifContent.body = personalized(content.body, name: userName)
        notifContent.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_\(type.rawValue)", content: notifContent, trigger: trigger)
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.requestPermissions()
            }
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Test notification error: \(error.localizedDescription)")
                } else {
                    print("Test notification '\(type.rawValue)' scheduled in 5s")
                }
            }
        }
    }
    
    enum TestNotificationType: String, CaseIterable {
        case dailyReminder = "daily_reminder"
        case streakWarning = "streak_warning"
        case inactivity3Days = "inactivity_3d"
        case inactivity7Days = "inactivity_7d"
        case dhillySpecial = "dhilly_special"

        var displayName: String {
            switch self {
            case .dailyReminder: return LanguageManager.shared.currentLanguage == .english ? "Test Morning" : "Test Matin"
            case .streakWarning: return LanguageManager.shared.currentLanguage == .english ? "Test Streak" : "Test Flamme"
            case .inactivity3Days: return LanguageManager.shared.currentLanguage == .english ? "Test Inactivity 3d" : "Test Inactivité 3j"
            case .inactivity7Days: return LanguageManager.shared.currentLanguage == .english ? "Test Inactivity 7d" : "Test Inactivité 7j"
            case .dhillySpecial: return "Test Laurine"
            }
        }

        var icon: String {
            switch self {
            case .dailyReminder: return "sun.max.fill"
            case .streakWarning: return "flame.fill"
            case .inactivity3Days: return "clock.badge.exclamationmark"
            case .inactivity7Days: return "calendar.badge.exclamationmark"
            case .dhillySpecial: return "heart.fill"
            }
        }

        var color: Color {
            switch self {
            case .dailyReminder: return .orange
            case .streakWarning: return .red
            case .inactivity3Days: return .purple
            case .inactivity7Days: return .gray
            case .dhillySpecial: return .pink
            }
        }
    }
}


struct NotificationContent {
    let title: String
    let body: String
}

struct NotificationLibrary {
    static var isEnglish: Bool { LanguageManager.shared.currentLanguage == .english }
    
    static var morning: [NotificationContent] {
        if isEnglish {
            return [
                NotificationContent(title: "Sabah el kher [name]! ☀️", body: "Start your day with just 5 min of Arabic. You got this!"),
                NotificationContent(title: "Ready, [name]? ☕️", body: "Your daily lesson is waiting. Let's make progress inside Noorine."),
                NotificationContent(title: "Good morning [name]!", body: "A little Arabic with your coffee? Perfect combination ☕️"),
                NotificationContent(title: "Marhaba [name]! 👋", body: "Consistency is key. One small lesson today = big results later.")
            ]
        } else {
            return [
                NotificationContent(title: "Sabah el kher [name] ! ☀️", body: "Commence ta journée avec 5 min d'arabe. Tu peux le faire !"),
                NotificationContent(title: "Prêt(e), [name] ? ☕️", body: "Ta leçon du jour t'attend. On progresse ensemble sur Noorine."),
                NotificationContent(title: "Bonjour [name] !", body: "Un peu d'arabe avec ton café ? Le combo parfait ☕️"),
                NotificationContent(title: "Marhaba [name] ! 👋", body: "La régularité est la clé. Une petite leçon aujourd'hui = de grands résultats.")
            ]
        }
    }
    
    static var evening: [NotificationContent] {
        if isEnglish {
            return [
                NotificationContent(title: "Masa el kher [name] 🌙", body: "Wrap up your day with a quick win. Your brain will thank you!"),
                NotificationContent(title: "5 minutes for you, [name]", body: "Unwind and learn something new before bed."),
                NotificationContent(title: "Evening check-in [name] ✨", body: "Did you practice today? There's still time to keep the momentum!"),
                NotificationContent(title: "Noorine is waiting... 🦉", body: "A quick session before sleep helps memory retention, [name]!")
            ]
        } else {
            return [
                NotificationContent(title: "Masa el kher [name] 🌙", body: "Finis ta journée sur une victoire. Ton cerveau te remerciera !"),
                NotificationContent(title: "5 minutes pour toi, [name]", body: "Détends-toi et apprends quelque chose de nouveau avant de dormir."),
                NotificationContent(title: "Petit coucou [name] ✨", body: "As-tu pratiqué aujourd'hui ? Il est encore temps !"),
                NotificationContent(title: "Noorine t'attend... 🦉", body: "Une petite session avant de dormir aide à la mémorisation, [name] !")
            ]
        }
    }
    
    static var streakWarning: [NotificationContent] {
        if isEnglish {
            return [
                NotificationContent(title: "🔥 Streak Danger [name]!", body: "You're about to lose your streak! Save it now with a quick lesson."),
                NotificationContent(title: "Don't break the chain! ⛓️", body: "Hey [name], protect your hard work. Do one lesson now."),
                NotificationContent(title: "Emergency Alert 🚨", body: "[name], your streak needs you! 3 minutes is all it takes."),
                NotificationContent(title: "Last call [name]! ⏰", body: "Midnight is coming. Don't let your streak turn to ash!")
            ]
        } else {
            return [
                NotificationContent(title: "🔥 Flamme en danger [name] !", body: "Tu vas perdre ta série ! Sauve-la maintenant avec une leçon rapide."),
                NotificationContent(title: "Ne brise pas la chaîne ! ⛓️", body: "Hey [name], protège tes efforts. Fais une leçon maintenant."),
                NotificationContent(title: "Alerte Urgence 🚨", body: "[name], ta flamme a besoin de toi ! 3 minutes suffisent."),
                NotificationContent(title: "Dernier appel [name] ! ⏰", body: "Minuit approche. Ne laisse pas ta série partir en fumée !")
            ]
        }
    }
    
    static var inactivity3Days: [NotificationContent] {
        if isEnglish {
            return [
                NotificationContent(title: "We miss you [name] 🥺", body: "It's been 3 days! Come back and learn one new word."),
                NotificationContent(title: "Where are you [name]? 🕵️", body: "Your Arabic journey is paused. Press play today!")
            ]
        } else {
            return [
                NotificationContent(title: "Tu nous manques [name] 🥺", body: "Ça fait 3 jours ! Reviens apprendre juste un mot."),
                NotificationContent(title: "Où es-tu [name] ? 🕵️", body: "Ton voyage en arabe est en pause. Appuie sur play aujourd'hui !")
            ]
        }
    }
    
    static var inactivity7Days: [NotificationContent] {
        if isEnglish {
            return [
                NotificationContent(title: "Don't give up [name]! 💪", body: "It's been a week. The best time to restart is right now."),
                NotificationContent(title: "A fresh start? 🌱", body: "Hey [name], let's get back on track together. We believe in you.")
            ]
        } else {
            return [
                NotificationContent(title: "N'abandonne pas [name] ! 💪", body: "Une semaine déjà. Le meilleur moment pour reprendre, c'est maintenant."),
                NotificationContent(title: "Un nouveau départ ? 🌱", body: "Hey [name], remettons-nous en selle ensemble. On croit en toi.")
            ]
        }
    }

    static var dhillySpecial: [NotificationContent] {
        [
            NotificationContent(title: "Laurine 💛", body: "Reviens t'entraîner et wow sub7anAllah ce sourire !!!!"),
            NotificationContent(title: "Notif aléatoire 🎲", body: "Laurine wAllah je suis une notif aléatoire mais tu es la plus belle fille de l'histoire"),
            NotificationContent(title: "Laurine Dhilly 🌟", body: "T'es trop forte ma sha Allah, reviens casser des records sur Noorine"),
            NotificationContent(title: "Alerte beauté 🚨", body: "Laurine sub7anAllah y'a trop de lumière qui sort de cette appli quand tu l'ouvres"),
            NotificationContent(title: "Message important 📩", body: "Laurine sache que tu es wow et que tu es une fille incroyable. Et bois de l'eau MDR."),
            NotificationContent(title: "Coucou Laurine 🌙", body: "Même cette notif est jalouse de toi parce que t'es trop wow Allahuma barik"),
            NotificationContent(title: "Breaking news 📰", body: "Laurine Dhilly a encore pas fait sa leçon d'arabe. Scandale. Reviens stp 🥺"),
            NotificationContent(title: "Sub7anAllah 🤲", body: "Laurine tu brilles tellement que même ton téléphone t'envoie des compliments. Allez hop, une leçon !"),
            NotificationContent(title: "Salam Laurine 💫", body: "WAllah t'es la meilleure élève que Noorine ait jamais eue (et la seule pr l'instant aussi mais chut)")
        ]
    }
}
