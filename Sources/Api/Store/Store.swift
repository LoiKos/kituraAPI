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
    
    let refStore = Column("refStore",Varchar.self, length:255, primaryKey:true, notNull:true, unique:true)
    let name = Column("name", Varchar.self, length: 255)
    let picture = Column("picture", Varchar.self, length: 255)
    let vat = Column("vat", Double.self)
    let currency = Column("currency", Varchar.self, length: 255)
    let merchantKey = Column("merchantKey", Varchar.self, length: 255)
    
    static func prepare(pool:ConnectionPool) throws {
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        self.init().create(connection: connection){ result in
            guard result.success else {
                Log.error("creation error :\(String(describing: result.asError))")
                return
            }
            Log.info("Table create with success")
        }
    }
    
}


