import SwiftUI
import SwiftData

struct PracticeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        PracticeHeader()
                            .padding(.top, 10)
                        
                        DailyChallengeCard()
                        
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
        }
    }
}

#Preview {
    PracticeView()
}