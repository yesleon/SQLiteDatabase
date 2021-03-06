import XCTest
@testable import SQLiteDatabase

struct Entry: Decodable {
    let id: Int
    let kip_input: String
}

final class SQLiteDatabaseTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
