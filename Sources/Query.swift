//
//  Query.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 04/04/2017.
//
//

import Foundation
import SwiftKueryPostgreSQL
import SwiftKuery

extension PostgreSQLConnection {
    
    /**
     
     Easier syntax to send a query from a Query object defined in Swift Kuery (IBM Package)
     
     - parameters:
        - query: the query to execute in the database
        - completionHandler: provide you a function to execute after receiving the query result
     
     - Author: Loic LE PENN
     
     - Date: April 4, 2017
     
     - version: 1.0
     
     - throws: if query builder failed the function will throw
     */
    public func sendQuery(query:Query, completionHandler: @escaping (QueryResult?, Error?) -> ()) throws {
        
        let string = try query.build(queryBuilder:queryBuilder)

        sendQuery(query: string){ result, error in
            completionHandler(result, error)
        }
    }
    
    /**
     
     Easier syntax to send a query from a string object build to work with Swift Kuery (IBM Package)
     
     - parameters:
        - query: the query to execute in the database.
        - completionHandler: provide you a function to execute after receiving the query result.
     
     - Author: Loic LE PENN
     
     - Date: April 4, 2017
     
     - version: 1.0

     */
    public func sendQuery(query:String, completionHandler: @escaping (QueryResult?, Error?) -> ()){
        self.connect() { error in
            if let error = error {
                completionHandler(nil,error)
            } else {
                self.execute(query){ result in
                    switch result {
                    case .successNoData:
                        completionHandler(result, nil)
                    case .error:
                        completionHandler(nil, error)
                    case .success:
                        completionHandler(result, nil)
                    case .resultSet:
                        completionHandler(result, nil)
                    }
                    self.closeConnection()
                }
            }
        }
    }
    
    
}
