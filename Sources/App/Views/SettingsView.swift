//
//  SettingsView.swift
//  HardwareGrowler
//
//  The Preferences window: General + Modules tabs, matching the old toolbar UI.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var registry = MonitorRegistry.shared
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        TabView {
            GeneralTab()
                .tabItem { Label("General", systemImage: "switch.2") }

            ModulesTab()
                .environmentObject(registry)
                .tabItem { Label("Modules", systemImage: "gearshape.2") }
        }
        .frame(width: 540, height: 420)
        .onAppear {
            SettingsLauncher.shared.openSettings = { openSettings() }
        }
    }
}
