//
//  routingCenter.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import SwiftKuery

final public class RoutingCenter {
    
    private let pool : ConnectionPool
    private let router : Router
    
    public init() throws {
        let database = try Database()
        self.pool = database.pool
        try database.preparation()
        self.router = Router()
    }
    
    public func setup() -> Router {
        router.all("*", middleware: BodyParser()) // Parse incoming request body
        
        router.get("/"){ request, response,_ in
            try response.send(status: .notFound).end()
        }
        
        let stockService = StockService(pool: pool)
        let stockRouter = StockRouter(stockService).router
        router.all("/api/v1/stores/:storeId/products", middleware: stockRouter)
        
        let storeService = StoreService(pool: pool)
        let storeRouter = StoreRouter(storeService).router
        router.all("/api/v1/stores", middleware: storeRouter)
        
        let productService = ProductService(pool: pool)
        let productRouter = ProductRouter(productService).router
        router.all("/api/v1/products", middleware: productRouter)
        
        return router
    }
}
