import Kitura
import HeliumLogger
import LoggerAPI
import SwiftKuery
import SwiftKueryPostgreSQL
import Foundation

let logger = HeliumLogger(.debug)
logger.colored = true
Log.logger = logger

let router = Router()

let db_config : DatabaseConfig

if let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
   let port_string = ProcessInfo.processInfo.environment["DATABASE_PORT"],
   let port = Int(port_string),
   let userName = ProcessInfo.processInfo.environment["DATABASE_USERNAME"],
   let database = ProcessInfo.processInfo.environment["DATABASE_DB"],
   let password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"]
    {
        db_config = DatabaseConfig(host: host, port: port, databaseName: database, userName: userName, password: password)
    }
else{
    Log.error("Database information are not complete to connect to database")
    throw QueryError.connection("Database information are not complete to connect to database")
}

let db_connect = db_config.connection()

Store.prepare(connection: db_connect)
Product.prepare(connection: db_connect)


let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

Kitura.addHTTPServer(onPort:port, with: router)

Kitura.run()
