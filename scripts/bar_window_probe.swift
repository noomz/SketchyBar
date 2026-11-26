// Print, every 0.5 s, how many on-screen windows a pid owns inside the top bar strip.
// usage: bar_window_probe <pid> <seconds>
import CoreGraphics
import Foundation

let pid = Int32(CommandLine.arguments[1])!
let secs = Double(CommandLine.arguments[2]) ?? 60
let fmt = DateFormatter(); fmt.dateFormat = "HH:mm:ss.S"
let end = Date().addingTimeInterval(secs)
var last = ""
while Date() < end {
  let all = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
  var total = 0, onscreen = 0, visible = 0
  for w in all where (w[kCGWindowOwnerPID as String] as? Int32) == pid {
    let b = w[kCGWindowBounds as String] as? [String: CGFloat] ?? [:]
    guard (b["Y"] ?? 999) < 40, (b["Height"] ?? 0) <= 40 else { continue }
    total += 1
    if (w[kCGWindowIsOnscreen as String] as? Bool) == true {
      onscreen += 1
      if ((w[kCGWindowAlpha as String] as? CGFloat) ?? 0) > 0 { visible += 1 }
    }
  }
  let line = "total=\(total) onscreen=\(onscreen) visible=\(visible)"
  if line != last { print(fmt.string(from: Date()), line); fflush(stdout); last = line }
  Thread.sleep(forTimeInterval: 0.5)
}
print(fmt.string(from: Date()), "end", last)
