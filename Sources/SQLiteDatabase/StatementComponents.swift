//
//  StatementComponents.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/5.
//

public enum Operator: String {
    case like = "LIKE"
    case equal = "="
}

public struct Condition {
    public init(column: String, operator: Operator, text: String) {
        self.column = column
        self.operator = `operator`
        self.text = text
    }
    
    var column: String
    var `operator`: Operator
    var text: String
    var string: String {
        return [column, `operator`.rawValue, text].joined(separator: " ")
    }
}


public struct SelectStatementComponents {
    public var select: [String]
    public var from: String
    public var `where` = [Condition]()
    public var orderBy: String?
    public var ascending = true
    public var limit: Int?
    public var statement: String {
        var statement = ""
        
        statement += "SELECT \(select.joined(separator: ", "))"
        statement += " FROM \(from)"
        if !`where`.isEmpty {
            statement += " WHERE"
            `where`.forEach {
                statement += " " + $0.string
            }
        }
        orderBy.map {
            statement += " ORDER BY \($0)"
            statement += ascending ? " ASC" : " DESC"
        }
        limit.map { statement += " LIMIT \($0)" }
        statement += ";"
        return statement
    }
    public init(select: [String], from: String) {
        self.select = select
        self.from = from
    }
}
