import Api
import HeliumLogger
import Kitura
import Foundation
import LoggerAPI

let logger = HeliumLogger(.warning)
logger.colored = true
Log.logger = logger

let Rcenter = try RoutingCenter()

// Server preparations
let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

let server = Kitura.addHTTPServer(onPort:port, with: Rcenter.setup())

// Run the server
Kitura.run()
