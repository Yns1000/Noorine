import Foundation

struct ArabicFact {
    let fr: String
    let en: String
}

class FactsData {
    static let shared = FactsData()
    
    private init() {}
    
    func getRandomFact(for language: AppLanguage) -> String {
        let fact = allFacts.randomElement() ?? allFacts[0]
        return language == .french ? fact.fr : fact.en
    }
    
    private let allFacts: [ArabicFact] = [
        ArabicFact(fr: "L'arabe s'écrit de droite à gauche.", en: "Arabic is written from right to left."),
        ArabicFact(fr: "L'alphabet arabe contient 28 lettres.", en: "The Arabic alphabet contains 28 letters."),
        ArabicFact(fr: "Il n'y a pas de majuscules en arabe.", en: "There are no capital letters in Arabic."),
        ArabicFact(fr: "L'arabe est la 5ème langue la plus parlée au monde.", en: "Arabic is the 5th most spoken language in the world."),
        
        ArabicFact(fr: "Les mots 'Sucre', 'Café' et 'Girafe' viennent de l'arabe.", en: "The words 'Sugar', 'Coffee', and 'Giraffe' come from Arabic."),
        ArabicFact(fr: "Le mot 'Algèbre' vient du titre d'un livre arabe du 9ème siècle.", en: "The word 'Algebra' comes from the title of a 9th-century Arabic book."),
        ArabicFact(fr: "Le mot 'Coton' vient de l'arabe 'Qutn'.", en: "The word 'Cotton' comes from the Arabic 'Qutn'."),
        ArabicFact(fr: "L'arabe a donné plus de 4000 mots à la langue espagnole.", en: "Arabic contributed over 4,000 words to the Spanish language."),
        ArabicFact(fr: "Le mot 'Hasard' vient de l'arabe 'Az-zahr' (jeu de dés).", en: "The word 'Hazard' comes from Arabic 'Az-zahr' (dice game)."),
        ArabicFact(fr: "Le mot 'Matelas' vient de l'arabe 'Matrah' (endroit où l'on jette quelque chose).", en: "The word 'Mattress' comes from Arabic 'Matrah' (place where something is thrown)."),
        ArabicFact(fr: "Le mot 'Sirop' vient de l'arabe 'Sharab' (boisson).", en: "The word 'Syrup' comes from Arabic 'Sharab' (drink)."),
        ArabicFact(fr: "Le mot 'Amiral' vient de 'Amir al-bahr' (Prince de la mer).", en: "The word 'Admiral' comes from 'Amir al-bahr' (Prince of the Sea)."),
        ArabicFact(fr: "Le mot 'Bougie' vient du nom de la ville algérienne Béjaïa.", en: "The French word 'Bougie' (candle) comes from the Algerian city Béjaïa."),
        
        ArabicFact(fr: "Chaque lettre change de forme selon sa place dans le mot.", en: "Each letter changes shape depending on its position in the word."),
        ArabicFact(fr: "En arabe, on n'écrit généralement pas les voyelles courtes.", en: "In Arabic, short vowels are usually not written."),
        ArabicFact(fr: "Il existe une conjugaison spéciale pour 'deux personnes' (le duel).", en: "There is a special grammatical form for 'two people' (the dual)."),
        ArabicFact(fr: "La racine des mots arabes est souvent composée de 3 lettres.", en: "Arabic word roots are often made of 3 letters."),
        ArabicFact(fr: "L'arabe appartient à la famille des langues sémitiques.", en: "Arabic belongs to the Semitic language family."),
        ArabicFact(fr: "Le verbe 'être' n'est pas utilisé au présent en arabe.", en: "The verb 'to be' is not used in the present tense in Arabic."),
        ArabicFact(fr: "Les adjectifs viennent toujours après le nom en arabe.", en: "Adjectives always come after the noun in Arabic."),
        
        ArabicFact(fr: "Le son 'P' n'existe pas en arabe standard.", en: "The 'P' sound does not exist in standard Arabic."),
        ArabicFact(fr: "L'arabe est surnommé 'la langue du Dhad' car ce son est unique.", en: "Arabic is nicknamed 'the language of Dhad' because this sound is unique."),
        ArabicFact(fr: "Les points sur les lettres changent complètement leur sens.", en: "The dots on the letters completely change their meaning."),
        ArabicFact(fr: "La lettre 'Ayn' (ع) vient du fond de la gorge.", en: "The letter 'Ayn' (ع) comes from deep in the throat."),
        
        ArabicFact(fr: "L'algèbre a été inventée par des mathématiciens arabes.", en: "Algebra was invented by Arabic mathematicians."),
        ArabicFact(fr: "La calligraphie arabe est considérée comme un art majeur.", en: "Arabic calligraphy is considered a major art form."),
        ArabicFact(fr: "L'arabe est une langue officielle de l'ONU.", en: "Arabic is an official language of the UN."),
        ArabicFact(fr: "Le Coran a aidé à standardiser la langue arabe classique.", en: "The Quran helped standardize classical Arabic."),
        ArabicFact(fr: "Il existe deux formes d'arabe : le littéraire et le dialectal.", en: "There are two forms of Arabic: Modern Standard and Dialectal."),
        ArabicFact(fr: "La plus ancienne université du monde (Al-Qarawiyyin) est au Maroc.", en: "The world's oldest university (Al-Qarawiyyin) is in Morocco."),
        ArabicFact(fr: "Les chiffres que nous utilisons sont d'origine arabe (via l'Inde).", en: "The numbers we use are of Arabic origin (via India)."),
        ArabicFact(fr: "Le 'Zéro' a été introduit en Europe par les Arabes.", en: "The concept of 'Zero' was introduced to Europe by Arabs."),
        
        ArabicFact(fr: "Il existe 11 mots différents pour dire 'Amour' en arabe.", en: "There are 11 different words for 'Love' in Arabic."),
        ArabicFact(fr: "Le chameau a des centaines de noms en arabe poétique.", en: "The camel has hundreds of names in poetic Arabic."),
        ArabicFact(fr: "Le lion possède plus de 300 noms en arabe.", en: "The lion has over 300 names in Arabic."),
        ArabicFact(fr: "Le mot 'Arabe' signifie à l'origine 'Nomade'.", en: "The word 'Arab' originally means 'Nomad'."),
        ArabicFact(fr: "En arabe, 'Sahara' signifie simplement 'Désert'.", en: "In Arabic, 'Sahara' simply means 'Desert'."),
        
        ArabicFact(fr: "Beaucoup d'étoiles portent des noms arabes (Altaïr, Rigel).", en: "Many stars have Arabic names (Altair, Rigel)."),
        ArabicFact(fr: "L'étoile 'Bételgeuse' vient de l'arabe 'Yad al-Jauza'.", en: "The star 'Betelgeuse' comes from the Arabic 'Yad al-Jauza'."),
        ArabicFact(fr: "Les astronomes arabes ont perfectionné l'astrolabe.", en: "Arab astronomers perfected the astrolabe."),
        
        ArabicFact(fr: "L'arabe est langue officielle dans 22 pays.", en: "Arabic is an official language in 22 countries."),
        ArabicFact(fr: "L'Égypte est le pays arabe le plus peuplé.", en: "Egypt is the most populous Arab country."),
        ArabicFact(fr: "Malte est le seul pays européen parlant un dérivé de l'arabe.", en: "Malta is the only European country speaking an Arabic derivative."),
        
        ArabicFact(fr: "On écrit les chiffres de gauche à droite, même en arabe.", en: "Numbers are written from left to right, even in Arabic."),
        ArabicFact(fr: "Le café (Qahwa) était à l'origine utilisé par les soufis.", en: "Coffee (Qahwa) was originally used by Sufis."),
        ArabicFact(fr: "L'arabe s'écrit en cursive, les lettres sont attachées.", en: "Arabic is written in cursive, letters are connected."),
        ArabicFact(fr: "Le style d'écriture 'Kufi' est le plus ancien style arabe.", en: "The 'Kufic' script is the oldest Arabic writing style."),
        ArabicFact(fr: "La journée mondiale de la langue arabe est le 18 décembre.", en: "World Arabic Language Day is on December 18th."),
        ArabicFact(fr: "L'arabe a influencé le turc, le persan et l'ourdou.", en: "Arabic influenced Turkish, Persian, and Urdu.")
    ]
}
