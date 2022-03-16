//
//  Database.swift
//  Database
//
//  Created by Li-Heng Hsu on 2021/3/3.
//

import SQLite3
import Foundation
import Combine


public actor SQLiteDatabase {
    
    public struct Error: Swift.Error {
        let resultCode: Int32, message: String?, statement: String?
       
        init?(resultCode: Int32, message: String? = nil, statement: String? = nil) {
            switch resultCode {
            case SQLITE_OK, SQLITE_ROW, SQLITE_DONE:
                return nil
            default:
                self.resultCode = resultCode
                self.message = message
                self.statement = statement
            }
        }
    }
    
    public typealias Row = [Column]
    public typealias Column = (name: String?, value: String?)
    
    public let fileURL: URL
    
    private var connection: OpaquePointer?
    
    public var isOpen: Bool {
        connection != nil
    }
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func open() throws {
        
        let state = sqlite3_open(fileURL.path, &connection)
        try Error(resultCode: state).map { throw $0 }
    }
    
    public func close() throws {
        
        let state = sqlite3_close(connection)
        try Error(resultCode: state).map { throw $0 }
    }
    
    public func execute(_ statement: String) throws -> [Row] {
        
        try "".withCString { emptyString in
            
            var errorMessage = Optional(UnsafeMutablePointer(mutating: emptyString))
            
            return try withUnsafeMutablePointer(to: &errorMessage) { errorMessagePointer in
                
                typealias RowHandler = (Row) -> Void
                var rows = [Row]()
                var rowHandler: RowHandler = { row in
                    rows.append(row)
                }
                
                try withUnsafeMutablePointer(to: &rowHandler) { rowHandlerPointer in
                    
                    let state = sqlite3_exec(connection, statement, { rowHandlerPointer, columnCount, values, columns in
                        
                        guard let rowHandler = rowHandlerPointer?.load(as: RowHandler.self) else { return SQLITE_ERROR }
                        
                        var row = Row()
                        for index in 0..<Int(columnCount) {
                            let name = columns?[index].map { String(cString: $0) }
                            let value = values?[index].map { String(cString: $0) }
                            row.append((name: name, value: value))
                        }
                        rowHandler(row)
                        return SQLITE_OK
                    }, rowHandlerPointer, errorMessagePointer)
                    
                    if let error = Error(resultCode: state, message: errorMessagePointer.pointee.map({ String(cString: $0) }), statement: statement) {
                        throw error
                    }
                }
                return rows
            }
        }
    }
    
    nonisolated public func publisher(for statement: String
    ) -> AnyPublisher<[Row], Swift.Error> {
        
        Future { promise in
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    if await !self.isOpen {
                        try await self.open()
                    }
                    let result = try await self.execute(statement)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
            
        }.eraseToAnyPublisher()
    }
}
