import CoreGraphics
import Darwin

let args = CommandLine.arguments
let owner = args.count > 1 ? args[1] : "sketchybar"
var height = 34.0
if args.count > 2 {
    guard let parsedHeight = Double(args[2]), parsedHeight.isFinite, parsedHeight > 0 else {
        print("Usage: swift scripts/check-main-bar-width.swift [window-owner] [bar-height]")
        exit(2)
    }
    height = parsedHeight
}

let displayID = CGMainDisplayID()
let screen = CGDisplayBounds(displayID)
let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] ?? []
let bar = windows.compactMap { window -> CGRect? in
    guard (window[kCGWindowOwnerName as String] as? String)?.lowercased() == owner.lowercased(),
          let bounds = window[kCGWindowBounds as String] as? [String: Any],
          let rect = CGRect(dictionaryRepresentation: bounds as CFDictionary),
          rect.height == height, rect.intersects(screen) else { return nil }
    return rect
}.max { $0.width < $1.width }

let display = "main display id=\(displayID) x=\(screen.minX) width=\(screen.width)"
guard let bar else {
    print("FAIL: \(display); no visible \(owner) window with height \(height)")
    exit(1)
}

let fullWidth = bar.minX == screen.minX && bar.maxX == screen.maxX
print("\(fullWidth ? "PASS" : "FAIL"): \(display); \(owner) bar x=\(bar.minX) width=\(bar.width)")
exit(fullWidth ? 0 : 1)
