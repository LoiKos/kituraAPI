//
//  StockRouter.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 14/04/2017.
//
//


import Foundation
import Kitura
import SwiftKuery
import LoggerAPI
import SwiftyJSON


public class StockRouter {
    
    let service : StockService
    
    public let router: Router
    
    init(database: Database){
        service = StockService(database: database)
        router = Router(mergeParameters: true)
        setupRoutes()
    }
    
    private func setupRoutes(){
        router.patch("/:productId", handler: updateStoreProductById)
        router.delete("/:productId", handler: deleteStoreProductById)
        router.get("/", handler: getStoreProducts)
        router.post("/", handler: createStoreProduct)
        router.error(handleError)
    }
    
    private func updateStoreProductById(request:RouterRequest, response: RouterResponse, next : @escaping () -> Void ) throws {
        guard let store = request.parameters["storeId"],
            let product = request.parameters["productId"] else {
                throw ErrorHandler.badRequest
        }
        
        guard let parsedBody = request.body else {
            throw ErrorHandler.EmptyBody
        }
        
        switch parsedBody {
            case .json(let jsonBody):
                service.updateProductInStock(storeId: store, productId: product, body: jsonBody){ result, error in
                    handleCompletion(result: result, error: error, response: response, next: next)
            }
            default:
                throw ErrorHandler.UnexpectedDataStructure
        }
    }
    
    private func deleteStoreProductById(request:RouterRequest, response: RouterResponse, next : @escaping () -> Void ) throws {
        
        guard let store = request.parameters["storeId"],
              let product = request.parameters["productId"] else {
            throw ErrorHandler.badRequest
        }
        
        service.deleteProductInStock(storeId: store, productId: product){result, error in
            handleCompletion(result: result, error: error, response: response, next: next)
        }
    }
    
    private func getStoreProducts(request:RouterRequest, response: RouterResponse, next : @escaping () -> Void ) throws {
        
        guard let store = request.parameters["storeId"] else {
            throw ErrorHandler.badRequest
        }
        
        var limit:Int = 0
        var offset:Int = 0
        
        if let paramOffset = request.queryParameters["offset"] {
            offset = Int(paramOffset) ?? 0
        }
        if let paramLimit = request.queryParameters["limit"] {
            limit = Int(paramLimit) ?? 0
        }
        
        service.getProductInStock(limit:limit, offset:offset, storeId: store){ result, error in
            handleCompletion(result: result, error: error, response: response, next: next)
        }
    }
    
    private func createStoreProduct(request:RouterRequest, response: RouterResponse, next : @escaping () -> Void ) throws {
        
        guard let store = request.parameters["storeId"] else {
            throw ErrorHandler.badRequest
        }
        
        guard let parsedBody = request.body else {
            throw ErrorHandler.EmptyBody
        }
        
        switch parsedBody {
            case .json(let jsonBody):
                service.createProductInStock(storeId: store, requestBody: jsonBody) { result, error in
                    response.status(.created)
                    handleCompletion(result: result, error: error, response: response, next: next)
            }
            default:
                throw ErrorHandler.UnexpectedDataStructure
        }
    }    
}
