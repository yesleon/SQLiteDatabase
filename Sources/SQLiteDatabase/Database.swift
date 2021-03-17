//
//  Database.swift
//  Database
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation



public final class Database {
    
    public typealias RowHandler = (Row) throws -> Void
    public typealias CompletionHandler = (Error?) -> Void
    
    public let fileURL: URL
    
    private let queue: DispatchQueue
    
    private var connection: OpaquePointer?
    
    public var isOpened: Bool {
        connection != nil
    }
    
    public init(fileURL: URL, queue: DispatchQueue? = nil) {
        self.fileURL = fileURL
        self.queue = queue ?? DispatchQueue(label: "com.narrativesaw.SQLiteDatabase.queue", qos: .userInitiated)
    }
    
    public func open(completionHandler: @escaping CompletionHandler) {
        
        queue.async { [self] in
            let state = sqlite3_open(fileURL.path, &connection)
            completionHandler(Error(resultCode: state))
        }
    }
    
    public func close(completionHandler: @escaping CompletionHandler) {
        
        queue.async { [self] in
            let state = sqlite3_close(connection)
            completionHandler(Error(resultCode: state))
        }
    }
    
    public func execute<Item: Decodable>(
        _ statement: String,
        completionHandler: @escaping CompletionHandler,
        itemHandler: @escaping (Item) throws -> Void
    ) {
        self.execute(statement, completionHandler: completionHandler) { row in
            let item = try Item(from: RowDecoder(row: row, codingPath: [], userInfo: [:]))
            try itemHandler(item)
        }
    }
    
    public func execute(
        _ statement: String,
        completionHandler: @escaping CompletionHandler,
        rowHandler: @escaping RowHandler
    ) {
        
        queue.async { [self] in
            
            var errorMessage = Optional("")?.withCString { UnsafeMutablePointer(mutating: $0) }
            
            let errorMessagePointer = withUnsafeMutablePointer(to: &errorMessage, Optional.init)
            
            var userError: Swift.Error?
            
            typealias Context = (rowHandler: (Any) -> Void, errorHandler: (Swift.Error) -> Void)
            
            var context: Context = (
                rowHandler: { input in
                    let input = input as! (Int32, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?)
                    let row = Row(columnCount: input.0, names: input.1, values: input.2)
                    try! rowHandler(row)
                },
                errorHandler: { userError = $0 }
            )
            
            let contextPointer = withUnsafeMutablePointer(to: &context) { $0 }
            
            let state = sqlite3_exec(
                connection,
                statement,
                { rawContext, columnCount, values, columns in
                    
//                    let context = rawContext!.load(as: Context.self)
                    let opaquePointer = OpaquePointer(rawContext)
                    let pointer = UnsafeMutablePointer<Context>(opaquePointer)
                    let context = pointer!.pointee
                    let rowHandler = context.rowHandler
                    
//                    let row = Row(columnCount: columnCount, names: columns, values: values)
                    rowHandler(1)
                    return SQLITE_OK
//                    do {
//                        try
//                        return SQLITE_OK
//                    } catch {
//                        context.errorHandler(error)
//                        return SQLITE_ERROR
//                    }
                    
                },
                contextPointer,
                errorMessagePointer
            )
            
            if let error = userError {
                completionHandler(.userError(error, statement: statement))
            } else if let errorMessage = errorMessage {
                let message = String(cString: errorMessage)
                completionHandler(.databaseFailure(resultCode: state, message: message, statement: statement))
            } else {
                completionHandler(nil)
            }
            
        }
    }
}
