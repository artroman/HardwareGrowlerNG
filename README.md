# HardwareGrowler NG

A modern rebuild of Growl's **HardwareGrowler** hardware-event notifier for
Apple Silicon macOS. Notifications go through the system notification centre
(`UNUserNotificationCenter`) instead of the retired Growl; the UI is SwiftUI.

## Status

Builds and runs on macOS 14+ as a universal binary (arm64 + x86_64).
Verified working: monitor bootstrap, Network / Power / Volume events, live
notification delivery.

| Monitor      | Notes |
|--------------|-------|
| USB          | ported verbatim (IOKit) |
| Bluetooth    | ported; needs the Bluetooth TCC prompt |
| Network      | ported; Wi‑Fi SSID/BSSID need Location permission on modern macOS |
| Power        | ported (IOPowerSources) |
| Thunderbolt  | ported (IOKit) |
| Volume       | ported (NSWorkspace mount/unmount) |
| Keyboard     | ported; global modifier watching needs **Input Monitoring** permission; off by default |
| Time Machine | ported but **inert** — it reads `com.apple.backupd` via ASL, which no longer carries those logs. Needs an `OSLogStore` rewrite. Off by default. |
| FireWire / Phone | dropped (no Apple Silicon Mac has FireWire; Phone used Bluetooth HFP) |

## Build

```sh
brew install xcodegen           # one-time
xcodegen generate               # regenerate HardwareGrowlerNG.xcodeproj from project.yml
open HardwareGrowlerNG.xcodeproj
```

The `.xcodeproj` is generated and git-ignored — edit `project.yml`, not the project.

## Layout

```
Sources/App/          SwiftUI app, AppDelegate, Preferences, NotificationController, MonitorRegistry
Sources/App/Views/    Settings window (General + Modules tabs) and per-monitor panes
Sources/PluginKit/    HardwareGrowlPlugin.h (plugin contract), GrowlNetworkUtilities, bridging + compat headers
Sources/Monitors/     the 8 Objective-C hardware monitors, ported from Extras/HardwareGrowler
Resources/            .icns, menu-bar icons, notification icons (lossless WebP)
```

## Architecture notes

* The monitors are compiled straight into the app — no loadable plugin bundles.
* They talk to `NotificationController` through the original
  `HWGrowlPluginControllerProtocol` seam (`notifyWithName:title:…`).
* `HWGCompat.pch` aliases a handful of renamed 2012-era AppKit/IOKit symbols so
  the monitor `.m` files compile unmodified (they are manual retain/release, so
  the whole target builds with ARC disabled).
* Launch-at-login uses `SMAppService`; the old `HardwareGrowlerLauncher` helper
  app is gone.
* Dock / menu-bar visibility are two independent toggles driving
  `NSApp.setActivationPolicy` and `MenuBarExtra`'s `isInserted`.
