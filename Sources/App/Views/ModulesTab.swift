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
                    HStack(spacing: 10) {
                        Image(nsImage: MonitorIcon.image(named: monitor.iconName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                        Text(monitor.displayName)
                        Spacer(minLength: 8)
                        Toggle("", isOn: registry.binding(for: monitor.id))
                            .labelsHidden()
                            .toggleStyle(.checkbox)
                    }
                    .padding(.vertical, 6)
                    .tag(monitor.id)
                }
            }
            .listStyle(.inset)
            .frame(width: 230)

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
        .frame(width: 640, height: 510)
}
