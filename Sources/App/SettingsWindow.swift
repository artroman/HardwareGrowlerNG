//
//  SettingsWindow.swift
//  HardwareGrowler
//
//  Opening the Settings scene from a menu-bar (accessory) app does not bring
//  the app forward, so the window can appear behind everything. This helper
//  activates the app and pulls the window to the front.
//

import AppKit

enum SettingsWindow {
    /// SwiftUI's internal autosave name for the `Settings` scene window.
    static let autosaveName = "com_apple_SwiftUI_Settings_window"

    static func show() {
        NSApp.activate(ignoringOtherApps: true)

        if let existing = window() {
            bringToFront(existing)
            return
        }

        // Same selector SettingsLink uses under the hood (macOS 13+).
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)

        DispatchQueue.main.async {
            if let created = window() {
                bringToFront(created)
            }
        }
    }

    private static func window() -> NSWindow? {
        NSApp.windows.first { $0.frameAutosaveName == autosaveName }
    }

    private static func bringToFront(_ window: NSWindow) {
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}
