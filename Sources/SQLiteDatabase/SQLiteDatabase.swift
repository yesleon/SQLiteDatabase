//
//  SQLiteDatabase.swift
//  SQLiteDatabase
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation

public typealias RowsHandler = (((String, String) -> Void) -> Void) -> Void
private var handlers = [UUID: RowsHandler]()

public class SQLiteDatabase {
    
    public let fileURL: URL
    private var connection: OpaquePointer?
    var isOpened: Bool {
        connection != nil
    }
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func open() throws {
        let state = sqlite3_open(fileURL.path, &connection)
        try Error(state).map { throw $0 }
    }
    
    public func close() throws {
        let state = sqlite3_close(connection)
        try Error(state).map { throw $0 }
    }
    
    public func execute(_ statement: String, rowsHandler: @escaping RowsHandler) throws {
        var errorMessage: UnsafeMutablePointer<Int8>! = "".withCString {
            UnsafeMutablePointer(mutating: $0)
        }
        
        let errorMessagePointer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>! = withUnsafeMutablePointer(to: &errorMessage) {
            $0
        }
        let uuid = UUID()
        handlers[uuid] = rowsHandler
        var input = uuid.uuid

        let state = withUnsafeMutablePointer(to: &input) { input in
            return sqlite3_exec(connection, statement, { input, columnCount, values, columns in
                
                input
                    .map { $0.load(as: uuid_t.self) }
                    .map { UUID(uuid: $0) }
                    .flatMap { handlers[$0] }
                    .map { handler in
                        
                        handler { completion in
                            (0..<Int(columnCount))
                                .lazy
                                .compactMap { index -> (String, String)? in
                                    guard let column = columns?[index] else { return nil }
                                    guard let value = values?[index] else { return nil }
                                    return (String(cString: column), String(cString: value))
                                }
                                .forEach(completion)
                        }
                    }
                        
                
                
                return SQLITE_OK
            }, input, errorMessagePointer)
        }
        
        handlers.removeValue(forKey: uuid)
        
        let message = errorMessagePointer
            .flatMap { $0.pointee }
            .map { String(cString: $0) }
            
        try Error(state, message: message).map { throw $0 }
    }
}


