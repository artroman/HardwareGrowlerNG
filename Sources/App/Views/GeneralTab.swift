//
//  GeneralTab.swift
//  HardwareGrowler
//

import SwiftUI

struct GeneralTab: View {
    @EnvironmentObject private var prefs: Preferences

    var body: some View {
        Form {
            Section {
                Toggle("Start HardwareGrowler at login", isOn: $prefs.startAtLogin)
            }

            Section("Icon") {
                Toggle("Show icon in the menu bar", isOn: $prefs.showMenuBarIcon)
                Toggle("Show icon in the Dock", isOn: $prefs.showDockIcon)
            }

            Section {
                Toggle("Show connected devices at launch", isOn: $prefs.showExistingAtLaunch)
            } footer: {
                Text("When enabled, HardwareGrowler posts a notification for every "
                     + "device already connected when it starts up.")
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            if !prefs.showMenuBarIcon && !prefs.showDockIcon {
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
