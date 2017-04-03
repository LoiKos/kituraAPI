//
//  Database.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 31/03/2017.
//
//

import Foundation
import SwiftKueryPostgreSQL
import SwiftKuery

struct DatabaseConfig {
    
    var host : String = "127.0.0.1"
    var port : Int = 5432
    var databaseName : String = "postgres"
    var userName : String = "postgres"
    var password : String = ""
    
    init(host : String = "127.0.0.1",port : Int = 5432,databaseName : String = "postgres",userName : String = "postgres",password : String = ""){
        self.host = host
        self.port = port
        self.databaseName = databaseName
        self.userName = userName
        self.password = password
    }
    
    // TODO: Init with file
    
    // Map config to match SwiftKuery model
    func connection() -> PostgreSQLConnection {
        var options = [ConnectionOptions]()
        options.append(.databaseName(self.databaseName))
        options.append(.password(self.password))
        options.append(.userName(self.userName))
        return PostgreSQLConnection(host: self.host, port: Int32(self.port) , options: options)
    }
}



extension PostgreSQLConnection {
    
    /**
     Simple function to send a query 
     
     
     */
    public func sendQuery(query:Query, completionHandler: (Any, Error) -> ()) throws {
            let string = try query.build(queryBuilder:queryBuilder)
            sendQuery(query: string)
    }
    
    public func sendQuery(query:String){
        self.connect() { error in
            if let error = error {
                print("We get an error trying to connect your database : \(error)")
            } else {
                self.execute(query){ result in
                    switch result {
                    case .successNoData:
                        break
                    case .error:
                        print("Can't prepare database correctly \(result)")
                        break
                    default:
                        break
                    }
                    self.closeConnection()
                }
            }
        }
    }
}
