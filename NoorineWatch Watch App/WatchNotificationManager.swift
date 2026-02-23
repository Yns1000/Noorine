import Foundation
import UserNotifications

class WatchNotificationManager {
    static let shared = WatchNotificationManager()

    private let notificationIdentifier = "NoorineWatchDailyPractice"
    private let scheduledDateKey = "NoorineWatchNotifScheduledDate"

    private var isEnglish: Bool {
        Locale.current.language.languageCode?.identifier == "en"
    }

    private init() {}

    func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if granted {
                        self.scheduleDailyNotification()
                    }
                }
            case .authorized, .provisional:
                self.scheduleDailyNotification()
            default:
                break
            }
        }
    }

    func scheduleDailyNotification() {
        if hasPracticedToday() {
            cancelPendingNotification()
            scheduleForTomorrow()
            return
        }

        let todayString = dateString(for: Date())
        if UserDefaults.standard.string(forKey: scheduledDateKey) == todayString {
            return
        }

        scheduleNotification()
    }

    private func scheduleNotification() {
        cancelPendingNotification()

        let now = Date()
        let calendar = Calendar.current

        var targetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = 14
        targetComponents.minute = 30

        guard let targetDate = calendar.date(from: targetComponents) else { return }

        if now > targetDate {
            scheduleForTomorrow()
            return
        }

        let content = makeNotificationContent()
        let trigger = UNCalendarNotificationTrigger(dateMatching: targetComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                UserDefaults.standard.set(self.dateString(for: now), forKey: self.scheduledDateKey)
            }
        }
    }

    private func scheduleForTomorrow() {
        cancelPendingNotification()

        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 14
        components.minute = 30

        let content = makeNotificationContent()
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                UserDefaults.standard.set(self.dateString(for: tomorrow), forKey: self.scheduledDateKey)
            }
        }
    }

    func onPracticeCompleted() {
        cancelPendingNotification()
        scheduleForTomorrow()
    }

    func cancelPendingNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier]
        )
    }

    private func hasPracticedToday() -> Bool {
        let key = todaySessionKey()
        return UserDefaults.standard.integer(forKey: key) > 0
    }

    private func todaySessionKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return "NoorineWatchSessionCount_\(fmt.string(from: Date()))"
    }

    private func dateString(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    private func makeNotificationContent() -> UNMutableNotificationContent {
        let message = watchMessages.randomElement()!
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        return content
    }

    private var watchMessages: [(title: String, body: String)] {
        if isEnglish {
            return [
                (title: "Time to draw! ✏️",
                 body: "Practice your Arabic letters on your wrist."),
                (title: "Quick practice? 🌟",
                 body: "Draw one letter, it only takes a minute!"),
                (title: "Marhaba! 👋",
                 body: "Your daily Arabic drawing awaits."),
                (title: "Don't forget! ✨",
                 body: "A quick letter on your watch keeps progress going."),
                (title: "Arabic time! 🎯",
                 body: "Trace a letter right from your wrist."),
            ]
        } else {
            return [
                (title: "C'est l'heure ! ✏️",
                 body: "Entraîne-toi sur tes lettres arabes au poignet."),
                (title: "Un petit tracé ? 🌟",
                 body: "Dessine une lettre, ça prend juste une minute !"),
                (title: "Marhaba ! 👋",
                 body: "Ton tracé d'arabe quotidien t'attend."),
                (title: "N'oublie pas ! ✨",
                 body: "Une lettre rapide au poignet pour continuer tes progrès."),
                (title: "C'est l'heure de l'arabe ! 🎯",
                 body: "Trace une lettre direct depuis ton poignet."),
            ]
        }
    }
}
