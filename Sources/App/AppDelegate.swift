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
        let prefs = Preferences.shared
        prefs.syncLoginItemStatus()
        prefs.applyActivationPolicy()

        let center = UNUserNotificationCenter.current()
        let registry = MonitorRegistry.shared
        let controller = NotificationController(registry: registry)
        self.controller = controller
        center.delegate = controller

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                NSLog("HardwareGrowler: notification authorization error: \(error)")
            } else if !granted {
                NSLog("HardwareGrowler: notification authorization denied")
            }
        }

        registry.start(with: controller)
        Log.app.info("started \(registry.monitors.count) monitors: \(registry.monitors.map { "\($0.id)=\(registry.isEnabled($0.id) ? "on" : "off")" }.joined(separator: ", "), privacy: .public)")
        if prefs.showExistingAtLaunch {
            registry.fireOnLaunchNotes()
        }
    }

    // Re-opening the app from Finder / Dock opens Preferences.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        return true
    }
}
