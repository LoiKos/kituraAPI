//
//  Product.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 31/03/2017.
//
//

import Kitura
import HeliumLogger
import LoggerAPI
import SwiftKueryPostgreSQL
import SwiftKuery
import Foundation

class Product : Table {
    
    let tableName = "products"
    
    let refProduct = Column("refProduct")
    let name = Column("name")
    let picture = Column("picture")
    let creationDate = Column("creationDate")
    
    static func prepare(pool:ConnectionPool) throws {
        
     var query:CreateTable = CreateTable(tableName: "products")
         query.addColumn("refProduct", type: .varchar(number: 255), notNull: true, primaryKey: true)
         query.addColumn("picture", type: .varchar(number: 255))
         query.addColumn("name", type: .varchar(number: 255))
         query.addColumn("creationDate", type: .timestamp)
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        connection.execute(query:query) { result in
            if let error = result.asError {
                Log.error(String(describing: error))
            } else {
                Log.info("Table prepare with Success")
            }
        }
    }

}
