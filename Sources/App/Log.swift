//
//  Log.swift
//  HardwareGrowler
//

import OSLog

enum Log {
    static let app = Logger(subsystem: "com.hwgrowler.HardwareGrowler", category: "app")
    static let monitors = Logger(subsystem: "com.hwgrowler.HardwareGrowler", category: "monitors")
    static let notifications = Logger(subsystem: "com.hwgrowler.HardwareGrowler", category: "notifications")
}
