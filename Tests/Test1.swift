import Darwin
import Foundation
import XCTest
import Dispatch

class TestCase1: XCTestCase {
    var handle: UnsafeMutableRawPointer? = nil

    override func setUp() {
      handle = dlopen("libscone_native.dylib", RTLD_NOW)
      if handle == nil {
        handle = dlopen(nil, RTLD_NOW)
        print("Using static linkage...")
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
