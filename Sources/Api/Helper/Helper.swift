//
//  helper.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 03/04/2017.
//
//

import Foundation
import Kitura
import SwiftKuery
import SwiftyJSON
import LoggerAPI

#if os(Linux)
  import Glibc
#endif

extension ResultSet {
    /**
        Retrieve a single row from a Query result (Swift-Kuery) ResultSet
     */
    func singleRow() throws -> Dictionary<String,Any> {
        var mainRow:Dictionary<String,Any> = Dictionary<String,Any>()
        
        for item in self.rows {
            if !mainRow.isEmpty { throw ErrorHandler.UnexpectedDataStructure }
            mainRow = Dictionary<String,Any>()
            for (index,value) in item.enumerated() {
                mainRow[self.titles[index]] = value ?? ""
            }
        }
        
        if mainRow.isEmpty {throw ErrorHandler.NothingFound }
        return mainRow
    }
    
    /**
     
     */
    func asDictionaries() -> [ Dictionary<String,Any> ] {
        return self.rows.map { row in
            var object = Dictionary<String,Any>()
            
            for (index,value) in row.enumerated() {
                object[self.titles[index]] = value ?? ""
            }
            
            return object
        }
    }
}


func handleCompletion(result: Dictionary<String,Any>?, error:Error?, response: RouterResponse, next: @escaping () -> Void){
    
    guard error == nil else {
        Log.error("\(error.debugDescription)")
        response.error = error
        next()
        return
    }
    
    guard let responseBody = result  else {
        Log.error("Impossible to retrieve results")
        response.error = ErrorHandler.UnknowError
        next()
        return
    }
    
    do{
        try response.send(json: JSON.parse(string: try responseBody.toJSON())).end()
    } catch {
        print("Impossible to send response : \(error)")
        Log.error("Impossible to send response : \(error)")
    }
}
