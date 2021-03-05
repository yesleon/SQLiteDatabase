//
//  StatementComponents.swift
//  
//
//  Created by Li-Heng Hsu on 2021/3/5.
//

public enum Operator: String {
    case like = "LIKE"
    case equals = "="
}

public struct Where {
    public init(_ conditions: [Condition], isAnd: Bool) {
        self.conditions = conditions
        self.isAnd = isAnd
    }
    
    public var conditions: [Condition]
    public var isAnd: Bool
    public var string: String {
        var string = ""
        if !conditions.isEmpty {
            string += " WHERE "
            string += conditions
                .map { $0.string }
                .joined(separator: " \(isAnd ? "AND" : "OR") ")
        }
        return string
    }
}

public struct Condition {
    public init(_ column: String, _ operator: Operator, _ content: String) {
        self.column = column
        self.operator = `operator`
        self.content = content
    }
    
    public var column: String
    public var `operator`: Operator
    public var content: String
    public var string: String {
        return [column, `operator`.rawValue, content].joined(separator: " ")
    }
}

public struct Order {
    public init(by column: String, ascending: Bool) {
        self.column = column
        self.ascending = ascending
    }
    
    public var column: String
    public var ascending: Bool
    public var string: String {
        return [column, ascending ? "ASC" : "DESC"].joined(separator: " ")
    }
}


public struct SelectStatementComponents {
    public var select: [String]
    public var from: String
    public var `where` = Where([], isAnd: false)
    public var orderBy = [Order]()
    
    public var limit: Int?
    public var statement: String {
        var statement = ""
        
        statement += "SELECT \(select.joined(separator: ", "))"
        statement += " FROM \(from)"
        statement += `where`.string
        if !orderBy.isEmpty {
            
            statement += " ORDER BY"
            orderBy.forEach {
                statement += " " + $0.string
            }
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
