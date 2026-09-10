//
//  Preferences.swift
//  HardwareGrowler
//
//  Thin ObservableObject over UserDefaults. Keys "OnLogin" and "ShowExisting"
//  are kept from the legacy app; the icon-visibility popup is replaced by two
//  independent toggles.
//

import AppKit
import Combine

final class Preferences: ObservableObject {
    static let shared = Preferences()

    private let defaults = UserDefaults.standard

    @Published var startAtLogin: Bool {
        didSet {
            guard oldValue != startAtLogin else { return }
            defaults.set(startAtLogin, forKey: Keys.onLogin)
            LoginItem.setEnabled(startAtLogin)
        }
    }

    @Published var showMenuBarIcon: Bool {
        didSet {
            guard oldValue != showMenuBarIcon else { return }
            defaults.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
        }
    }

    @Published var showDockIcon: Bool {
        didSet {
            guard oldValue != showDockIcon else { return }
            defaults.set(showDockIcon, forKey: Keys.showDockIcon)
            applyActivationPolicy()
        }
    }

    @Published var showExistingAtLaunch: Bool {
        didSet {
            guard oldValue != showExistingAtLaunch else { return }
            defaults.set(showExistingAtLaunch, forKey: Keys.showExisting)
        }
    }

    private init() {
        defaults.register(defaults: [
            Keys.onLogin: false,
            Keys.showExisting: true,
            Keys.showMenuBarIcon: true,
            Keys.showDockIcon: false,
        ])
        startAtLogin = defaults.bool(forKey: Keys.onLogin)
        showMenuBarIcon = defaults.bool(forKey: Keys.showMenuBarIcon)
        showDockIcon = defaults.bool(forKey: Keys.showDockIcon)
        showExistingAtLaunch = defaults.bool(forKey: Keys.showExisting)
    }

    func applyActivationPolicy() {
        NSApp.setActivationPolicy(showDockIcon ? .regular : .accessory)
    }

    /// Reconcile the stored toggle with the real login-item state, which the
    /// user can change from System Settings behind our back.
    func syncLoginItemStatus() {
        let actual = LoginItem.isEnabled
        if actual != startAtLogin {
            startAtLogin = actual
        }
    }

    private enum Keys {
        static let onLogin = "OnLogin"
        static let showExisting = "ShowExisting"
        static let showMenuBarIcon = "ShowMenuBarIcon"
        static let showDockIcon = "ShowDockIcon"
    }
}
