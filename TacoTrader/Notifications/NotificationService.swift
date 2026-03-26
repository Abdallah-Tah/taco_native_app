import Foundation
import UIKit
import UserNotifications

// MARK: - Payload model

struct RedeemNotificationPayload {
    let eventType: String
    let amount: Double
    let title: String
    let timestamp: Date
}

// MARK: - Service

@MainActor
final class NotificationService: NSObject {
    static let shared = NotificationService()

    func requestPermission() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Fire a local notification — useful for testing without APNs
    func fireLocalRedeemNotification(_ payload: RedeemNotificationPayload) {
        let content = UNMutableNotificationContent()
        content.title = "💰 \(payload.title)"
        content.body = String(format: "$%.2f redeemed successfully", payload.amount)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("cha-ching.caf"))
        content.userInfo = [
            "event_type": payload.eventType,
            "amount": payload.amount,
            "timestamp": ISO8601DateFormatter().string(from: payload.timestamp)
        ]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
