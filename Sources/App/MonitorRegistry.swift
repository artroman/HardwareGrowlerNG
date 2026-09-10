//
//  MonitorRegistry.swift
//  HardwareGrowler
//
//  Instantiates the hardware monitors directly (no loadable bundles), tracks
//  their enabled state, and drives their lifecycle. Replaces the plugin-loading
//  half of the old HWGrowlPluginController.
//

import AppKit
import SwiftUI

/// Every ported monitor conforms to both halves of the plugin contract.
typealias HardwareMonitor = HWGrowlPluginProtocol & HWGrowlPluginNotifierProtocol

/// Plain value type for the UI. Deliberately holds no reference to the
/// Objective-C plugin: a SwiftUI key path (`\.id`) into a struct that stores an
/// existential of composed `@objc` protocols crashes the Swift runtime's
/// key-path metadata resolver.
struct MonitorInfo: Identifiable, Hashable {
    let id: String
    let displayName: String
    let symbolName: String
}

final class MonitorRegistry: ObservableObject {
    static let shared = MonitorRegistry()

    let monitors: [MonitorInfo]
    @Published private(set) var enabledByID: [String: Bool] = [:]

    private let plugins: [String: any HardwareMonitor]
    private var started: Set<String> = []
    private weak var controller: NotificationController?
    private let defaults = UserDefaults.standard
    private let disabledKey = "DisabledPlugins"

    private init() {
        let specs: [(id: String, symbol: String, plugin: any HardwareMonitor)] = [
            ("USBMonitor",         "cable.connector",        HWGrowlUSBMonitor()),
            ("BluetoothMonitor",   "dot.radiowaves.right",   HWGrowlBluetoothMonitor()),
            ("NetworkMonitor",     "network",                HWGrowlNetworkMonitor()),
            ("PowerMonitor",       "bolt.fill",              HWGrowlPowerMonitor()),
            ("ThunderboltMonitor", "bolt.horizontal.circle", HWGrowlThunderboltMonitor()),
            ("TimeMachineMonitor", "clock.arrow.circlepath", HWGrowlTimeMachineMonitor()),
            ("VolumeMonitor",      "externaldrive",          HWGrowlVolumeMonitor()),
            ("KeyboardMonitor",    "keyboard",               HWGrowlKeyboardMonitor()),
        ]

        monitors = specs.map {
            MonitorInfo(id: $0.id, displayName: $0.plugin.pluginDisplayName(), symbolName: $0.symbol)
        }
        plugins = Dictionary(uniqueKeysWithValues: specs.map { ($0.id, $0.plugin) })

        let disabledDict = defaults.dictionary(forKey: disabledKey) as? [String: Bool] ?? [:]
        for spec in specs {
            if let disabled = disabledDict[spec.id] {
                enabledByID[spec.id] = !disabled
            } else {
                enabledByID[spec.id] = spec.plugin.enabledByDefault?() ?? true
            }
        }
    }

    // MARK: - Lifecycle

    func start(with controller: NotificationController) {
        self.controller = controller
        for plugin in plugins.values {
            plugin.setDelegate(controller)
        }
        // Only bring up monitors that are enabled. Some (Keyboard, Time Machine)
        // request TCC permission in -postRegistrationInit, so a disabled monitor
        // must stay dormant until the user turns it on.
        for (id, plugin) in plugins where isEnabled(id) {
            plugin.postRegistrationInit?()
            started.insert(id)
        }
    }

    func fireOnLaunchNotes() {
        for monitor in monitors where isEnabled(monitor.id) {
            plugins[monitor.id]?.fireOnLaunchNotes?()
        }
    }

    func notifyClosed(pluginClass: String, context: String, byClick: Bool) {
        guard let plugin = plugins.values.first(where: {
            NSStringFromClass(type(of: $0)) == pluginClass
        }) else { return }
        plugin.noteClosed?(context, byClick: byClick)
    }

    // MARK: - Enabled state

    func isEnabled(_ id: String) -> Bool {
        enabledByID[id] ?? true
    }

    func isEnabled(plugin: AnyObject) -> Bool {
        guard let entry = plugins.first(where: { ($0.value as AnyObject) === plugin }) else {
            return true
        }
        return isEnabled(entry.key)
    }

    func setEnabled(_ enabled: Bool, for id: String) {
        enabledByID[id] = enabled

        if enabled {
            if !started.contains(id), controller != nil {
                plugins[id]?.postRegistrationInit?()
                started.insert(id)
            }
            plugins[id]?.startObserving?()
        } else {
            plugins[id]?.stopObserving?()
        }

        var dict = defaults.dictionary(forKey: disabledKey) as? [String: Bool] ?? [:]
        dict[id] = !enabled
        defaults.set(dict, forKey: disabledKey)
    }

    func binding(for id: String) -> Binding<Bool> {
        Binding(get: { [weak self] in self?.isEnabled(id) ?? true },
                set: { [weak self] newValue in self?.setEnabled(newValue, for: id) })
    }
}
