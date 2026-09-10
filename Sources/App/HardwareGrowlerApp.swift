//
//  HardwareGrowlerApp.swift
//  HardwareGrowler
//
//  SwiftUI entry point. The app runs as a menu-bar agent (LSUIElement);
//  the AppDelegate owns the monitor lifecycle, this scene owns the UI.
//

import SwiftUI

@main
struct HardwareGrowlerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(Defaults.Key.showMenuBarIcon) private var showMenuBarIcon = true

    var body: some Scene {
        MenuBarExtra(isInserted: $showMenuBarIcon) {
            Button("HardwareGrowler Preferences…") {
                SettingsWindow.show()
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit HardwareGrowler") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        } label: {
            Image(nsImage: MenuBarIcon.image)
        }

        Settings {
            SettingsView()
        }
    }
}

/// The menu-bar status icon, loaded from the bundled template PNG with an
/// SF Symbol fallback.
enum MenuBarIcon {
    static let image: NSImage = {
        let image = NSImage(named: "menubarIcon_Normal")
            ?? NSImage(systemSymbolName: "bolt.horizontal.circle",
                       accessibilityDescription: "HardwareGrowler")
            ?? NSImage()
        image.isTemplate = true
        image.size = NSSize(width: 18, height: 18)
        return image
    }()
}
