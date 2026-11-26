// Nudge a display's origin for this login session and restore it.
// Fires a CoreGraphics display reconfiguration (moved) without touching cables.
// usage: display_nudge <did> <dy> [hold_seconds]
import CoreGraphics
import Foundation

let args = CommandLine.arguments
guard args.count >= 3, let did = UInt32(args[1]), let dy = Int32(args[2]) else {
  FileHandle.standardError.write("usage: display_nudge <did> <dy> [hold_seconds]\n".data(using: .utf8)!)
  exit(2)
}
let hold = args.count > 3 ? Double(args[3]) ?? 1 : 1
let b = CGDisplayBounds(did)

func move(_ x: Int32, _ y: Int32) {
  var cfg: CGDisplayConfigRef?
  guard CGBeginDisplayConfiguration(&cfg) == .success else { exit(1) }
  CGConfigureDisplayOrigin(cfg, did, x, y)
  guard CGCompleteDisplayConfiguration(cfg, .forSession) == .success else { exit(1) }
}

move(Int32(b.origin.x), Int32(b.origin.y) + dy)
Thread.sleep(forTimeInterval: hold)
move(Int32(b.origin.x), Int32(b.origin.y))
print("nudged did=\(did) dy=\(dy) and restored to \(Int(b.origin.x)),\(Int(b.origin.y))")
