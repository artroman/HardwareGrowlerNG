//
//  NotificationController.swift
//  HardwareGrowler
//
//  Bridges the monitors' delegate callbacks to UNUserNotificationCenter.
//  Replaces the GrowlApplicationBridge half of the old HWGrowlPluginController.
//

import AppKit
import UserNotifications

@objc final class NotificationController: NSObject {
    private let registry: MonitorRegistry

    init(registry: MonitorRegistry) {
        self.registry = registry
        super.init()
    }

    private static let attachmentDirectory: URL = {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HardwareGrowlerIcons", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func makeAttachment(from data: Data) -> UNNotificationAttachment? {
        guard let image = NSImage(data: data),
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            return nil
        }
        let url = Self.attachmentDirectory.appendingPathComponent(UUID().uuidString + ".png")
        do {
            try png.write(to: url)
            return try UNNotificationAttachment(identifier: "", url: url, options: nil)
        } catch {
            return nil
        }
    }
}

// MARK: - HWGrowlPluginControllerProtocol

extension NotificationController: HWGrowlPluginControllerProtocol {
    func notify(withName name: String?,
                title: String?,
                description: String?,
                icon iconData: Data?,
                identifierString identifier: String?,
                contextString context: String?,
                plugin: Any?) {

        if let plugin = plugin as AnyObject?, pluginDisabled(plugin) {
            Log.notifications.debug("dropped notification '\(name ?? "?", privacy: .public)' from disabled monitor")
            return
        }

        Log.notifications.info("post '\(name ?? "?", privacy: .public)': \(title ?? "", privacy: .public) — \(description ?? "", privacy: .public)")

        let content = UNMutableNotificationContent()
        content.title = title ?? "HardwareGrowler"
        if let description, !description.isEmpty {
            content.body = description
        }
        if let name, !name.isEmpty {
            content.categoryIdentifier = name
        }

        var userInfo: [String: Any] = [:]
        if let context {
            userInfo["context"] = context
        }
        if let plugin = plugin as AnyObject? {
            userInfo["pluginClass"] = NSStringFromClass(type(of: plugin))
        }
        content.userInfo = userInfo

        if let iconData, let attachment = makeAttachment(from: iconData) {
            content.attachments = [attachment]
        }

        let requestID = (identifier?.isEmpty == false) ? identifier! : UUID().uuidString
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                NSLog("HardwareGrowler: failed to post notification: \(error)")
            }
        }
    }

    func onLaunchEnabled() -> Bool {
        Preferences.shared.showExistingAtLaunch
    }

    func pluginDisabled(_ plugin: Any?) -> Bool {
        guard let plugin = plugin as AnyObject? else { return false }
        return !registry.isEnabled(plugin: plugin)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        if let pluginClass = info["pluginClass"] as? String,
           let context = info["context"] as? String {
            registry.notifyClosed(pluginClass: pluginClass, context: context, byClick: true)
        }
        completionHandler()
    }
}
