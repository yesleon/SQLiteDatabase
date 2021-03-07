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

public struct Sentence {
    public var select: [String]
    public var from: String?
    public var replace: (in: String, from: String, to: String)?
    public var `where` = Where([], isAnd: false)
    public var string: String {
        var string = ""
        
        string += "SELECT \(select.joined(separator: ", "))"
        replace.map { string += " replace(\($0.in),'\($0.from)','\($0.to)')" }
        from.map { string += " FROM \($0)" }
        string += `where`.string
        return string
    }
    public init(select: [String], from: String) {
        self.select = select
        self.from = from
    }
}

public enum UnionType: String {
    case union = "UNION", unionAll = "UNION ALL"
}

public struct SelectStatement {
    public init(sentences: [Sentence], unionType: UnionType = .union) {
        self.sentences = sentences
        self.unionType = unionType
    }
    public var unionType: UnionType
    public var sentences: [Sentence]
    public var orderBy = [Order]()
    public var limit: Int?
    public var string: String {
        var string = sentences
            .map { $0.string }
            .joined(separator: " \(unionType.rawValue) ")
        
        if !orderBy.isEmpty {
            
            string += " ORDER BY"
            orderBy.forEach {
                string += " " + $0.string
            }
        }
        limit.map { string += " LIMIT \($0)" }
        string += ";"
        return string
    }
}
