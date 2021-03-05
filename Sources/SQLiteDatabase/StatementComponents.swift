//
//  StatementComponents.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/5.
//




public struct StatementComponents {
    public var select: String
    public var from: String
    public var `where`: String?
    public var orderBy: String?
    public var limit: Int?
    public var statement: String {
        var statement = ""
        statement += "SELECT \(select)"
        statement += "FROM \(from)"
        `where`.map { statement += "WHERE \($0)" }
        orderBy.map { statement += "ORDER BY \($0)" }
        limit.map { statement += "LIMIT \($0)" }
        statement += ";"
        return statement
    }
    public init(select: String, from: String) {
        self.select = select
        self.from = from
    }
}
