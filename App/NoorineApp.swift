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
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct NoorineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var languageManager = LanguageManager()
    private let dataManager = DataManager.shared
    @State private var showMainApp = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            LevelProgress.self,
            MistakeItem.self,
            SRSCard.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let storeURL = config.url
            try? FileManager.default.removeItem(at: storeURL)
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try! ModelContainer(for: schema, configurations: [fallback])
            }
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
                let context = sharedModelContainer.mainContext
                dataManager.configure(with: context)
                SRSEngine.shared.configure(with: context)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
