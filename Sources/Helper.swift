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
import SwiftyJSON

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
        reference.append(c[Int(arc4random_uniform(UInt32(c.count)))])
    }
    reference.append(suffix)
    return reference
}



/**
 
 Enum to handle api error
 
 - Author: Loic LE PENN

 - Version: 1.0
 */

enum ErrorHandler : Error, CustomStringConvertible {
    
    case WrongType()
    case EmptyBody()
    case MissingRequireProperty(String)
    case UnknowError()
    case DatabaseError(String)
    
    var description: String {
        switch self {
        case .WrongType:
            return "Body need to be in JSON. Check that header contains Content-type: application/json"
        case .EmptyBody:
            return "Empty body are not accepted"
        case .MissingRequireProperty(let property):
            return "Missing require Property \(property)"
        case .UnknowError:
            return "Unknown Error"
        case .DatabaseError(let error):
            return "Database error: \(error)"
        }
    }
    
    func toJSON() -> JSON {
        return JSON(["error":self.description])
    }
    
}
