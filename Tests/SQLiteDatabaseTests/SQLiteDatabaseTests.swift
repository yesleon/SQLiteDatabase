import XCTest
@testable import SQLiteDatabase

final class SQLiteDatabaseTests: XCTestCase {
    let database = SQLiteDatabase(fileURL: URL(fileURLWithPath: ""))
    
    override func setUp() {
        super.setUp()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")
        
            
        let expectation = self.expectation(description: "================")
        expectation.assertForOverFulfill = false
        
        try! self.database.open()
        
        try! self.database.execute("") { row in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            error.map { print($0) }
        }
        
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
