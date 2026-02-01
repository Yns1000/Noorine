import SwiftUI

struct DailyChallengeInviteView: View {
    let onStart: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            
            VStack(spacing: 6) {
                Text(LocalizedStringKey("Défi du Jour !"))
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .foregroundColor(.noorText)
                
                Text(LocalizedStringKey("Prêt pour tes 6 exercices quotidiens ?\nGagne jusqu'à 60 XP en quelques minutes."))
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
                        Text(LocalizedStringKey("LANCER LE DÉFI"))
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
                    Text(LocalizedStringKey("Plus tard"))
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
