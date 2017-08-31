//
//  Service.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 31/08/2017.
//
//

import Foundation
import SwiftyJSON

protocol Service {
    
    func all(limit:Int, offset:Int, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws
    
    func create(body:JSON, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws
    
    func update(id: String, jsonBody: JSON, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func getOne(id:String, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func delete(id:String, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
}

protocol Pivot {
    
    func all(limit:Int, offset:Int, storeId: String, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func create(storeId: String, requestBody: JSON, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func update(storeId: String, productId: String, body: JSON, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func getOne(storeId: String, productId: String, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws
    
    func delete(storeId: String, productId: String, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws

}
