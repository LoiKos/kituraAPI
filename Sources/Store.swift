//
//  Store.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 30/03/2017.
//
//

import Kitura
import HeliumLogger
import LoggerAPI
import SwiftKueryPostgreSQL
import SwiftKuery
import Foundation

class Store : Table {
    
    let tableName = "stores"
    
    let refStore = Column("refStore")
    let picture = Column("picture")
    let name = Column("name")
    let vat = Column("vat")
    let merchantKey = Column("merchantKey")
    
//    static func prepare(connection:PostgreSQLConnection){
//        
//        var query:CreateTable = CreateTable(tableName: "stores")
//            query.addColumn("refStore", type: .varchar(number: 255), notNull: true, primaryKey: true)
//            query.addColumn("picture", type: .varchar(number: 255))
//            query.addColumn("name", type: .varchar(number: 255))
//            query.addColumn("vat", type: .decimal)
//            query.addColumn("merchantKey", type: .varchar(number: 255))
//       
//        do {
//            
//            try db.connection.executeQuery(query: query) { result in
//                if let error = result?.asError {
//                    Log.error(String(describing: error))
//                }
//                else {
//                    Log.info("Table prepare with Success")
//                }
//            }
//        } catch {
//             Log.error(String(describing: error))
//        }
//    }
    
}


