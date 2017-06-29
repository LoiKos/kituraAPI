//
//  routingCenter.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

@_exported import Foundation
@_exported import Kitura
@_exported import SwiftyJSON
@_exported import SwiftKuery
@_exported import LoggerAPI

public class RoutingCenter {
    
    private let pool : ConnectionPool
    private let router : Router
    
    public init() throws {
        let database = try Database()
        try database.preparation()
        self.pool = database.pool
        self.router = Router()
    }
    
    public func setup() -> Router {
        router.all("*", middleware: BodyParser()) // Parse incoming request body
        
        router.get("/"){ request, response,_ in
            try response.send(status: .notFound).end()
        }
        
        let stockRouter = StockRouter(pool:pool).router
        router.all("/api/v1/stores/:storeId/products", middleware: stockRouter)
        
        let storeRouter = StoreRouter(pool:pool).router
        router.all("/api/v1/stores", middleware: storeRouter)
        
        let productRouter = ProductRouter(pool:pool).router
        router.all("/api/v1/products", middleware: productRouter)
        
        return router
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
        Log.error("Impossible to send response : \(error)")
    }
}
