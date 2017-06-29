//
//  createDB.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 03/04/2017.
//
//

import Foundation
import SwiftKuery
import SwiftKueryPostgreSQL


/** 
 
 Create table from your code
 
 - Requires: 
    - SwiftKuery
    - SwiftKueryPostgreSQL
 
 - Author: Loic LE PENN
 
 - Date: April 4, 2017
 
 - Version: 1.0
*/
public struct CreateTable : Query {
    
    private let tableName: String
    private let ifNotExist: Bool
    private var columns: [TableColumn] = [TableColumn]()
    
    init(tableName: String, ifNotExist: Bool = true) {
        self.tableName = tableName
        self.ifNotExist = ifNotExist
    }

    
    /**
     
     Build the query to string to be executed in postgreSQL
     
     - parameters:
        - queryBuilder: Swift Kuery tool to build query
     
     - Author: Loic LE PENN
     
     - Date: April 4, 2017
     
     - Version: 1.0
     
     - throws: to match signature but the method should never throw
     */
    
    public func build(queryBuilder: QueryBuilder) throws -> String {
        
            var result = ""
        
            result += "CREATE TABLE"
        
            if(ifNotExist){
                result += " IF NOT EXISTS"
            }
            result += " \(tableName) (\n"
        
            for (index,column) in columns.enumerated() {
                
                result.append("\(column.name) \(column.type)")
                
                if(column.primaryKey) {
                    result.append(" PRIMARY KEY")
                }
                
                if(column.unique) {
                    result.append(" UNIQUE")
                }
                
                if(column.notNull) {
                    result.append(" NOT NULL")
                }
                
                if(index < columns.count - 1 ){
                    result.append(",\n")
                }
            }
        
            result += ");"
            return result
    }
    
    /**
     
     Add a column to your table
     
     - parameters:
        - name: name of a column
        - type: type of a column based on enum `ColumnType`
        - unique: specified if column values should be unique
        - notNull: specified if column values should be not null        
        - primaryKey: specified if the column is a primary key of your table
     
     - Author: Loic LE PENN
     
     - Date: April 4, 2017
     
     - Version: 1.0
     */
    mutating func addColumn(_ name: String, type: ColumnType, unique: Bool = false, notNull: Bool = false, primaryKey: Bool = false){
        columns.append(TableColumn(name: name, type: type, unique: unique, notNull: notNull, primaryKey: primaryKey))
    }
    
}

/**
 
 Struct that represents column skeleton's
 
 - Author: Loic LE PENN
 
 - Date: April 4, 2017
 
 - Version: 1.0
 */
private struct TableColumn {
    
    var name: String
    var type: ColumnType
    var unique: Bool
    var notNull: Bool
    var primaryKey: Bool
    
    init(name:String,type: ColumnType, unique: Bool = false, notNull: Bool = false, primaryKey: Bool = false){
        self.name = name
        self.type = type
        self.unique = unique
        self.notNull = notNull
        self.primaryKey = primaryKey
    }
    
}

/**
 
 Enum column type for postgreSQL
 
 - Author: Loic LE PENN
 
 - Date: April 4, 2017
 
 - Version: 1.0
 */
enum ColumnType : CustomStringConvertible {
    
    case bigint
    case bigserial
    case bit(number:Int)
    case bitVarying(number:Int)
    case boolean
    case bytea
    case char(number: Int)
    case varchar(number: Int)
    case cidr
    case circle
    case date
    case float8
    case inet
    case integer
    case json
    case jsonb
    case line
    case lseg
    case macaddr
    case money
    case numeric(precision : Int, scale: Int)
    case decimal
    case path
    case point
    case polygon
    case real
    case smallint
    case smallserial
    case serial
    case text
    case time
    case timestamp
    case uuid
    case xml
    
    var description: String {
        switch self {
            case .bigint:
                return "bigint"
            case .bigserial:
                return "bigserial"
            case .bit(let n):
                return "bit(\(n))"
            case .bitVarying(let n):
                return "bit varying(\(n))"
            case .boolean:
                return "boolean"
            case .bytea:
                return "bytea"
            case .char(let n):
                return "char(\(n))"
            case .varchar(let n):
                return "varchar(\(n))"
            case .cidr:
                return "cidr"
            case .circle:
                return "circle"
            case .date:
                return "date"
            case .float8:
                return "double precision"
            case .inet:
                return "inet"
            case .integer:
                return "integer"
            case .json:
                return "json"
            case .jsonb:
                return "jsonb"
            case .line:
                return "line"
            case .lseg:
                return "lseg"
            case .macaddr:
                return "macaddr"
            case .money:
                return "money"
            case .numeric(let precision, let scale):
                return "decimal(\(precision),\(scale))"
            case .decimal:
                return "decimal"
            case .path:
                return "path"
            case .point:
                return "point"
            case .polygon:
                return "polygon"
            case .real:
                return "real"
            case .smallint:
                return "smallint"
            case .smallserial:
                return "smallserial"
            case .serial:
                return "serial"
            case .text:
                return "text"
            case .time:
                return "time without time zone"
            case .timestamp:
                return "timestamp without time zone"
            case .uuid:
                return "uuid"
            case .xml:
                return "xml"
        }
    }
}
