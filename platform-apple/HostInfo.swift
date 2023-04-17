import Foundation
// #if os(iOS)
// import UIKit
// #endif

/// @see https://developer.apple.com/documentation/foundation/processinfo
class HostInfo {
  let info = ProcessInfo.processInfo
  var bundle: Bundle? = Bundle.main
  let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

  @objc
  init() {
    print(systemVersion())
  }

  @objc
  func backgroundQueue() -> UnsafeMutableRawPointer {
    let native = unsafeBitCast(queue, to: UnsafeMutableRawPointer.self)
    return native
  }

  @objc
  func systemVersion() -> String {
    let ver = info.operatingSystemVersion
    return "\(ver.majorVersion).\(ver.minorVersion)"
  }

  @objc
  func hostName() -> String {
    return info.hostName
  }

  @objc
  func bundlePath() -> String {
    return bundle!.bundlePath
  }
}
