import Foundation
@testable import scone
import XCTest

class SymbolTest: XCTestCase {
  var handle: UnsafeMutableRawPointer?

  override func setUp() {
    handle = dlopen("libscone_native.dylib", RTLD_NOW)
    if handle == nil {
      handle = dlopen(nil, RTLD_NOW)
    }
    XCTAssertNotNil(handle)
  }

  override func tearDown() {
    dlclose(handle)
  }

  // check protobuf symbols
  func test1() {
    let fn = dlsym(handle, "_ZTSN6google8protobuf11MessageLiteE")
    XCTAssertNotNil(fn)
  }
}
