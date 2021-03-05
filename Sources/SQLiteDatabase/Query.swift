//
//  Query.swift
//  
//
//  Created by 許立衡 on 2021/3/6.
//

import Foundation
import SQLite3

public typealias RowHandler = (Row) throws -> Void
public typealias ColumnHandler = (inout Column) throws -> Void

public struct Row {
    public let forEachColumn: (ColumnHandler) throws -> Void
}

public struct Column {
    public let getName: () -> String?
    public let getValue: () -> String?
}

public struct Query {
    public let execute: (@escaping RowHandler) throws -> Void

    public init(statement: String, in database: SQLiteDatabase?) {

        self.execute = { [weak database] rowHandler in
            guard let database = database else { throw Error(resultCode: SQLITE_MISUSE, message: "Database does not exist.", statement: statement)! }
            try database.queue.sync { [weak database] in
                
                var errorMessage: UnsafeMutablePointer<Int8>!
                    = "".withCString { UnsafeMutablePointer(mutating: $0) }
                
                let errorMessagePointer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>!
                    = withUnsafeMutablePointer(to: &errorMessage) { $0 }
                
                typealias Context = (rowHandler: RowHandler, errorHandler: (Swift.Error) -> Void)
                var userError: Swift.Error?
                var context: Context = (
                    rowHandler: rowHandler,
                    errorHandler: { (error: Swift.Error) in
                        userError = error
                    }
                )
                
                let state = withUnsafeMutablePointer(to: &context) { context in
                    return sqlite3_exec(database?.connection, statement, { context, columnCount, values, columns in
                        let columnCount = Int(columnCount)
                        let context = context!.load(as: Context.self)
                        
                        do {
                            let row = Row { columnHandler in
                                for index in 0..<columnCount {
                                    var column = Column(
                                        getName: { columns?[index].map { String(cString: $0) } },
                                        getValue: { values?[index].map { String(cString: $0) } }
                                    )
                                    try columnHandler(&column)
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
                
                try Error(resultCode: state, message: message, statement: statement).map { throw $0 }
            }
        }
    }
}
