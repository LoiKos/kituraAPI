/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Kitura
import KituraNet
@testable import Api
import Foundation
import Dispatch

class KituraTest: XCTestCase {
    
    static let httpPort = 8090
    
    static private(set) var httpServer: HTTPServer?
    
    private(set) var port = -1
    
    private static let initOnce: () = {
        PrintLogger.use(colored: true)
    }()
    
    override func setUp() {
        super.setUp()
        KituraTest.initOnce
    }
    
    func performServerTest(_ router: ServerDelegate, timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: @escaping (XCTestExpectation) -> Void...) {
            self.port = KituraTest.httpPort
            doPerformServerTest(router: router, timeout: timeout, line: line, asyncTasks: asyncTasks)
    }
    
    func doPerformServerTest(router: ServerDelegate, timeout: TimeInterval, line: Int, asyncTasks: [(XCTestExpectation) -> Void]) {
        
        guard startServer(router: router) else {
            XCTFail("Error starting server on port \(port)")
            return
        }
        
        let requestQueue = DispatchQueue(label: "Request queue")
        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(line: line, index: index)
            requestQueue.async {
                asyncTask(expectation)
            }
        }
        
        // wait for timeout or for all created expectations to be fulfilled
        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }
    
    private func startServer(router: ServerDelegate) -> Bool {
        if let server = KituraTest.httpServer {
            server.delegate = router
            return true
        }
        
        let server = HTTP.createServer()
        server.delegate = router
        do {
            try server.listen(on: port)
            KituraTest.httpServer = server
            return true
        } catch {
            XCTFail("Error starting server: \(error)")
            return false
        }
    }
    
    func stopServer() {
        KituraTest.httpServer?.stop()
        KituraTest.httpServer = nil
    }
    
    func performRequest(_ method: String, path: String,
                        callback: @escaping ClientRequest.Callback, headers: [String: String]? = nil,
                        requestModifier: ((ClientRequest) -> Void)? = nil) {
        
        let port = Int16(self.port)
        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }
        
        let schema = "http"
        var options: [ClientRequest.Options] =
            [.method(method), .schema(schema), .hostname("127.0.0.1"), .port(port), .path(path),
             .headers(allHeaders)]
        
        let req = HTTP.request(options, callback: callback)
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end(close: true)
    }
    
    func expectation(line: Int, index: Int) -> XCTestExpectation {
        return self.expectation(description: "\(type(of: self)):\(line)[\(index)]")
    }
}
