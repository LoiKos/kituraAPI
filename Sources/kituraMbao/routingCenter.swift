//
//  routingCenter.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import SwiftyJSON
import SwiftKuery
import LoggerAPI

func routingCenter(database: Database) -> Router {

    let router = Router()

    router.all("*", middleware: BodyParser()) // Parse incoming request body

    router.get("/"){ request, response,_ in
        try response.send(status: .notFound).end()
    }

    let stockRouter = StockRouter(database: database).router
    router.all("/api/v1/stores/:storeId/products", middleware: stockRouter)

    let storeRouter = StoreRouter(database: database).router
    router.all("/api/v1/stores", middleware: storeRouter)

    let productRouter = ProductRouter(database: database).router
    router.all("/api/v1/products", middleware: productRouter)

    return router
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
        Log.error("Impossible to send response : \(error)")
    }
}
