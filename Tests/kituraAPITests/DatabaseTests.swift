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
    
    func testRemove(){
        let expect = expectation(description: "should drop table")
        
        XCTAssertNoThrow(try Database().drop(){ error in
            XCTAssertNil(error, "There is an error: \(error)")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10){ error in
            XCTAssertNil(error, "Test failed. \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testRemoveNoConnection(){
        let expect = expectation(description: "should failed")
        
        XCTAssertNoThrow(try Database().preparation())
        
        XCT
            try Database().drop(){ error in
            XCTAssertNil(error, "There is an error: \(error)")
            expect.fulfill()
            })
        
        waitForExpectations(timeout: 10){ error in
            XCTAssertNil(error, "Test failed. \(String(describing: error?.localizedDescription))")
        }

    }

    func testPerformanceExample() {
        self.measure {
            do {
                try Database().preparation()
            } catch {
                print("error during preparations test ")
            }
        }
        testRemove()
    }
}
