import SwiftUI
import UserNotifications

@main
struct TacoTraderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(APIClient.shared)
                .preferredColorScheme(.dark)
        }
    }
}
