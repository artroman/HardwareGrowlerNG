//
//  SettingsWindow.swift
//  HardwareGrowler
//
//  Opening the Settings scene from a menu-bar (accessory) app does not bring
//  the app forward, so the window can appear behind everything — or, via the
//  AppKit selector, not appear at all on recent macOS. We capture SwiftUI's
//  `openSettings` action from a live view and drive it from here.
//

import SwiftUI

@MainActor
final class SettingsLauncher {
    static let shared = SettingsLauncher()

    /// Set by `MenuBarLabel` once the scene is live.
    var openSettings: (() -> Void)?

    static let autosaveName = "com_apple_SwiftUI_Settings_window"

    func launch() {
        NSApp.activate(ignoringOtherApps: true)

        if let openSettings {
            openSettings()
        } else {
            // No live view has handed us the SwiftUI action yet (e.g. the menu
            // bar icon is hidden and Settings has never been opened). Fall back
            // to the AppKit selector; it logs a dev-only diagnostic but works.
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }

        // The window is created asynchronously; pull it in front once it exists.
        DispatchQueue.main.async { [self] in
            bringToFront()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in bringToFront() }
        }
    }

    private func bringToFront() {
        guard let window = NSApp.windows.first(where: {
            $0.frameAutosaveName == Self.autosaveName
        }) else { return }
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}

/// The menu-bar status icon. Also the always-rendered view we use to capture
/// the `openSettings` environment action for use outside the view tree.
struct MenuBarLabel: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Image(nsImage: MenuBarIcon.image)
            .onAppear {
                SettingsLauncher.shared.openSettings = { openSettings() }
            }
    }
}

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
