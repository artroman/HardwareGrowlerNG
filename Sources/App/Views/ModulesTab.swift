//
//  ModulesTab.swift
//  HardwareGrowler
//
//  Left: monitors with an enable checkbox. Right: that monitor's settings,
//  or a placeholder when it has none.
//

import SwiftUI

struct ModulesTab: View {
    @EnvironmentObject private var registry: MonitorRegistry
    @State private var selection: String?

    var body: some View {
        // A plain HStack + Divider keeps the separator within the content area.
        // HSplitView draws its divider across the whole window, up behind the
        // tab bar.
        HStack(spacing: 0) {
            List(selection: $selection) {
                ForEach(registry.monitors) { monitor in
                    HStack(spacing: 8) {
                        Image(systemName: monitor.symbolName)
                            .frame(width: 18)
                            .foregroundStyle(.tint)
                        Text(monitor.displayName)
                        Spacer(minLength: 8)
                        Toggle("", isOn: registry.binding(for: monitor.id))
                            .labelsHidden()
                            .toggleStyle(.checkbox)
                    }
                    .tag(monitor.id)
                }
            }
            .listStyle(.inset)
            .frame(width: 220)

            Divider()

            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case "KeyboardMonitor":
            KeyboardPrefsView()
        case "PowerMonitor":
            PowerPrefsView()
        case "VolumeMonitor":
            VolumePrefsView()
        default:
            ContentUnavailableView(
                "No Preferences",
                systemImage: "slider.horizontal.3",
                description: Text("There are no preferences available for this monitor.")
            )
        }
    }
}

#Preview("Modules") {
    ModulesTab()
        .environmentObject(MonitorRegistry.shared)
        .frame(width: 540, height: 420)
}
