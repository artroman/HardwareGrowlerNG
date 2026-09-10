//
//  Defaults.swift
//  HardwareGrowler
//
//  Plain namespace over UserDefaults. The UI binds to these keys with
//  @AppStorage directly; this type is for non-UI reads and side effects.
//  (An ObservableObject here caused "Publishing changes from within view
//  updates" loops with MenuBarExtra + the Settings scene.)
//

import AppKit

enum Defaults {
    enum Key {
        static let onLogin = "OnLogin"
        static let showExisting = "ShowExisting"
        static let showMenuBarIcon = "ShowMenuBarIcon"
        static let showDockIcon = "ShowDockIcon"
    }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.onLogin: false,
            Key.showExisting: true,
            Key.showMenuBarIcon: true,
            Key.showDockIcon: false,
        ])
    }

    static var showExistingAtLaunch: Bool {
        UserDefaults.standard.bool(forKey: Key.showExisting)
    }

    static var showDockIcon: Bool {
        UserDefaults.standard.bool(forKey: Key.showDockIcon)
    }

    static func applyActivationPolicy() {
        NSApp.setActivationPolicy(showDockIcon ? .regular : .accessory)
    }

    /// Reconcile the stored toggle with the real login-item state (the user can
    /// change it from System Settings behind our back).
    static func syncLoginItem() {
        UserDefaults.standard.set(LoginItem.isEnabled, forKey: Key.onLogin)
    }
}
