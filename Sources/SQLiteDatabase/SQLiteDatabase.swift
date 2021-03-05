//
//  SQLiteDatabase.swift
//  SQLiteDatabase
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation

public typealias RowHandler = (Row) throws -> Void
public struct Column {
    public let name: String?
    public let value: String?
}
public struct Row {
    public let forEachColumn: ((Column) throws -> Void) throws -> Void
}

open class SQLiteDatabase {
    
    public let fileURL: URL
    public let queue: DispatchQueue
    var connection: OpaquePointer?
    
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
            try Error(resultCode: state).map { throw $0 }
        }
    }
    
    public func close() throws {
        try queue.sync {
            let state = sqlite3_close(connection)
            try Error(resultCode: state).map { throw $0 }
        }
        
    }
    
    public func query(_ statement: Statement) -> Query {
        return Query(rawStatement: statement.string, in: self)
    }
    
    public func query(_ rawStatement: String) -> Query {
        return Query(rawStatement: rawStatement, in: self)
        
    }
}


