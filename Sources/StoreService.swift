//
//  StoreHandler.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import SwiftKueryPostgreSQL
import LoggerAPI
import SwiftyJSON
import SwiftKuery

class StoreService{
    
    let store = Store()
    
    let connection : PostgreSQLConnection
    
    init(connection : PostgreSQLConnection){
        self.connection = connection
    }
    
    func create(json:JSON, completionHandler: @escaping (_ id: String?,_ error: Error?) throws -> Void) throws {
        guard let name = json["name"].string else {
            throw ErrorHandler.MissingRequireProperty("name")
        }
        
        var tuples = [(Column, Any)]()
        let id = generateRef()
        tuples.append((store.refStore, id))
        tuples.append((store.name,name))
        
        if let picture = json["picture"].string {
            tuples.append((store.picture,picture))
        }
        if let vat = json["vat"].string {
            tuples.append((store.vat,vat))
        }
        if let merchantKey = json["merchantKey"].string {
            tuples.append((store.merchantKey,merchantKey))
        }
        
        let db_query = Insert(into: store, valueTuples: tuples)
        
        try connection.sendQuery(query:db_query){ result, error in
            do {
                if let success = result?.success {
                    success ? try completionHandler(id,error) : try completionHandler(nil,error)
                } else {
                    try completionHandler(nil,error)
                }
            } catch {
                Log.error(" [StoreService] Completion error failed ")
            }
        }
    }
    
    func findAll(){
        // TODO:
    }
    
}
