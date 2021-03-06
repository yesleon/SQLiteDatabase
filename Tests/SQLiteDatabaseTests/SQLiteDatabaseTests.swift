import XCTest
@testable import SQLiteDatabase

struct Entry: Decodable {
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
    
    let database = SQLiteDatabase(fileURL: .init(fileURLWithPath: ""))
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")
        
        try database.open()
        try database.query("SELECT * FROM ;").execute(as: Entry.self) { entry in
            
        }
    }
    
    func testExample2() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(SQLiteDatabase().text, "Hello, World!")
        
        try database.open()
        try database.query("SELECT * FROM TaihoaSoanntengTuichiautian;").execute { row in
            var id: String?
            var kip_input: String?
            var poj_unicode: String?
            var hoabun: String?
            do {
                try row.forEachColumn { column in
                    if id != nil, kip_input != nil, poj_unicode != nil, hoabun != nil {
                        throw Abort()
                    }
                    switch column.getName() {
                    case "id":
                        id = column.getValue()
                    case "kip_input":
                        kip_input = column.getValue()
                    case "poj_unicode":
                        poj_unicode = column.getValue()
                    case "hoabun":
                        hoabun = column.getValue()
                    default:
                        break
                    }
                }
                if let id = id {
                    let entry = Entry(id: Int(id)!, poj_unicode: poj_unicode, poj_unicode_other: nil, poj_input: nil, poj_input_other: nil, hanlo_taibun_poj: nil, kip_unicode: nil, kip_unicode_other: nil, kip_input: kip_input, kip_input_other: nil, hanji_taibun: nil, hanji_taibun_other: nil, hanlo_taibun_kip: nil, descriptions_poj: nil, descriptions_kip: nil, poj_kaisoeh: nil, hanlo_taibun_kaisoeh_poj: nil, hanlo_taibun_leku_poj: nil, hanlo_taibun_kaisoeh_kip: nil, hanlo_taibun_leku_kip: nil, kip_kaisoeh: nil, hoabun: hoabun, english: nil, author: nil)
                }
            } catch is Abort {
                
            } catch {
                throw error
            }
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
struct Abort: Swift.Error {
    
}
