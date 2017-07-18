//
//  JSONTests.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 04/07/2017.
//
//

import XCTest
@testable import Api

class JSONTests: XCTestCase {

    func testString() {
        let test = "Hello"
        XCTAssert(test.toJSON() == "\"Hello\"")
    }
    
    func testDate() {
        let test = Date()
        XCTAssert(test.toJSON() == "\"\(test.description)\"")
    }
    
    func testInt() {
        let test = 10
        XCTAssert(test.toJSON() == "10")
    }
    
    func testInt8(){
        let test = Int8(exactly: 10)
        XCTAssertNotNil(test)
        XCTAssert(test?.toJSON() == "10")
    }
    func testInt16(){
        let test = Int16(exactly: 10)
        XCTAssertNotNil(test)
        XCTAssert(test?.toJSON() == "10")
    }
    func testInt32(){
        let test = Int32(exactly: 10)
        XCTAssertNotNil(test)
        XCTAssert(test?.toJSON() == "10")
    }
    func testInt64(){
        let test = Int64(exactly: 10)
        XCTAssertNotNil(test)
        XCTAssert(test?.toJSON() == "10")
    }
    
    func testFloat32(){
        let float = Float32(floatLiteral: 10.99)
        XCTAssertNotNil(float)
        XCTAssert(float.toJSON() == "10.99")
    }
    func testFloat64(){
        let float = Float64(floatLiteral: 10.99)
        XCTAssertNotNil(float)
        XCTAssert(float.toJSON() == "10.99")
    }
    func testFloat80(){
        let float = Float80(floatLiteral: 10.99)
        XCTAssertNotNil(float)
        XCTAssert(float.toJSON() == "10.99")
    }
    
    func testArray(){
        let date = Date()
        let array : [Any] = ["toto",10,10.99,date]
        XCTAssertNoThrow(XCTAssert(try array.toJSON() == "[\"toto\", 10, 10.99, \"\(date.description)\"]"))
    }
    func testArrayFailed(){
        var array : [Any] = [(String,Date)]()
        array.append(("toto",Date()))
        XCTAssertThrowsError(try array.toJSON()){ error in
            XCTAssert(error is JSONSerializableError)
            XCTAssert(error as? JSONSerializableError == JSONSerializableError.typeUnSerializable)
        }
    }
    
    func testDictionnary(){
        let date = Date()
        let dict = ["string":"toto","number":10,"float":10.0,"date":date,"array":["test"]] as [String : Any]
        XCTAssertNoThrow(try dict.toJSON())
    }
    func testDictionnaryFailed(){}
}
