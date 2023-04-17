import Darwin
import Dispatch
import Foundation
import XCTest

@testable import BaguetteBridge

class TestCase1: XCTestCase {
  var bridge: BaguetteBridge?
  var handle: UnsafeMutableRawPointer?

  override func setUp() {
    bridge = BaguetteBridge()
    handle = bridge!.nativeHandle()
    XCTAssertNotNil(handle)
  }

  func testSelectorSymbols() {
    XCTAssertNotNil(dlsym(handle, "_ZN2NS7Private8Selector8s_kallocE"))
  }

  func testCppSymbols() {
    XCTAssertNotNil(dlsym(handle, "_ZN10experiment31get_objc_runtime_error_categoryEv"))
  }
}
