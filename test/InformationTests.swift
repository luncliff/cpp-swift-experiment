import XCTest
@testable import BaguetteBridge

final class InformationTests: XCTestCase {
    func testVersion() throws {
        let info = Information()
        XCTAssertEqual(info.version, 1)
    }
}
