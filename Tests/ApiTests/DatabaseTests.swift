//
//  DatabaseTests.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 28/07/2017.
//
//

import XCTest
@testable import Api
import SwiftKueryPostgreSQL

class DatabaseTests: XCTestCase {

    func testConnectivity() {
        XCTAssertNoThrow(try Database().pool.getConnection())
    }

    func testPreparations(){
        XCTAssertNoThrow(try Database().preparation())
    }

    func testRemoveNoConnection(){
        let expect = expectation(description: "should drop table")
        let db : Database

        do {
           db = try Database()

           XCTAssertNoThrow(try db.preparation())

           db.pool.disconnect()

            XCTAssertNoThrow(db.drop(completionHandler: { (error) in
                XCTAssertNotNil(error)
                if let error = error {
                    XCTAssert(error is ErrorHandler)
                    XCTAssert((error as! ErrorHandler).description == ErrorHandler.DBPoolEmpty.description)

                    expect.fulfill()
                }
            }))
        } catch {

        }

        waitForExpectations(timeout: 10){ error in
            XCTAssertNil(error, "Test failed. \(String(describing: error?.localizedDescription))")
        }
    }

    func testRemoveStockAlreadyDrop(){
        let expect = expectation(description: "shouldn't be able to drop because stock table is already removed")

        guard let db = try? Database(),((try? db.preparation()) != nil) else {
            XCTFail(" failed to instanciate db")
            return
        }


        guard let connection = db.pool.getConnection()else {
            XCTFail(" failed to get db connection")
            return
        }

        Stock().drop().execute(connection){ result in
                XCTAssert(result.success)
                db.drop(){ error in
                   XCTAssertNotNil(error)
                   XCTAssert(String.init(describing: error!) == "Query execution error:\nERROR:  table \"stock\" does not exist\n For query: DROP TABLE stock")
                   expect.fulfill()
                }
            }

        waitForExpectations(timeout: 10){ error in
            XCTAssertNil(error, "Test failed. \(String(describing: error?.localizedDescription))")
        }
    }

    func testRemove(){
        guard ((try? Database().preparation()) != nil) else {
            XCTFail("can't prepare database")
            return
        }

        let expect = expectation(description: "should drop table")

        XCTAssertNoThrow(try Database().drop(){ error in
            XCTAssertNil(error, "There is an error: \(String(describing: error))")
            expect.fulfill()
            })

        waitForExpectations(timeout: 10){ error in
            XCTAssertNil(error, "Test failed. \(String(describing: error?.localizedDescription))")
        }
    }

    func testPerformancePreparation() {
        self.measure {
            guard let _ = try? Database().preparation() else {
                XCTFail("error during preparations test ")
                return
            }
        }
        testRemove()
    }

    static var allTests : [(String, (DatabaseTests) -> () throws -> Void)] {
        return [
            ("testConnectivity", testConnectivity),
            ("testPreparations", testPreparations),
            ("testRemoveNoConnection", testRemoveNoConnection),
            ("testRemoveStockAlreadyDrop", testRemoveStockAlreadyDrop),
            ("testRemove", testRemove),
            ("testPerformancePreparation", testPerformancePreparation)
        ]
    }

}
