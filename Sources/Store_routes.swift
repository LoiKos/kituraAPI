//
//  Store_routes.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import SwiftKuery
import SwiftKueryPostgreSQL
import LoggerAPI
import SwiftyJSON

func storeRoutes(connection:PostgreSQLConnection) -> RouterMiddleware {
    
    let router = Router()
    
    let service = StoreService(connection: connection)
    
    router.route("/")
        
         .get(){ request, response, next in
            Log.info("Trying recover query paramers offset and limit")
            if let offset = request.queryParameters["offset"],
               let limit = request.queryParameters["limit"]{
                
            } else {
            
            }
        }
        
         .post(){ request, response, next in
            Log.info("Trying recover body")
            guard let parsedBody = request.body else {
                throw ErrorHandler.EmptyBody()
            }
            Log.info("Check Body")
            switch parsedBody {
                case .json(let jsonBody):
                    Log.info("Try to store the object in database")
                    try service.create(json: jsonBody){ id, err in
                        if let error = err {
                            throw ErrorHandler.DatabaseError("\(error)")
                        }
                        if let storeId = id {
                            Log.info("Object Create with success !")
                            try response.send(json:JSON(["id":"\(storeId)"])).end()
                            return
                        }
                        throw ErrorHandler.UnknowError()
                    }
                default:
                    throw ErrorHandler.WrongType()
            }
            next()
        }
    
    
    
    router.error{ request, response, next in
        response.headers["Content-Type"] = "application/json"
       
        let errorDescription : JSON
        
        if let error = (response.error) as? ErrorHandler {
            errorDescription = error.toJSON()
            switch error {
                case .EmptyBody,.MissingRequireProperty,.WrongType:
                    response.status(.badRequest)
                default:
                    break
            }
        } else {
            errorDescription = ErrorHandler.UnknowError().toJSON()
            response.status(.internalServerError)
        }
        Log.error(errorDescription["error"].stringValue)
        try response.send(json:errorDescription).end()
    }
    
    return router
}

