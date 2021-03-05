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
        
        var a = Sentence(select: ["a"], from: "b")
        a.where = .init([.init("c", .equals, "d"), .init("e", .like, "f")], isAnd: true)
        
        var b = a
        b.from = "g"
        
        let h = SelectStatementComponents(sentences: [a, b])
        print(h.string)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
