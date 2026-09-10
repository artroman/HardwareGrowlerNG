//
//  Log.swift
//  HardwareGrowler
//

import Foundation
import OSLog

enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "HardwareGrowler"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let monitors = Logger(subsystem: subsystem, category: "monitors")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
}
