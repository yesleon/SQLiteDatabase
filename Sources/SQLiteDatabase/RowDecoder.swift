//
//  RowDecoder.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/6.
//
import Combine

struct RowKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    let container: [String: () -> String?]
    
    
    init(row: Row) throws {
        var container = [String: () -> String?]()
        var keys = [Key]()
        try row.forEachColumn { column in
            guard let name = column.getName() else { return }
            guard let key = Key(stringValue: name) else { return }
            container[name] = column.getValue
            keys.append(key)
        }
        self.container = container
        self.allKeys = keys
    }
    
    let codingPath: [CodingKey] = []
    
    let allKeys: [Key]
    
    func contains(_ key: Key) -> Bool {
        container[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        guard let getValue = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key.debugDescription)"))
        }
        return getValue() == nil
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let getValue = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key.debugDescription)"))
        }
        guard let value = getValue() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        guard let U = T.self as? LosslessStringConvertible.Type else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Type '\(type)' not supported."))
        }
        guard let initializedValue = U.init(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Failed to initialize \(value) of type \(U)"))
        }
        return initializedValue as! T
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Type '\(type)' not supported."))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Nested value not supported."))
    }
    
    func superDecoder() throws -> Decoder {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Nested value not supported."))
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Nested value not supported."))
    }
    
    
}

public final class RowDecoder: TopLevelDecoder {
    
    public typealias Input = Row
    
    public init() { }
    
    public func decode<T: Decodable>(_ type: T.Type, from row: Row) throws -> T {
        let decoder = __RowDecoder(row: row, userInfo: [:])
        return try T(from: decoder)
    }
}

final class __RowDecoder: Decoder {
    
    let row: Row
    
    let codingPath: [CodingKey] = []
    
    let userInfo: [CodingUserInfoKey : Any]
    
    init(row: Row, userInfo: [CodingUserInfoKey: Any]) {
        self.row = row
        self.userInfo = userInfo
    }
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = try RowKeyedDecodingContainer<Key>(row: row)
        
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed value not supported."))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Single value not supported."))
    }
    
    
}

