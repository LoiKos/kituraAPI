//
//  helper.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 03/04/2017.
//
//

import Foundation
import LoggerAPI
import HeliumLogger
import SwiftKuery

/**
 
 Generate a reference to register for example products. the reference is created from a set of 36 characters and contains at least 15 characters.
 
 - Author: Loic LE PENN
 
 - returns : return the reference as a String
 
 - parameters:
    - prefix : if you need to a custom prefix to the reference
    - suffix : This is useful in some case to add suffix to reference
 
 - Version: 1.0
 */
func generateRef(prefix:String = "", suffix:String = "") -> String {
    let charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var c = charSet.characters.map{ String($0) }
    var reference = prefix
    for _ in 0...14 {
        reference.append(c[Int(arc4random_uniform(UInt32(c.count)))])
    }
    reference.append(suffix)
    return reference
}

/**
 
 Generate a reference to register for example products. the reference is created from a set of 36 characters and contains at least 15 characters.
 
 - Author: Loic LE PENN
 
 - returns : return the reference as a String
 
 - parameters:
    - size : size of the generated references
    - prefix : if you need to a custom prefix to the reference
    - suffix : This is useful in some case to add suffix to reference
 
 - Version: 1.0
 */
func generateRef(size:Int, prefix:String = "", suffix:String = "") -> String {
    let charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var c = charSet.characters.map{ String($0) }
    var reference = prefix
    for _ in 0...(size - 1) {
        #if os(Linux)
            srandom(UInt32(time(nil)))
            reference.append(c[Int(UInt32(random() % c.count))])
        #else
            reference.append(c[Int(arc4random_uniform(UInt32(c.count)))])
        #endif
    }
    reference.append(suffix)
    return reference
}






extension ResultSet {
    
    func uniqueSingleRow() throws -> [String:Any?]? {
        var mainRow:[String:Any?]? = nil
        for item in self.rows {
            if mainRow == nil {
                mainRow = [String:Any?]()
                for (index,value) in item.enumerated() {
                    mainRow?[self.titles[index]] = value ?? nil
                }
            } else {
                throw ErrorHandler.UnexpectedDataStructure
            }
        }
        return mainRow
    }

    func asDictionaries() -> [[String:Any?]] {
        return self.rows.map { row in
            var object = [String:Any?]()
            
            for (index,value) in row.enumerated() {
                object[self.titles[index]] = value ?? nil
            }
            return object
        }
    }
}
