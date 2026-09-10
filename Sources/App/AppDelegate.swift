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

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                NSLog("HardwareGrowler: notification authorization error: \(error)")
            } else if !granted {
                NSLog("HardwareGrowler: notification authorization denied")
            }
        }

        registry.start(with: controller)
        Log.app.info("started monitors: \(registry.monitors.map { "\($0.id)=\(registry.isEnabled($0.id) ? "on" : "off")" }.joined(separator: ", "), privacy: .public)")
        if Defaults.showExistingAtLaunch {
            registry.fireOnLaunchNotes()
        }
    }

    // Re-opening the app from Finder / Dock brings up Preferences. Prefer
    // fronting an already-open Settings window; only ask SwiftUI to create one
    // otherwise (that path logs a benign "use SettingsLink" diagnostic).
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        if let settings = NSApp.windows.first(where: {
            $0.frameAutosaveName == "com_apple_SwiftUI_Settings_window"
        }) {
            settings.makeKeyAndOrderFront(nil)
        } else {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        return true
    }
}
