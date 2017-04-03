//
//  Product.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 31/03/2017.
//
//

import Kitura
import HeliumLogger
import SwiftKueryPostgreSQL
import SwiftKuery
import Foundation

class Product : Table {
    
    let tableName = "product"
    let refProduct = Column("refProduct")
    let name = Column("name")
    let currency = Column("currency")
    let picture = Column("picture")
    let priceHT = Column("priceHT")
    let creationDate = Column("creationDate")
    let tva = Column("tva")
    
    static func prepare(connection:PostgreSQLConnection){
        
        let string = "CREATE TABLE  IF NOT EXISTS products ( "
            + "refProduct varchar(255) PRIMARY KEY NOT NULL,"
            + "picture  varchar(255),"
            + "name   varchar(255),"
            + "tva decimal,"
            + "currency  varchar(255),"
            + "priceHT  decimal,"
            + "creationDate TIMESTAMP WITH TIME ZONE"
            + ");"
        
        connection.sendQuery(query: string)
    }

}
