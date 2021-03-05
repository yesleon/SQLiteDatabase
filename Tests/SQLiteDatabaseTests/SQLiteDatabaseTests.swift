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
        
        var a = SelectStatementComponents(select: ["a"], from: "b")
        a.where = .init([.init("c", .equals, "d"), .init("e", .like, "f")], isAnd: true)
        print(a.statement)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
