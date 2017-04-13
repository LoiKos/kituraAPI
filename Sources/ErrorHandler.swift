//
//  ErrorHandler.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 12/04/2017.
//
//

import Foundation
import SwiftyJSON
import Kitura
import LoggerAPI

/**
 
 Enum to handle API error
 
 - Author: Loic LE PENN
 
 - Version: 1.0
 */

enum ErrorHandler : Error, CustomStringConvertible {
    
    case WrongType
    case EmptyBody
    case MissingRequireProperty(String)
    case UnknowError
    case WrongParameter
    case NothingToUpdate
    case DatabaseError(String)
    case ParsingResponse
    case NothingFoundFor(String)
    case UnexpectedDataStructure
    
    var description: String {
        switch self {
        case .WrongType:
            return "Body need to be in JSON. Check that header contains Content-type: application/json"
            
        case .EmptyBody:
            return "Empty body are not accepted. If your body isn't empty it mean that he is malformed and can't be parsed"
            
        case .WrongParameter:
            return "one or more parameters are not set correctly"
            
        case .MissingRequireProperty(let property):
            return "Missing require Property \(property)"
            
        case .NothingToUpdate:
            return "Nothing to update. Check your parameters names. They should match the column name"
            
        case .UnknowError:
            return "Unknown Error"
            
        case .DatabaseError(let error):
            return "Database error: \(error)"
            
        case .ParsingResponse:
            return "Impossible to parse database response"
            
        case .NothingFoundFor(let str):
            return "No object matched \(str)"
        
        case .UnexpectedDataStructure:
            return "Unknown Data Structure"
        }
    }
    
    func toJSON() -> JSON {
        return JSON(["error":self.description])
    }
    
}



/**
    
 Generic function to handle error on subRouter level.
 Use it with Router.error as a router handler
    - parameters:
        - request: a Kitura RouterRequest
        - response: a Kitura RouterResponse
        - next: go to the next middleware
    - Author: Loic LE PENN
    - Version: 1.0
 
 */
public func handleError(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void){
    let errorDescription : JSON
    
    if let error = (response.error) as? ErrorHandler {
        errorDescription = error.toJSON()
        switch error {
        case .EmptyBody,.MissingRequireProperty,.WrongType,.WrongParameter,.NothingToUpdate:
            response.status(.badRequest)
        case .NothingFoundFor:
            response.status(.notFound)
        default:
            response.status(.internalServerError)
        }
    } else {
        errorDescription = ErrorHandler.UnknowError.toJSON()
        response.status(.internalServerError)
    }
    
    do {
        Log.error("Error in STORE ROUTER : \(errorDescription["error"].stringValue)")
        try response.send(json:errorDescription).end()
    } catch {
        Log.error("[ERROR HANDLER FAILURE] : \(error)")
    }
}
