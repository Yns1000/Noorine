import SwiftUI
import SwiftData

struct PracticeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showRecommendedTool = false

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.noorBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        PracticeHeader()
                            .padding(.top, 10)

                        DailyChallengeCard()

                        if let rec = dataManager.getPracticeRecommendation(isEnglish: isEnglish) {
                            AdaptiveRecommendationBanner(
                                recommendation: rec,
                                isEnglish: isEnglish,
                                onTap: { showRecommendedTool = true }
                            )
                        }

                        PracticeToolsGrid()

                        WordsReviewList()

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showRecommendedTool) {
                MistakesReviewView()
            }
        }
    }
}

struct AdaptiveRecommendationBanner: View {
    let recommendation: PracticeRecommendation
    let isEnglish: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                EmotionalMascot(mood: .encouraging, size: 40, showAura: false)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isEnglish ? "RECOMMENDED" : "RECOMMANDÉ")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.noorGold)

                    Text(recommendation.message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.noorText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.noorGold)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.noorSecondary.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.noorGold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PracticeView()
}
