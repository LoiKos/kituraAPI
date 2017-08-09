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
import LoggerAPI

struct Database {

    private var host : String
    private var port : Int32
    private var databaseName : String
    private var userName : String
    private var password : String

    public var pool: ConnectionPool

    init() throws {

        guard let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
            let port_string = ProcessInfo.processInfo.environment["DATABASE_PORT"],
            let port = Int32(port_string),
            let userName = ProcessInfo.processInfo.environment["DATABASE_USER"],
            let database = ProcessInfo.processInfo.environment["DATABASE_DB"],
            let password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] else {
            throw QueryError.connection("Database informations are not complete to connect to database or are not pass as environnement variable")
        }

        self.host = host
        self.port = port
        self.databaseName = database
        self.userName = userName
        self.password = password
        
        /*  This configuration is classic but offers a powerful pool and good performances. 
            PostgreSQL max connections = 100 
            you should avoid the use of large pool and prefer set a timeout a bit longer. 
            Keeping a good ratio between timeout and maxCapacity to reach the best concurrency possible. */
        pool = PostgreSQLConnection.createPool(host: self.host, port: self.port, options: [.userName(self.userName),.password(self.password),.databaseName(self.databaseName)], poolOptions:  ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 10, timeout: 30000))
    }

    func preparation() throws {        
        try Product.prepare(pool: self.pool)
        try Store.prepare(pool:self.pool)
        try Stock.prepare(pool:self.pool)
    }
    
    func drop(completionHandler:(@escaping (Error?) -> ())){
        guard let connection = pool.getConnection() else {
            completionHandler(ErrorHandler.DBPoolEmpty)
            return
        }
        
        connection.startTransaction(){ result in
            Stock().drop().execute(connection){ result in
                guard result.success else {
                    let error = result.asError
                    connection.rollback(){ result in
                        guard result.success else {
                            completionHandler(result.asError)
                            return
                        }
                        completionHandler(error)
                    }
                    return
                }
                Product().drop().execute(connection){ result in
                    guard result.success else {
                        let error = result.asError
                        connection.rollback(){ result in
                            guard result.success else {
                                completionHandler(result.asError)
                                return
                            }
                            completionHandler(error)
                        }
                        return
                    }
                    Store().drop().execute(connection){ result in
                        guard result.success else {
                            let error = result.asError
                            connection.rollback(){ result in
                                guard result.success else {
                                    completionHandler(result.asError)
                                    return
                                }
                                completionHandler(error)
                            }
                            return
                        }
                        connection.commit(){ result in
                            guard result.success else {
                                completionHandler(result.asError)
                                return
                            }
                            completionHandler(nil)
                        }
                    }
                }
            }
        }
    }
}
