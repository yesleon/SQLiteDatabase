//
//  RowDecoder.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/6.
//


class RowKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    var container: [String: () -> String?] = [:]
    
    var codingPath: [CodingKey] { [] }
    
    var allKeys: [Key]  {
        []
    }
    
    func set(row: Row) throws {
        var container = [String: () -> String?]()
        try row.forEachColumn { column in
            guard let name = column.getName() else { return }
            container[name] = column.getValue
        }
        self.container = container
    }
    
    func contains(_ key: Key) -> Bool {
        container.keys.contains(key.stringValue)
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

final class RowDecoder: Decoder {
    
    var row: Row!
    
    var codingPath: [CodingKey] { [] }
    
    var userInfo: [CodingUserInfoKey : Any] { [:] }
    var containers: [String: Any] = [:]
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let typeName = String(describing: type)
        if let container = containers[typeName] as? RowKeyedDecodingContainer<Key> {
            return KeyedDecodingContainer<Key>(container)
        } else {
            let container = RowKeyedDecodingContainer<Key>()
            try container.set(row: row)
            containers[String(describing: type)] = container
            return KeyedDecodingContainer<Key>(container)
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed value not supported."))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Single value not supported."))
    }
    
    
}

