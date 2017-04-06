//
//  routingCenter.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import SwiftKueryPostgreSQL
import SwiftyJSON

func routingCenter(connection:PostgreSQLConnection) -> Router {
    
    let router = Router()
    
    router.all("/", middleware: BodyParser())
    
    router.get("/"){ request, response,_ in
        try response.send(status: .notFound).end()
    }
    
    router.get("/api/v1/status"){ request, response,_ in
        let json = JSON(
            [
                "name":"MBAO API",
                "version":"v1.0",
                "status":"available"
            ])
        try response.send(json: json).end()
    }
    
    router.all("/api/v1/stores", middleware: storeRoutes(connection: connection))

    return router
}
