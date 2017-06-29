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
import LoggerAPI
import SwiftyJSON



public class StoreRouter {

    let service : StoreService

    public let router: Router

    init(pool:ConnectionPool)  {
        service = StoreService(pool:pool)
        router = Router()
        setupRoutes()
    }

    private func setupRoutes(){
        router.get("/:id", handler : getStoreById )
        router.patch("/:id", handler : updateStoreById )
        router.delete("/:id", handler : deleteStoreById )
        router.get("/", handler : getStores)
        router.post("/", handler : createStore )
        router.error(handleError)
    }

    private func getStoreById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let id = request.parameters["id"] {
            try service.findById(id: id) { result, error in
                response.status(.OK)
                handleCompletion(result: result, error: error, response: response, next: next)
            }
        } else {
            throw ErrorHandler.MissingRequireProperty("id")
        }
    }

    private func updateStoreById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
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

    private func deleteStoreById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let id = request.parameters["id"] {
            try service.deleteById(id: id) { result, error in
                response.status(.OK)
                handleCompletion(result: result, error: error, response: response, next: next)
            }
        } else {
            throw ErrorHandler.MissingRequireProperty("id")
        }
    }

    private func getStores(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
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

    private func createStore(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {

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
