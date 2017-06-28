import Kitura
import HeliumLogger
import LoggerAPI
import Foundation

// First set Logger to
let logger = HeliumLogger(.debug)
logger.colored = true
Log.logger = logger

// grant access to connection pool all over the API
let pool = try Database().pool

try Store.prepare()
try Product.prepare()
try Stock.prepare()

let router = routingCenter()

// Server preparations
let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

let server = Kitura.addHTTPServer(onPort:port, with: router)

// Run the server
Kitura.run()

