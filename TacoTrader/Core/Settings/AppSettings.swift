import Foundation
import SwiftUI

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("backend_url") var backendURL: String = "http://raspberrypi.local:5000"
    @AppStorage("auth_token") var authToken: String = ""
    @AppStorage("refresh_interval") var refreshInterval: Double = 15.0
    @AppStorage("notifications_enabled") var notificationsEnabled: Bool = true
}
