//
//  Error.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/4.
//


import SQLite3

public struct Error: Swift.Error {
    public let resultCode: Int32
    public let message: String?
    public init?(_ resultCode: Int32, message: String? = nil) {
        switch resultCode {
        case SQLITE_OK, SQLITE_ROW, SQLITE_DONE:
            return nil
        default:
            self.resultCode = resultCode
        }
        self.message = message
    }
}
