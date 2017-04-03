//
//  Store.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 30/03/2017.
//
//

import Kitura
import HeliumLogger
import SwiftKueryPostgreSQL
import SwiftKuery
import Foundation


class Store : Table {
    
    let tableName = "stores"
    let refStore = Column("id")
    let picture = Column("picture")
    let nom = Column("nom")
    let tva = Column("TVA")
    let merchantKey = Column("merchantKey")
    
    static func prepare(connection:PostgreSQLConnection){
        
        let string = "CREATE TABLE  IF NOT EXISTS stores ( "
                    + "refStore varchar(255) PRIMARY KEY NOT NULL,"
                    + "picture  varchar(255),"
                    + "nom  varchar(255),"
                    + "tva decimal,"
                    + "merchantKey  varchar(255)"
                    + ");"
        
        connection.sendQuery(query: string)
    }
    
}


