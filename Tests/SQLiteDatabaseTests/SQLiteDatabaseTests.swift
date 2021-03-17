import XCTest
@testable import SQLiteDatabase

struct Entry {
    let id: Int
    let poj_unicode: String?
    let poj_unicode_other: String?
    let poj_input: String?
    let poj_input_other: String?
    let hanlo_taibun_poj: String?
    let kip_unicode: String?
    let kip_unicode_other: String?
    let kip_input: String?
    let kip_input_other: String?
    let hanji_taibun: String?
    let hanji_taibun_other: String?
    let hanlo_taibun_kip: String?
    let descriptions_poj: String?
    let descriptions_kip: String?
    let poj_kaisoeh: String?
    let hanlo_taibun_kaisoeh_poj: String?
    let hanlo_taibun_leku_poj: String?
    let hanlo_taibun_kaisoeh_kip: String?
    let hanlo_taibun_leku_kip: String?
    let kip_kaisoeh: String?
    let hoabun: String?
    let english: String?
    let author: String?
}



final class SQLiteDatabaseTests: XCTestCase {
    
    let database = Database(fileURL: .init(fileURLWithPath: "/Users/hsuliheng/Developer/TaigiDict/TaigiDict/database.sqlite"), queue: .main)
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")
        let database = self.database
        measure {
            
            let expectation = XCTestExpectation()
            
            
            database.open { error in
                if let error = error {
                    print(error)
                    expectation.fulfill()
                    return
                }
                var values = [Any]()
                database.execute("SELECT * FROM KauiokpooTaigiSutian;") { error in
                    expectation.fulfill()
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    print(values.count)
                } rowHandler: { row in
                    for (name, value) in row {
//                        values.append(value)
                    }
                }
            }
            wait(for: [expectation], timeout: 120)
        }
        
    }
}

