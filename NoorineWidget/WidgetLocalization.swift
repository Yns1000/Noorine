import Foundation

enum WidgetLocalization {
    static var isEnglish: Bool {
        Locale.current.language.languageCode?.identifier == "en"
    }

    static var lessonHeader: String { isEnglish ? "NOORINE LESSON" : "NOORINE LEÇON" }
    static var streakHeader: String { isEnglish ? "NOORINE STREAK" : "NOORINE SÉRIE" }
    static var wordOfDayHeader: String { isEnglish ? "WORD OF THE DAY" : "MOT DU JOUR" }
    static var days: String { isEnglish ? "days" : "jours" }
    
    static var protectStreak: String { isEnglish ? "Protect your streak!" : "Protège ta série !" }
    static var saveFlame: String { isEnglish ? "Save your flame before midnight!" : "Sauve ta flamme avant minuit !" }
    
    static var wordOfDayTitle: String { isEnglish ? "WORD OF THE DAY" : "MOT DU JOUR" }
    static var streakWidgetTitle: String { isEnglish ? "Noorine Streak" : "Série Noorine" }
    static var wordOfDayDesc: String { isEnglish ? "A new Arabic word every day" : "Un nouveau mot arabe chaque jour" }
    static var streakWidgetDesc: String { isEnglish ? "Your streak and daily progress" : "Ta série de jours et progression quotidienne" }
}
