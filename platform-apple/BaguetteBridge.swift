import Darwin
import Dispatch
import Foundation

class BaguetteBridge {
  var handle: UnsafeMutableRawPointer?

  init() {
    handle = dlopen("libbaguette.dylib", RTLD_NOW)
    if handle == nil {
      handle = dlopen(nil, RTLD_NOW)
    }
  }

  deinit {
    dlclose(handle)
  }

  func nativeHandle() -> UnsafeMutableRawPointer? {
    return handle
  }
}
