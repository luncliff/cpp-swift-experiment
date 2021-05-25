import Darwin
import Foundation
import XCTest

class TestCase1: XCTestCase {
  var handle: UnsafeMutableRawPointer? = nil

  override func setUp() {
    handle = dlopen("libgloom_pb.dylib", RTLD_NOW)
    XCTAssertNotNil(handle)
  }
  override func tearDown() {
    dlclose(handle)
  }

  func test1() {
    let fn = dlsym(handle, "_ZTSN6google8protobuf11MessageLiteE")
    XCTAssertNotNil(fn)
  }
}
