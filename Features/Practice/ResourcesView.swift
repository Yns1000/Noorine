import SwiftUI

struct ResourcesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var audioManager = AudioManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var pronounWords: [ArabicWord] {
        CourseContent.words.filter { [21, 22, 23, 24, 25].contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                    
                    sectionTitle(languageManager.currentLanguage == .english ? "Alphabet" : "Alphabet")
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ArabicLetter.alphabet) { letter in
                            LetterAudioCard(letter: letter) {
                                audioManager.playLetter(letter.isolated)
                                FeedbackManager.shared.tapLight()
                            }
                        }
                    }
                    
                    sectionTitle(languageManager.currentLanguage == .english ? "Harakat (Short Vowels)" : "Harakat (Voyelles courtes)")
                    
                    VStack(spacing: 12) {
                        ForEach(CourseContent.vowels) { vowel in
                            vowelRow(vowel)
                        }
                    }
                    
                    if !pronounWords.isEmpty {
                        sectionTitle(languageManager.currentLanguage == .english ? "Basic Pronouns" : "Pronoms de base")
                        
                        VStack(spacing: 12) {
                            ForEach(pronounWords) { word in
                                wordRow(word)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.noorGold)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    )
            }
            
            Spacer()
            
            Text(LocalizedStringKey("Ressources"))
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.top, 10)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(LocalizedStringKey(text))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.noorText)
            Spacer()
        }
    }
    
    private func vowelRow(_ vowel: ArabicVowel) -> some View {
        let example = vowel.examples.first
        let combo = example?.combination ?? ("◌" + vowel.symbol)
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(combo)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.noorText)
                    Text(vowel.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorGold)
                }
                Text(languageManager.currentLanguage == .english
                     ? "Sound: \(vowel.transliteration)"
                     : "Son : \(vowel.transliteration)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Button(action: {
                if let example = example {
                    audioManager.playSound(named: example.audioName)
                } else {
                    audioManager.playText(combo, style: .letter, useCache: true)
                }
                FeedbackManager.shared.tapLight()
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.noorGold)
                    .padding(10)
                    .background(Color.noorGold.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
    
    private func wordRow(_ word: ArabicWord) -> some View {
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.arabic)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.noorText)
                Text(word.transliteration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Text(languageManager.currentLanguage == .english ? word.translationEn : word.translationFr)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.noorGold)
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
