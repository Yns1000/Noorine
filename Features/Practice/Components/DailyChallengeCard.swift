import SwiftUI

struct DailyChallengeCard: View {
    @State private var showChallenge = false
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.noorGold, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 15, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                        Text(LocalizedStringKey("DÉFI QUOTIDIEN"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    
                    Text(LocalizedStringKey("Renforce ta mémoire"))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: { showChallenge = true }) {
                        Text(LocalizedStringKey("LANCER (+\(totalSteps * 10) XP)"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 8)
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
