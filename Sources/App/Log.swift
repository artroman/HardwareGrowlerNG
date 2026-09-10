//
//  Log.swift
//  HardwareGrowler
//

import OSLog

enum Log {
    static let app = Logger(subsystem: "com.growl.HardwareGrowlerNG", category: "app")
    static let monitors = Logger(subsystem: "com.growl.HardwareGrowlerNG", category: "monitors")
    static let notifications = Logger(subsystem: "com.growl.HardwareGrowlerNG", category: "notifications")
}
