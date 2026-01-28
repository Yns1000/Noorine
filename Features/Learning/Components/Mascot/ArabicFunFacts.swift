import Foundation

struct ArabicFunFacts {
    static let facts = [
        "L'arabe est parlé par plus de 420 millions de personnes dans le monde.",
        "L'alphabet arabe compte 28 lettres, toutes des consonnes.",
        "L'arabe s'écrit de droite à gauche, une particularité partagée avec l'hébreu.",
        "Le mot 'algorithme' vient du mathématicien arabe Al-Khwarizmi.",
        "L'arabe est l'une des 6 langues officielles de l'ONU.",
        "Chaque lettre arabe peut avoir jusqu'à 4 formes différentes.",
        "Le Coran est écrit en arabe classique, considéré comme la forme la plus pure.",
        "L'arabe a influencé de nombreuses langues : espagnol, portugais, français...",
        "Le mot 'café' vient de l'arabe 'qahwa'.",
        "L'arabe possède plus de 12 millions de mots, contre 600 000 en anglais.",
        "La calligraphie arabe est considérée comme un art majeur dans le monde islamique.",
        "Les chiffres 'arabes' que nous utilisons viennent en fait de l'Inde.",
        "L'arabe distingue les nombres singulier, duel (pour 2) et pluriel.",
        "Le plus ancien texte arabe date du 1er siècle avant J.-C.",
        "L'arabe a 3 voyelles longues et 3 voyelles courtes."
    ]
    
    static let encouragements = [
        "La persévérance est la clé de l'apprentissage.",
        "Chaque erreur est une opportunité d'apprendre.",
        "Les plus grands calligraphes ont tous commencé comme toi.",
        "La patience est le secret des maîtres arabes.",
        "Continue, tu progresses à chaque essai.",
        "L'apprentissage est un voyage, pas une destination.",
        "Même les experts ont eu besoin de pratique.",
        "Ton effort d'aujourd'hui est ton succès de demain."
    ]
    
    static func randomFact() -> String {
        facts.randomElement() ?? facts[0]
    }
    
    static func randomEncouragement() -> String {
        encouragements.randomElement() ?? encouragements[0]
    }
}
