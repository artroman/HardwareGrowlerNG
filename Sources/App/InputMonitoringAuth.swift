//
//  InputMonitoringAuth.swift
//  HardwareGrowler
//
//  Helpers for the Input Monitoring status shown in the Keyboard monitor's
//  settings pane. KeyboardMonitor watches modifier keys globally, which needs
//  this permission — and unlike Notifications/Bluetooth, macOS won't show its
//  prompt unless something explicitly calls IOHIDRequestAccess.
//

import AppKit
import IOKit.hid

enum InputMonitoringAuth {
    static var status: IOHIDAccessType {
        IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
    }

    /// Synchronous: shows the system prompt and blocks until answered if the
    /// user hasn't been asked yet.
    @discardableResult
    static func request() -> Bool {
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    }

    static func openSystemSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent",
            "x-apple.systempreferences:com.apple.preference.security",
        ]
        for string in candidates {
            if let url = URL(string: string), NSWorkspace.shared.open(url) {
                return
            }
        }
    }
}
