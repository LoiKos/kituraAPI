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



struct Database {
    
    private var host : String = "127.0.0.1"
    private var port : Int32 = 5432
    private var databaseName : String = "postgres"
    private var userName : String = "postgres"
    private var password : String = ""
    
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
        
        pool = PostgreSQLConnection.createPool(host: host, port: port, options: [.userName(userName),.password(password),.databaseName(database)], poolOptions:  ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50, timeout: 10000))
    }
    
    func preparation() throws {
        try Store.prepare(pool:self.pool)
        try Product.prepare(pool:self.pool)
        try Stock.prepare(pool:self.pool)
    }
}



