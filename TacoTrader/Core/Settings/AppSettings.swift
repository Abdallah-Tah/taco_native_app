import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("backend_url") var backendURL: String = "http://192.168.40.209:5000"
    @AppStorage("auth_token") var authToken: String = "c7c49da0c6e73ca8aa2b799864293f796cedbb3b71641b7c3a8435fc383674c6"
    @AppStorage("refresh_interval") var refreshInterval: Double = 15.0
    @AppStorage("notifications_enabled") var notificationsEnabled: Bool = true
}
