//
//  AppDelegate.swift
//  HardwareGrowler
//
//  Owns startup: activation policy, notification authorization, and bringing
//  the hardware monitors online. Mirrors the old HWGrowlPluginController
//  bootstrap, minus Growl.
//

import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: NotificationController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Defaults.registerDefaults()
        Defaults.syncLoginItem()
        Defaults.applyActivationPolicy()

        let center = UNUserNotificationCenter.current()
        let registry = MonitorRegistry.shared
        let controller = NotificationController(registry: registry)
        self.controller = controller
        center.delegate = controller

        center.getNotificationSettings { settings in
            Log.notifications.info("settings before request: authorization=\(settings.authorizationStatus.rawValue) alert=\(settings.alertSetting.rawValue)")
        }
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error as NSError? {
                Log.notifications.error("authorization error: \(error.domain, privacy: .public) \(error.code) — \(error.localizedDescription, privacy: .public)")
            } else {
                Log.notifications.info("authorization granted=\(granted)")
            }
            center.getNotificationSettings { settings in
                Log.notifications.info("settings after request: authorization=\(settings.authorizationStatus.rawValue) alert=\(settings.alertSetting.rawValue)")
            }
        }

        registry.start(with: controller)
        Log.app.info("started monitors: \(registry.monitors.map { "\($0.id)=\(registry.isEnabled($0.id) ? "on" : "off")" }.joined(separator: ", "), privacy: .public)")
        if Defaults.showExistingAtLaunch {
            registry.fireOnLaunchNotes()
        }
    }

    // Re-opening the app from Finder / Dock brings up Preferences.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsLauncher.shared.launch()
        return true
    }
}
