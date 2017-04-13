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
    let currency = Column("currency")
    let picture = Column("picture")
    let priceHT = Column("priceWT")
    let creationDate = Column("creationDate")
    let vat = Column("vat")
    
//    static func prepare(connection:PostgreSQLConnection){
//        
//     var query:CreateTable = CreateTable(tableName: "products")
//         query.addColumn("refProduct", type: .varchar(number: 255), notNull: true, primaryKey: true)
//         query.addColumn("picture", type: .varchar(number: 255))
//         query.addColumn("name", type: .varchar(number: 255))
//         query.addColumn("vat", type: .decimal)
//         query.addColumn("currency", type: .varchar(number: 255))
//         query.addColumn("priceWT", type: .decimal)
//         query.addColumn("creationDate", type: .timestamp)
//        
//        do {
//            try db.connection.executeQuery(query: query) { result in
//                if let error = result?.asError {
//                    Log.error(String(describing: error))
//                } else {
//                    Log.info("Table prepare with Success")
//                }
//            }
//        } catch {
//            Log.error(String(describing: error))
//        }
//    }

}
