import SwiftUI
import SwiftData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct NoorineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var dataManager = DataManager.shared
    @State private var showMainApp = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            LevelProgress.self,
            MistakeItem.self
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
                
                if !showMainApp {
                    SplashScreenView(isActive: $showMainApp)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(1)
                }
                
                if showMainApp && (dataManager.userProgress?.name.isEmpty ?? true) {
                    OnboardingView(isActive: Binding(
                        get: { dataManager.userProgress?.name.isEmpty ?? true },
                        set: { _ in }
                    ))
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
            }
            .environmentObject(dataManager)
            .environmentObject(languageManager)
            .environment(\.locale, .init(identifier: languageManager.currentLanguage.rawValue))
            .id(languageManager.currentLanguage.rawValue)
            .onAppear {
                dataManager.configure(with: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
