import SwiftUI

struct AlphabetHeroCard: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.noorGold, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 15, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(languageManager.currentLanguage == .english ? "Arabic Alphabet" : "Alphabet Arabe")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(languageManager.currentLanguage == .english
                         ? "Learn the correct pronunciation for every letter."
                         : "Apprends la prononciation correcte de chaque lettre.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(languageManager.currentLanguage == .english ? "28 letters" : "28 lettres")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        
                        Text(languageManager.currentLanguage == .english ? "HD audio" : "Audio HD")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .foregroundColor(.white)
                    .padding(.top, 8)
                }
                Spacer()
            }
            .padding(24)
            
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.15))
                .offset(x: 10, y: 20)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

struct FutureModuleCard: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color.opacity(0.5))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.noorSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

struct ListeningModuleCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.clear)
                )
                .shadow(color: colors.last?.opacity(0.25) ?? .black.opacity(0.1), radius: 12, y: 6)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.12))
                .offset(x: 8, y: 12)
        }
        .frame(minHeight: 140)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct LetterAudioCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isPlaying = false
    let letter: ArabicLetter
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPlaying = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isPlaying = false
                }
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Text(letter.isolated)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.noorText)
                }
                .frame(height: 60)
                
                VStack(spacing: 2) {
                    Text(letter.transliteration)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.noorText)
                    
                    Text(letter.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.noorSecondary)
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isPlaying ? Color.noorGold.opacity(0.5) : Color.black.opacity(0.03), lineWidth: isPlaying ? 2 : 1.5)
            )
            .scaleEffect(isPlaying ? 1.05 : 1.0)
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
