import Api
import HeliumLogger
import Kitura

// First set Logger to
let logger = HeliumLogger(.debug)
logger.colored = true
Log.logger = logger

let center : RoutingCenter = try RoutingCenter()

// Server preparations
let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

let server = Kitura.addHTTPServer(onPort:port, with: center.setup())

// Run the server
Kitura.run()
