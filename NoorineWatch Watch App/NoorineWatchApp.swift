import SwiftUI

@main
struct NoorineWatch_Watch_AppApp: App {
    init() {
        WatchSyncManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
