import SwiftUI

struct DailyChallengeInviteView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let onStart: () -> Void
    let onDismiss: () -> Void
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 6) {
                Text(LocalizedStringKey(isEnglish ? "Daily Challenge!" : "Défi du Jour !"))
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .foregroundColor(.noorText)
                
                Text(LocalizedStringKey(isEnglish ? "Ready for your 6 daily exercises?\nEarn up to 60 XP in minutes." : "Prêt pour tes 6 exercices quotidiens ?\nGagne jusqu'à 60 XP en quelques minutes."))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
            
            VStack(spacing: 10) {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(LocalizedStringKey(isEnglish ? "START CHALLENGE" : "LANCER LE DÉFI"))
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.noorDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.noorGold)
                    .cornerRadius(18)
                    .shadow(color: Color.noorGold.opacity(0.3), radius: 6, y: 3)
                }
                
                Button(action: onDismiss) {
                    Text(LocalizedStringKey(isEnglish ? "Later" : "Plus tard"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorSecondary)
                        .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.noorBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    DailyChallengeInviteView(onStart: {}, onDismiss: {})
}
