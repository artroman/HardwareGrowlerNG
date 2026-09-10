//
//  LoginItem.swift
//  HardwareGrowler
//
//  Launch-at-login via SMAppService (macOS 13+), replacing the old
//  SMLoginItemSetEnabled + HardwareGrowlerLauncher helper app.
//

import ServiceManagement

enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            NSLog("HardwareGrowler: failed to set login item to \(enabled): \(error)")
        }
    }
}
