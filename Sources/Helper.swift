//
//  helper.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 03/04/2017.
//
//

import Foundation

/**
 Generate a reference to register for example products. the reference is created from a set of 36 characters and contains at least 15 characters.
 - Author: Loic LE PENN
 - returns : return the reference as a String
 - parameters:
    - prefix : if you need to a custom prefix to the reference
    - suffix : This is useful in some case to add suffix to reference
 - Version: 1.0
 */
func generateRef(prefix:String = "",suffix:String = "") -> String {
    let charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var c = charSet.characters.map{ String($0) }
    var reference = prefix
    for n in 0...14 {
        reference.append(c[Int(arc4random_uniform(UInt32(c.count)))])
    }
    reference.append(suffix)
    return reference
}
