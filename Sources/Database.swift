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
    private var port : Int = 5432
    private var databaseName : String = "postgres"
    private var userName : String = "postgres"
    private var password : String = ""
    public var connection:PostgreSQLConnection
    
    init(host : String = "127.0.0.1",port : Int = 5432,databaseName : String = "postgres",userName : String = "postgres",password : String = ""){
        self.host = host
        self.port = port
        self.databaseName = databaseName
        self.userName = userName
        self.password = password
        
        /// Map config to match SwiftKuery model
        var options = [ConnectionOptions]()
        options.append(.databaseName(self.databaseName))
        options.append(.password(self.password))
        options.append(.userName(self.userName))
        connection = PostgreSQLConnection(host: self.host, port: Int32(self.port) , options: options)
    }
    
    /**
     Static function that give you a database instance with connection based on your environnement variables.
    
     - Authors: Loic LE PENN
     
     - Important: This function required to have
        DATABASE_HOST,
        DATABASE_PORT,
        DATABASE_USERNAME,
        DATABASE_DB 
        and DATABASE_PASSWORD environnement variables set or it will throw
     
     - throws: QueryError.connection
     
     - important: This is static method so you should use it on Database type and not instance.
     
     - Version: 1.0
     */
    static func environmentDatabase() throws -> Database {
        if let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
            let port_string = ProcessInfo.processInfo.environment["DATABASE_PORT"],
            let port = Int(port_string),
            let userName = ProcessInfo.processInfo.environment["DATABASE_USERNAME"],
            let database = ProcessInfo.processInfo.environment["DATABASE_DB"],
            let password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"]
        {
            return Database(host: host, port: port, databaseName: database, userName: userName, password: password)
        } else {
            throw QueryError.connection("Database informations are not complete to connect to database or are not pass as environnement variable")
        }
    }
}



