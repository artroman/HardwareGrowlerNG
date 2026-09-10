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
        HSplitView {
            List(registry.monitors, id: \.id, selection: $selection) { monitor in
                HStack(spacing: 8) {
                    Image(systemName: monitor.symbolName)
                        .frame(width: 18)
                        .foregroundStyle(.tint)
                    Text(monitor.displayName)
                    Spacer()
                    Toggle("", isOn: registry.binding(for: monitor.id))
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                }
                .tag(monitor.id)
            }
            .listStyle(.inset)
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 300)

            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
