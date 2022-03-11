//
//  RowDecoder.swift
//
//
//  Created by Li-Heng Hsu on 2021/3/6.
//


struct RowKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    let _values: [String: String]
    
    let codingPath: [CodingKey]
    
    var allKeys: [Key]  {
        return _values.keys
            .compactMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return _values[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
         return _values[key.stringValue] == nil
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let value = _values[key.stringValue] else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        guard let StringConvertible = T.self as? LosslessStringConvertible.Type else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Type '\(type)' not supported."))
        }
        guard let initializedValue = StringConvertible.init(value) as? T else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Failed to initialize \(value) of type \(StringConvertible)"))
        }
        return initializedValue
    }
    
    // MARK: - Nested value not supported
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Nested value not supported."))
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

@available(macOS 10.15.0, *)
final class RowDecoder: Decoder {
    
    init(row: SQLiteDatabase.Row, codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        
        var values = [String: String]()
        for (name, value) in row {
            guard let name = name, let value = value else { continue }
            values[name] = value
        }
        self._values = values
    }
    
    let codingPath: [CodingKey]
    
    let userInfo: [CodingUserInfoKey : Any]
    
    let _values: [String: String]
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = RowKeyedDecodingContainer<Key>(_values: _values, codingPath: [])
        return .init(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed value not supported."))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Single value not supported."))
    }
}
