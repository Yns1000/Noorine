import Foundation

struct SharedDataStore {
    static let appGroupID = "group.com.yns.Noorine"

    static var shared: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private enum Keys {
        static let streakDays = "widget_streakDays"
        static let xpTotal = "widget_xpTotal"
        static let currentWeekXP = "widget_currentWeekXP"
        static let wordOfDayArabic = "widget_wordOfDayArabic"
        static let wordOfDayTransliteration = "widget_wordOfDayTransliteration"
        static let wordOfDayTranslationFr = "widget_wordOfDayTranslationFr"
        static let wordOfDayTranslationEn = "widget_wordOfDayTranslationEn"
        static let lastSyncDate = "widget_lastSyncDate"
        static let todayXP = "widget_todayXP"
        static let userName = "widget_userName"
    }

    static func sync(
        streakDays: Int,
        xpTotal: Int,
        currentWeekXP: Int,
        todayXP: Int,
        userName: String
    ) {
        let store = shared
        store.set(streakDays, forKey: Keys.streakDays)
        store.set(xpTotal, forKey: Keys.xpTotal)
        store.set(currentWeekXP, forKey: Keys.currentWeekXP)
        store.set(todayXP, forKey: Keys.todayXP)
        store.set(userName, forKey: Keys.userName)
        store.set(Date(), forKey: Keys.lastSyncDate)
    }

    static func syncWordOfDay(
        arabic: String,
        transliteration: String,
        translationFr: String,
        translationEn: String
    ) {
        let store = shared
        store.set(arabic, forKey: Keys.wordOfDayArabic)
        store.set(transliteration, forKey: Keys.wordOfDayTransliteration)
        store.set(translationFr, forKey: Keys.wordOfDayTranslationFr)
        store.set(translationEn, forKey: Keys.wordOfDayTranslationEn)
    }

    static var streakDays: Int { shared.integer(forKey: Keys.streakDays) }
    static var xpTotal: Int { shared.integer(forKey: Keys.xpTotal) }
    static var currentWeekXP: Int { shared.integer(forKey: Keys.currentWeekXP) }
    static var todayXP: Int { shared.integer(forKey: Keys.todayXP) }
    static var userName: String { shared.string(forKey: Keys.userName) ?? "Apprenti" }

    static var wordOfDayArabic: String { shared.string(forKey: Keys.wordOfDayArabic) ?? "كِتَاب" }
    static var wordOfDayTransliteration: String { shared.string(forKey: Keys.wordOfDayTransliteration) ?? "Kitab" }
    static var wordOfDayTranslationFr: String { shared.string(forKey: Keys.wordOfDayTranslationFr) ?? "Livre" }
    static var wordOfDayTranslationEn: String { shared.string(forKey: Keys.wordOfDayTranslationEn) ?? "Book" }

    static var lastSyncDate: Date? { shared.object(forKey: Keys.lastSyncDate) as? Date }
}
