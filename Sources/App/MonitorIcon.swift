//
//  MonitorIcon.swift
//  HardwareGrowler
//
//  Loads the original app's HWGPrefs* monitor icons (now bundled as .webp)
//  for the Modules list.
//

import AppKit

enum MonitorIcon {
    private static var cache: [String: NSImage] = [:]

    static func image(named name: String) -> NSImage {
        if let cached = cache[name] {
            return cached
        }
        let image: NSImage
        if let path = Bundle.main.path(forResource: name, ofType: "webp"),
           let loaded = NSImage(contentsOfFile: path) {
            image = loaded
        } else {
            image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: name)
                ?? NSImage()
        }
        cache[name] = image
        return image
    }
}
