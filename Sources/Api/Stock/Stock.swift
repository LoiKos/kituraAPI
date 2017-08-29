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

    let refStore = Column("refStore", Varchar.self, length:255)
    let refProduct = Column("refProduct", Varchar.self, length:255)
    let quantity = Column("quantity", Int32.self)
    let creationDate = Column("creationDate", Timestamp.self)
    let lastUpdate = Column("lastUpdate", Timestamp.self)
    let status = Column("status", Varchar.self, length:255)
    let priceHT = Column("priceHT", Double.self)
    let vat = Column("vat", Double.self)

    static func prepare(pool:ConnectionPool) throws {
        let query : String = "CREATE TABLE IF NOT EXISTS stock ( "
                           + "refStore varchar(255) NOT NULL REFERENCES stores,"
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
