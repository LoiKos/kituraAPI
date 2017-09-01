//
//  StoreRouterTests.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 22/08/2017.
//
//  Need to be connected to database

import XCTest
@testable import Api
import Kitura
import KituraNet
import SwiftyJSON

class StoreRouterTests : KituraTest {

    func testPostHello() {
        guard let router = try? RoutingCenter().setup() else {
            XCTFail("Impossible to init Routing center")
            return
        }
        
        let jsonToTest = JSON(["name": "Nike"])
        
        self.performServerTest(router) { expectation in
            self.performRequest("post", path: "/api/v1/stores", callback: { response in
                guard let response = response else {
                    XCTFail("ClientRequest response object was nil")
                    expectation.fulfill()
                    return
                }
                expectation.fulfill()
            }, headers: ["Content-Type":"application/json"]) { req in
                do {
                    let jsonData = try jsonToTest.rawData()
                    req.write(from: jsonData)
                    req.write(from: "\n")
                } catch {
                    XCTFail("caught error \(error)")
                }
            }
        }
    }
}
