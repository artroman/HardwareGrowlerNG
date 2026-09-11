//
//  MonitorPrefViews.swift
//  HardwareGrowler
//
//  Per-monitor settings panes. Each binds directly to the UserDefaults keys
//  the corresponding Objective-C monitor already reads, so no extra plumbing
//  is needed. A running monitor picks up changes on its next internal refresh
//  (or on next launch).
//

import SwiftUI
import IOKit.hid

// MARK: - Keyboard

struct KeyboardPrefsView: View {
    private static let key = "hwgkeyboardkeysenabled"

    @State private var capsLock = read("capslock", default: true)
    @State private var fnKey = read("fnkey", default: false)
    @State private var shiftKey = read("shiftkey", default: false)

    var body: some View {
        Form {
            Section {
                Toggle("Caps Lock", isOn: $capsLock)
                Toggle("FN Key", isOn: $fnKey)
                Toggle("Shift Key", isOn: $shiftKey)
            } header: {
                Text("Notify For")
            } footer: {
                Text("Watching modifier keys globally requires Input Monitoring "
                     + "permission (below).")
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            InputMonitoringStatusSection()
        }
        .formStyle(.grouped)
        .onChange(of: capsLock) { _, value in Self.write("capslock", value) }
        .onChange(of: fnKey) { _, value in Self.write("fnkey", value) }
        .onChange(of: shiftKey) { _, value in Self.write("shiftkey", value) }
    }

    private static func read(_ subKey: String, default fallback: Bool) -> Bool {
        let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Bool]
        return dict?[subKey] ?? fallback
    }

    private static func write(_ subKey: String, _ value: Bool) {
        var dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Bool] ?? [:]
        dict[subKey] = value
        UserDefaults.standard.set(dict, forKey: key)
    }
}

private struct InputMonitoringStatusSection: View {
    @State private var status: IOHIDAccessType = InputMonitoringAuth.status

    var body: some View {
        Section("Input Monitoring") {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                Text(statusText)
                Spacer()
                actionButton
            }
        }
        .onAppear(perform: refresh)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refresh()
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch status {
        case kIOHIDAccessTypeUnknown:
            Button("Request Access") {
                _ = InputMonitoringAuth.request()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { refresh() }
            }
        case kIOHIDAccessTypeDenied:
            Button("Open Input Monitoring Settings…") {
                InputMonitoringAuth.openSystemSettings()
            }
        default:
            EmptyView()
        }
    }

    private var statusText: String {
        switch status {
        case kIOHIDAccessTypeGranted: return "Access granted"
        case kIOHIDAccessTypeDenied: return "Access denied for HardwareGrowler"
        default: return "Access not requested yet"
        }
    }

    private var iconName: String {
        switch status {
        case kIOHIDAccessTypeGranted: return "checkmark.circle.fill"
        case kIOHIDAccessTypeDenied: return "exclamationmark.triangle.fill"
        default: return "questionmark.circle"
        }
    }

    private var iconColor: Color {
        switch status {
        case kIOHIDAccessTypeGranted: return .green
        case kIOHIDAccessTypeDenied: return .orange
        default: return .secondary
        }
    }

    private func refresh() {
        status = InputMonitoringAuth.status
    }
}

// MARK: - Power

struct PowerPrefsView: View {
    @AppStorage("EnablePowerRefire") private var enableRefire = true
    @AppStorage("PowerRefireTime") private var refireMinutes = 10.0
    @AppStorage("RefireOnBattery") private var refireOnlyOnBattery = true

    var body: some View {
        Form {
            Section {
                Toggle("Refire battery status", isOn: $enableRefire)

                HStack {
                    Text("Refire every")
                    Spacer()
                    TextField("", value: $refireMinutes, format: .number)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text("minutes")
                }
                .disabled(!enableRefire)

                Toggle("Refire only on battery", isOn: $refireOnlyOnBattery)
                    .disabled(!enableRefire)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Volume

struct VolumePrefsView: View {
    private static let key = "HWGVolumeMonitorExceptions"

    @State private var entries: [String] = VolumePrefsView.load()
    @State private var selection: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ignored Drives")
                .font(.headline)

            List(selection: $selection) {
                ForEach(entries.indices, id: \.self) { index in
                    TextField("Name or path (trailing * matches a prefix)",
                              text: Binding(
                                get: { entries.indices.contains(index) ? entries[index] : "" },
                                set: { entries[index] = $0; save() }))
                    .tag(index)
                }
            }
            .frame(minHeight: 160)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))

            HStack(spacing: 4) {
                Button {
                    entries.append("")
                    selection = entries.count - 1
                    save()
                } label: {
                    Image(systemName: "plus")
                }

                Button {
                    if let index = selection, entries.indices.contains(index) {
                        entries.remove(at: index)
                        selection = nil
                        save()
                    }
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
            }
            .buttonStyle(.bordered)
        }
    }

    private static func load() -> [String] {
        let raw = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? []
        return raw.compactMap { $0["justastring"] }
    }

    private func save() {
        let raw = entries.map { ["justastring": $0] }
        UserDefaults.standard.set(raw, forKey: Self.key)
    }
}

// MARK: - Previews

#Preview("Keyboard") {
    KeyboardPrefsView()
        .frame(width: 420, height: 220)
}

#Preview("Power") {
    PowerPrefsView()
        .frame(width: 420, height: 220)
}

#Preview("Volume") {
    VolumePrefsView()
        .padding()
        .frame(width: 420, height: 280)
}
