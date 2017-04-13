import Kitura
import HeliumLogger
import LoggerAPI
import SwiftKuery
import SwiftKueryPostgreSQL
import Foundation

// First set Logger to
let logger = HeliumLogger(.debug)
logger.colored = true
Log.logger = logger

// connect to database
let db = try Database.environmentDatabase()

//Store.prepare(connection: db.connection)
//Product.prepare(connection: db.connection)
//Stock.prepare(connection: db.connection)

let router = routingCenter(database: db)

// Server preparations
let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

let server = Kitura.addHTTPServer(onPort:port, with: router)

// Run the server
Kitura.run()

