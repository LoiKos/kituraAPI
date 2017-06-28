//
//  table_store.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 04/04/2017.
//
//

import Foundation
import SwiftKuery
import SwiftKueryPostgreSQL
import LoggerAPI

class Stock : Table {
    
    let tableName = "stock"
    
    let refStore = Column("refStore")
    let refProduct = Column("refProduct")
    let quantity = Column("quantity")
    let creationDate = Column("creationDate")
    let lastUpdate = Column("lastUpdate")
    let status = Column("status")
    let priceHT = Column("priceHT")
    let vat = Column("vat")
    
    static func prepare() throws {
        let query : String = "CREATE TABLE IF NOT EXISTS stock ( refStore varchar(255) NOT NULL REFERENCES stores,"
                           + "refProduct varchar(255) NOT NULL REFERENCES products,"
                           + "quantity integer,"
                           + "creationDate timestamp,"
                           + "lastUpdate timestamp,"
                           + "status varchar(45),"
                           + "priceHT decimal,"
                           + "vat decimal,"
                           + "PRIMARY KEY (refStore,refProduct) );"
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }

        connection.execute(query) { result in
            if let error = result.asError {
                Log.error(String(describing: error))
            } else {
                Log.info("Table prepare with Success")
            }
        }
    }
}

