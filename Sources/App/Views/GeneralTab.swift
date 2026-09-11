//
//  GeneralTab.swift
//  HardwareGrowler
//

import SwiftUI
import UserNotifications

struct GeneralTab: View {
    @AppStorage(Defaults.Key.onLogin) private var startAtLogin = false
    @AppStorage(Defaults.Key.showMenuBarIcon) private var showMenuBarIcon = true
    @AppStorage(Defaults.Key.showDockIcon) private var showDockIcon = false
    @AppStorage(Defaults.Key.showExisting) private var showExistingAtLaunch = true

    var body: some View {
        Form {
            Section {
                Toggle("Start HardwareGrowler at login", isOn: $startAtLogin)
                    .onChange(of: startAtLogin) { _, enabled in
                        LoginItem.setEnabled(enabled)
                    }
            }

            Section("Icon") {
                Toggle("Show icon in the menu bar", isOn: $showMenuBarIcon)
                Toggle("Show icon in the Dock", isOn: $showDockIcon)
                    .onChange(of: showDockIcon) { _, _ in
                        Defaults.applyActivationPolicy()
                    }
            }

            Section {
                Toggle("Show connected devices at launch", isOn: $showExistingAtLaunch)
            } footer: {
                Text("When enabled, HardwareGrowler posts a notification for every "
                     + "device already connected when it starts up.")
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            NotificationStatusSection()

            if !showMenuBarIcon && !showDockIcon {
                Section {
                    Label("With both icons hidden, reopen HardwareGrowler from Finder "
                          + "to get back to this window.", systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview("General") {
    GeneralTab()
        .frame(width: 540, height: 420)
}

private struct NotificationStatusSection: View {
    @State private var status: UNAuthorizationStatus = .notDetermined

    var body: some View {
        Section("Notifications") {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                Text(statusText)
                Spacer()
                actionButton
            }

            Button("Send Test Notification") {
                NotificationAuth.sendTestNotification()
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
        case .notDetermined:
            Button("Request Permission") {
                NotificationAuth.request()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { refresh() }
            }
        case .denied:
            Button("Open Notification Settings…") {
                NotificationAuth.openSystemSettings()
            }
        default:
            EmptyView()
        }
    }

    private var statusText: String {
        switch status {
        case .authorized, .provisional, .ephemeral: return "Notifications are enabled"
        case .denied: return "Notifications are turned off for HardwareGrowler"
        case .notDetermined: return "Permission not requested yet"
        @unknown default: return "Unknown notification status"
        }
    }

    private var iconName: String {
        switch status {
        case .authorized, .provisional, .ephemeral: return "checkmark.circle.fill"
        case .denied: return "exclamationmark.triangle.fill"
        default: return "questionmark.circle"
        }
    }

    private var iconColor: Color {
        switch status {
        case .authorized, .provisional, .ephemeral: return .green
        case .denied: return .orange
        default: return .secondary
        }
    }

    private func refresh() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { status = settings.authorizationStatus }
        }
    }
}
