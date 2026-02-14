import SwiftUI

struct DailyChallengeCard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showChallenge = false
    private let totalSteps = 6
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    private var isCompleted: Bool {
        dataManager.isDailyChallengeCompletedToday()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isCompleted
                            ? [Color.green.opacity(0.7), Color.green.opacity(0.5)]
                            : [.noorGold, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isCompleted
                    ? .green.opacity(0.2)
                    : .orange.opacity(0.3), radius: 15, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark.seal.fill" : "flame.fill")
                            .foregroundColor(.white)
                        Text(isEnglish ? "DAILY CHALLENGE" : "DÉFI QUOTIDIEN")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    
                    Text(isCompleted
                        ? (isEnglish ? "Come back tomorrow!" : "Reviens demain !")
                        : (isEnglish ? "Strengthen your memory" : "Renforce ta mémoire"))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if isCompleted {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(isEnglish ? "COMPLETED" : "TERMINÉ")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        .padding(.top, 8)
                    } else {
                        Button(action: { showChallenge = true }) {
                            Text(isEnglish
                                ? "START (+\(totalSteps * 10) XP)"
                                : "LANCER (+\(totalSteps * 10) XP)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(20)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                
                Spacer()
                
                NoorineMascot()
                    .frame(width: 100, height: 100)
                    .offset(x: -10, y: 10)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
        .frame(height: 160)
        .fullScreenCover(isPresented: $showChallenge) {
            DailyChallengeView()
        }
    }
}
