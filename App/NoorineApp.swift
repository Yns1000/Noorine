import SwiftUI
import SwiftData

@main
struct NoorineApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var dataManager = DataManager.shared
    @State private var showMainApp = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            LevelProgress.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage.rawValue))
                    .environmentObject(languageManager)
                    .environmentObject(dataManager)
                    .id(languageManager.currentLanguage.rawValue)
                
                if !showMainApp {
                    SplashScreenView(isActive: $showMainApp)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(1)
                }
            }
            .onAppear {
                dataManager.configure(with: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
