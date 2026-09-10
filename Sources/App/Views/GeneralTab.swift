//
//  GeneralTab.swift
//  HardwareGrowler
//

import SwiftUI

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
