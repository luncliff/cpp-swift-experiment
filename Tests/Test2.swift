import XCTest

@testable import Gloom

class TestCase2: XCTestCase {
    override func setUp() {
    }
    override func tearDown() {
    }

    func test1() {
      let req = Gloom.V1_Request()
      XCTAssertTrue(req.blob.isEmpty)
    }
    func test2() {
      let res = Gloom.V1_Response()
      XCTAssertTrue(res.blob.isEmpty)
    }
    
}
