//
//  File.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 13/04/2017.
//
//

import Foundation
import Kitura
import SwiftKuery
import LoggerAPI
import SwiftyJSON

public class ProductRouter {
    
    let service : ProductService
    
    public let router: Router
    
    init(pool:ConnectionPool) {
        service = ProductService(pool:pool)
        router = Router()
        setupRoutes()
    }

    private func setupRoutes(){
        router.get( "/:id", handler : getProductById )
        router.patch( "/:id", handler : updateProductById )
        router.delete( "/:id", handler : deleteProductById )
        router.get( "/", handler : getProducts )
        router.post( "/", handler : createProduct )
        router.error(handleError)
    }
    
    
    private func getProductById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let id = request.parameters["id"] {
            try service.findById(id: id) { result, error in
                response.status(.OK)
                handleCompletion(result: result, error: error, response: response, next: next)
            }
        } else {
            throw ErrorHandler.MissingRequireProperty("id")
        }
    }
    
    private func updateProductById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let id = request.parameters["id"] {
            guard let parsedBody = request.body else {
                throw ErrorHandler.EmptyBody
            }
            
            switch parsedBody {
                case .json(let jsonBody):
                    try service.updateById(id: id, jsonBody: jsonBody) { result, error in
                        response.status(.OK)
                        handleCompletion(result:result, error: error,response: response,next: next)
                    }
                default:
                    throw ErrorHandler.WrongType
            }
        } else {
            throw ErrorHandler.MissingRequireProperty("id")
        }
    }
    
    private func deleteProductById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let id = request.parameters["id"] {
            try service.deleteById(id: id) { result, error in
                response.status(.OK)
                handleCompletion(result: result, error: error, response: response, next: next)
            }
        } else {
            throw ErrorHandler.MissingRequireProperty("id")
        }
    }
    
    private func getProducts(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.info("Trying recover query paramers offset and limit")
        
        var limit:Int = 0
        var offset:Int = 0
        
        if let paramOffset = request.queryParameters["offset"] {
            offset = Int(paramOffset) ?? 0
        }
        if let paramLimit = request.queryParameters["limit"] {
            limit = Int(paramLimit) ?? 0
        }
        
        try service.findAll(limit: limit, offset: offset) { result, error in
            response.status(.OK)
            handleCompletion(result: result, error: error, response: response, next: next)
        }
    }
    
    private func createProduct(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        
        guard let parsedBody = request.body else {
            throw ErrorHandler.EmptyBody
        }
        
        switch parsedBody {
            case .json(let jsonBody):
                try service.create(body: jsonBody) { result, error in
                    response.status(.created)
                    handleCompletion(result: result, error: error, response: response, next: next)
                }
            default:
                throw ErrorHandler.WrongType
        }
    }
}
