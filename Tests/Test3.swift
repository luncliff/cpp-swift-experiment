import Darwin
import Foundation
import XCTest
import Dispatch

class TestCase3: XCTestCase {
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
    
    // print_message_async(dispatch_queue_s*, char const*) -> fire_and_forget
    func testSymbols(){
      let fn = dlsym(handle, "_Z19print_message_asyncP16dispatch_queue_sPKc")
      XCTAssertNotNil(fn)
      XCTAssertNil(dlsym(handle, "_Z19print_message_asyncP16dispatch_queue_sPKc.cleanup"))
      XCTAssertNil(dlsym(handle, "_Z19print_message_asyncP16dispatch_queue_sPKc.destroy"))
      XCTAssertNil(dlsym(handle, "_Z19print_message_asyncP16dispatch_queue_sPKc.resume"))
    }

    typealias Fn1 = @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>) -> UnsafeMutableRawPointer

    func getBindingFunction() -> Fn1 {
        let fn: UnsafeMutableRawPointer? = dlsym(handle, "_Z19print_message_asyncP16dispatch_queue_sPKc")
        XCTAssertNotNil(fn)
        let casted = unsafeBitCast(fn!, to: Fn1.self)
        return casted;
    }

    func testInvokeWithZero(){
        let zero = UnsafeMutableRawPointer.init(bitPattern: UInt.min)

        let fn = getBindingFunction()
        let txt: UnsafePointer<CChar> = NSString("testInvokeWithZero").utf8String!
        XCTAssertNotNil(fn(zero, txt))
    }

    func testInvokeWithQueue(){
        let queue = DispatchQueue.global(qos:DispatchQoS.QoSClass.background)
        XCTAssertNotNil(queue)
        let native = unsafeBitCast(queue, to: UnsafeMutableRawPointer.self)

        let fn = getBindingFunction()
        let txt: UnsafePointer<CChar> = NSString("testInvokeWithQueue").utf8String!
        XCTAssertNotNil(fn(native, txt))
        do {
            sleep(3)
        }
    }

}
