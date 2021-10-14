import XCTest

@testable import scone

class TestCase2: XCTestCase {
    override func setUp() {
    }
    override func tearDown() {
    }

    func test1() {
      let req = scone.V1_Request()
      XCTAssertTrue(req.blob.isEmpty)
    }
    func test2() {
      let res = scone.V1_Response()
      XCTAssertTrue(res.blob.isEmpty)
    }
    
}
