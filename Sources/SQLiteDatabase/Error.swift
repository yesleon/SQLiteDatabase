//
//  Error.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/4.
//


import SQLite3

extension Database {
    
    public enum Error: Swift.Error {
        case databaseFailure(resultCode: Int32, message: String?, statement: String?)
        case userError(Swift.Error, statement: String)
       
        public init?(resultCode: Int32, message: String? = nil, statement: String? = nil) {
            switch resultCode {
            case SQLITE_OK, SQLITE_ROW, SQLITE_DONE:
                return nil
            default:
                self = .databaseFailure(resultCode: resultCode, message: message, statement: statement)
            }
        }
    }
}
