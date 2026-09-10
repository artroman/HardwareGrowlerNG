//
//  NotificationAuth.swift
//  HardwareGrowler
//
//  Helpers for the notification-permission section of the Settings window.
//

import AppKit
import UserNotifications

enum NotificationAuth {
    static func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                Log.notifications.error("authorization request failed: \(error.localizedDescription, privacy: .public)")
            } else {
                Log.notifications.info("authorization request returned granted=\(granted)")
            }
        }
    }

    static func openSystemSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.Notifications-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.notifications",
        ]
        for string in candidates {
            if let url = URL(string: string), NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    static func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "HardwareGrowler"
        content.body = "Test notification — if you can see this, notifications are working."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "hwg.test.\(UUID().uuidString)",
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Log.notifications.error("test notification failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
