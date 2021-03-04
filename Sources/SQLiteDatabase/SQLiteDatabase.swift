//
//  SQLiteDatabase.swift
//  SQLiteDatabase
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation

public typealias RowHandler = (Row) throws -> Void
public typealias Column = (name: String?, value: String?)
public typealias Row = LazyMapSequence<LazySequence<(Range<Int>)>.Elements, Column>

open class SQLiteDatabase {
    
    public let fileURL: URL
    private var connection: OpaquePointer?
    
    public var isOpened: Bool {
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
    
    public func execute(_ statement: String, rowHandler: @escaping RowHandler) throws {
        var errorMessage: UnsafeMutablePointer<Int8>! = "".withCString {
            UnsafeMutablePointer(mutating: $0)
        }
        
        let errorMessagePointer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>! = withUnsafeMutablePointer(to: &errorMessage) {
            $0
        }
        typealias Context = (rowHandler: RowHandler, errorHandler: (Swift.Error) -> Void)
        var userError: Swift.Error?
        var context: Context = (
            rowHandler: rowHandler,
            errorHandler: { (error: Swift.Error) in
                userError = error
            }
        )

        let state = withUnsafeMutablePointer(to: &context) { context in
            return sqlite3_exec(connection, statement, { context, columnCount, values, columns in
                
                let row = (0..<Int(columnCount))
                    .lazy
                    .map { index -> Column in
                        let column = columns.flatMap { $0[index] }
                            .map { String(cString: $0) }
                        let value = values.flatMap { $0[index] }
                            .map { String(cString: $0) }
                        return (column, value)
                    }
                let context = context.map({ $0.load(as: Context.self) })!
                do {
                    try context.rowHandler(row)
                    return SQLITE_OK
                } catch {
                    context.errorHandler(error)
                    return SQLITE_ERROR
                }
                
            }, context, errorMessagePointer)
        }
        
        try userError.map { throw $0 }
        
        let message = errorMessagePointer
            .flatMap { $0.pointee }
            .map { String(cString: $0) }
            
        try Error(state, message: message).map { throw $0 }
    }
}


