//
//  SQLiteDatabase.swift
//  SQLiteDatabase
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation

public typealias RowHandler = (Row) throws -> Void
public struct Query {
    public let forEachRow: (@escaping (Row) throws -> Void) throws -> Void
}
public struct Column {
    public let name: String?
    public let value: String?
}
public struct Row {
    public let forEachColumn: ((Column) throws -> Void) throws -> Void
}


open class SQLiteDatabase {
    
    public let fileURL: URL
    let queue: DispatchQueue
    private var connection: OpaquePointer?
    
    public var isOpened: Bool {
        connection != nil
    }
    
    public init(fileURL: URL, queue: DispatchQueue? = nil) {
        self.fileURL = fileURL
        self.queue = queue ?? .init(label: "com.narrativesaw.SQLiteDatabase.queue")
    }
    
    public func open() throws {
        try queue.sync {
            let state = sqlite3_open(fileURL.path, &connection)
            try Error(state).map { throw $0 }
        }
    }
    
    public func close() throws {
        try queue.sync {
            let state = sqlite3_close(connection)
            try Error(state).map { throw $0 }
        }
        
    }
    
    public func query(_ statement: String) -> Query {
        return Query { [weak self] rowHandler in
            guard let self = self else { return }
            return try self.queue.sync {
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
                    return sqlite3_exec(self.connection, statement, { context, columnCount, values, columns in
                        
                        
                        let context = context.map({ $0.load(as: Context.self) })!
                        do {
                            
                            let row = Row { columnHandler in
                                
                                try (0..<Int(columnCount))
                                    .forEach { index in
                                        let column = columns.flatMap { $0[index] }
                                            .map { String(cString: $0) }
                                        let value = values.flatMap { $0[index] }
                                            .map { String(cString: $0) }
                                        try columnHandler(Column(name: column, value: value))
                                    }
                            }
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
        
    }
}


