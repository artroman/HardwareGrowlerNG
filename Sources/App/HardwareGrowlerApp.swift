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
                SettingsLauncher.shared.launch()
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit HardwareGrowler") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        } label: {
            MenuBarLabel()
        }

        Settings {
            SettingsView()
        }
    }
}
