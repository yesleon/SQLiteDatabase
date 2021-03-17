//
//  Query.swift
//  
//
//  Created by 許立衡 on 2021/3/6.
//

import Foundation
import SQLite3

extension Database {
    
    public struct Row: Hashable {
        private let _columnCount: Int32
        private let _names: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
        private let _values: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
        
        init(
            columnCount: Int32,
            names: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
            values: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
        ) {
            
            self._names = names
            self._values = values
            self._columnCount = columnCount
        }
    }
}

extension Database.Row: RandomAccessCollection {
    
    public typealias Column = (String?, String?)

    public subscript(position: Int) -> Column {
        
        var name: String?
        if let cString = _names?[position] {
            name = String(cString: cString)
        }
        
        var value: String?
        if let cString = _values?[position] {
            value = String(cString: cString)
        }
        
        return (name, value)
    }

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        Int(_columnCount)
    }
}
