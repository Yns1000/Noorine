import Foundation

struct ArabicFunFacts {
    static var facts: [String] {
        [
            "fact_1",
            "fact_2",
            "fact_3",
            "fact_4",
            "fact_5",
            "fact_6",
            "fact_7",
            "fact_8",
            "fact_9",
            "fact_10",
            "fact_11",
            "fact_12",
            "fact_13",
            "fact_14",
            "fact_15",
            "fact_listening_1",
            "fact_listening_2",
            "fact_listening_3",
            "fact_listening_4",
            "fact_listening_5",
            "fact_listening_6"
        ]
    }
    
    static var encouragements: [String] {
        [
            "encouragement_1",
            "encouragement_2",
            "encouragement_3",
            "encouragement_4",
            "encouragement_5",
            "encouragement_6",
            "encouragement_7",
            "encouragement_8"
        ]
    }
    
    static func randomFact() -> String {
        facts.randomElement() ?? facts[0]
    }
    
    static func randomEncouragement() -> String {
        encouragements.randomElement() ?? encouragements[0]
    }
}
