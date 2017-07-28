//
//  ReferenceTests.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 03/07/2017.
//
//

import XCTest
@testable import Api

class ReferenceTests: XCTestCase {

    internal let charSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

    func testSimpleReference() {
        let reference = Reference.sharedInstance
        var genRef = reference.generateRef()
        
        XCTAssert(genRef.characters.count == 15)
        XCTAssert(genRef.trimmingCharacters(in: self.charSet) == "")
    }
    
    func testCustomReference(){
        var genRef = try? Reference.sharedInstance.generateRef(size: 11)
        XCTAssertNotNil(genRef)
        if let ref = genRef {
            XCTAssert(ref.characters.count == 11)
            XCTAssert(ref.trimmingCharacters(in: self.charSet) == "")
        }
        
        genRef = try? Reference.sharedInstance.generateRef(size: 20)
        XCTAssertNotNil(genRef)
        if let ref = genRef {
            XCTAssert(ref.characters.count == 20)
            XCTAssert(ref.trimmingCharacters(in: self.charSet) == "")
        }
        
    }
    
    func testCustomReferenceFailed(){
        XCTAssertThrowsError(try Reference.sharedInstance.generateRef(size: 9)){ error in
            XCTAssert(error is ReferenceError)
            XCTAssert(error as! ReferenceError == ReferenceError.wrongSize)
        }
    }
    
    func testPrefix(){
        let reference = Reference.sharedInstance
        let prefix = "FR_"
        let genRef = reference.prefix(prefix).generateRef()
        let genRef2 = reference.generateRef()
        XCTAssert(genRef.contains(prefix))
        XCTAssertFalse(genRef2.contains(prefix))
    }
    
    func testSuffix(){
        let reference = Reference.sharedInstance
        let suffix = "_FR"
        let genRef = reference.suffix(suffix).generateRef()
        let genRef2 = reference.generateRef()
        XCTAssert(genRef.contains(suffix))
        XCTAssertFalse(genRef2.contains(suffix))
    }
    
    
    func testSimpleRefPerformance() {
        self.measure {
            for _ in 0...1000 {
                _ = Reference.sharedInstance.generateRef()
            }
        }
    }
    
    func testCustomRefPerformance() {
        self.measure {
            for _ in 0...1000 {
                do {
                   _ = try Reference.sharedInstance.generateRef(size: 30)
                } catch {
                    exit(0)
                }
            }
        }
    }
    
    func testSuffixPerformanceSimple() {
        self.measure {
            for _ in 0...1000 {
                _ = Reference.sharedInstance.suffix("_FR").generateRef()
            }
        }
    }
    
    func testPrefixPerformanceSimple() {
        self.measure {
            for _ in 0...1000 {
                _ = Reference.sharedInstance.prefix("FR_").generateRef()
            }
        }
    }
    
    static var allTests : [(String, (ReferenceTests) -> () throws -> Void)] {
        return [
            ("testSimpleReference", testSimpleReference),
            ("testCustomReference", testCustomReference),
            ("testCustomReferenceFailed", testCustomReferenceFailed),
            ("testPrefix", testPrefix),
            ("testSuffix", testSuffix)
        ]
    }

}
