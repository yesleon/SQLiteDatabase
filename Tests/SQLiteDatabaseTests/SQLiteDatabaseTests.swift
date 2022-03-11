import XCTest
@testable import SQLiteDatabase

struct Entry: Codable {
    let DictWordID: Int?
    let PojUnicode: String?
    let PojUnicodeOthers: String?
    let PojInput: String?
    let PojInputOthers: String?
    let KipUnicode: String?
    let KipUnicodeOthers: String?
    let KipInput: String?
    let KipInputOthers: String?
    let HanLoTaibunKip: String?
    let KipDictHanjiTaibunOthers: String?
    let KipDictWordProperty: String?
    let KaisoehHanLoPoj: String?
    let HoaBun: String?
    let KaisoehHanLoKip: String?
    let KipDictDialects: String?
    let Synonym: String?
    let Opposite: String?
}



final class SQLiteDatabaseTests: XCTestCase {
    
    let database = SQLiteDatabase(fileURL: .init(fileURLWithPath: "/Users/hsuliheng/Developer/Taigi/Taigi/ChhoeTaigiDatabase/dicts.db"))
    
    @available(iOS 13.0, *)
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")
        let database = self.database
        measure {
            let expectation = XCTestExpectation()
            Task {
                
                
                do {
                    try await database.open()
                    var values = [Any]()
//                    values = try await database.executeLazily("SELECT * FROM KauiokpooTaigiSutian;")
                    try await database.execute2("SELECT * FROM ChhoeTaigi_KauiokpooTaigiSutian;").map { try Entry(from: RowDecoder(row: $0)) }
                        .first.map {
                            print($0)
                        }
                        
//                        .map { try Entry(from: RowDecoder(row: $0, codingPath: [], userInfo: [:])) }
//                        .forEach { print($0) }
//                    for try await row in await database.execute("SELECT * FROM KauiokpooTaigiSutian;") {
////                        for (name, value) in row {
////                            values.append(value)
////                        }
//                    }
//                    try await database.execute("SELECT * FROM KauiokpooTaigiSutian;") { row in
//                        for (name, value) in row {
//                            values.append(value)
//                        }
//                    }
                    print(values.count)
                    expectation.fulfill()
                } catch {
                    print(error)
                    
                    expectation.fulfill()
                }
            }
            wait(for: [expectation], timeout: 120)
            
        }
        
    }
}

