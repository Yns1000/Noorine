import SwiftUI

struct ContentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    @State private var showWeeklySummary = false

    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "map.fill" : "map")
                    Text(LocalizedStringKey(isEnglish ? "Learn" : "Apprendre"))
                }
                .tag(0)

            PracticeView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "book.fill" : "book")
                    Text(LocalizedStringKey(isEnglish ? "Practice" : "Réviser"))
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                    Text(LocalizedStringKey(isEnglish ? "Profile" : "Profil"))
                }
                .tag(2)
        }
        .toolbarBackground(Color.noorBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(.noorGold)
        .onAppear {
            if dataManager.shouldShowWeeklySummary() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showWeeklySummary = true
                }
            }
        }
        .fullScreenCover(isPresented: $showWeeklySummary) {
            WeeklySummaryView()
        }
    }
}

#Preview {
    ContentView()
}
