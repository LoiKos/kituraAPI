//
//  ProductService.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 13/04/2017.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftKuery
import SwiftyJSON

class ProductService {
    
    let product = Product()
    let ref : Reference
    let pool : ConnectionPool
    
    init(pool:ConnectionPool){
        self.ref = Reference.sharedInstance
        self.pool = pool
    }
    
    func create(body:JSON, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {
        guard let name = body["name"].string else {
            throw ErrorHandler.MissingRequireProperty("name")
        }
        
        var tuples : [(Column,Any)] = [(Column,Any)]()
        
        tuples.append((product.name,name))
        
        if let picture = body["picture"].string {
            tuples.append((product.picture, picture))
        }
        
        guard body.count == tuples.count else {
            throw ErrorHandler.WrongParameter
        }
        
        let id = self.ref.generateRef()
        tuples.append((product.refProduct, id))
        tuples.append((product.creationDate, Date()))
        
        let query = Insert(into: product, valueTuples: tuples).suffix("RETURNING *")
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        connection.execute(query: query) { result in
            switch result {
            case .error(let error):
                oncompletion(nil,error)
            case .resultSet(let resultSet):
                do {
                    try oncompletion(resultSet.singleRow(),nil)
                } catch {
                    Log.error("Malformed resulset")
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                }
            default:
                oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
            }
        }
    }
    
    func findAll(limit:Int = 0, offset:Int = 0, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {
        
        let query : Select = Select(from: product).order(by: .ASC(product.name))
        var rawQuery : String = ""
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        if limit > 0 {
            rawQuery = try connection.descriptionOf(query: query.limit(to: limit))
        } else if limit < 0 {
            throw ErrorHandler.WrongParameter
        } else {
            rawQuery = try connection.descriptionOf(query: query)
        }
        
        if offset > 0 {
            rawQuery += " OFFSET \(offset)"
        } else if offset < 0 {
            throw ErrorHandler.WrongParameter
        }
        
        count(connection: connection){ countResult, errorCount in
            guard let numberElement = countResult?["count"] else {
                if let error = errorCount {
                    oncompletion(nil, error)
                } else {
                    oncompletion(nil, ErrorHandler.DatabaseError("Impossible to retrieve database response"))
                }
                return
            }
            
            connection.execute(rawQuery){ result in
                switch result {
                case .error(let error):
                    oncompletion( nil, error )
                case .successNoData:
                    var dict = [String: Any]()
                    dict["total"] = numberElement
                    if limit != 0 {
                        dict["limit"] = limit
                    }
                    if offset != 0 {
                        dict["offset"] = offset
                    }
                    dict["data"] = [[String: Any]]()
                    oncompletion(dict, nil)
                case .resultSet(let resultSet):
                    var dict = [String: Any]()
                    
                    dict["total"] = numberElement
                    if limit != 0 {
                        dict["limit"] = limit
                    }
                    if offset != 0 {
                        dict["offset"] = offset
                    }
                    dict["data"] = resultSet.asDictionaries()
                    oncompletion(dict,nil)
                default :
                    oncompletion(nil, ErrorHandler.UnknowError)
                }
                return
            }
        }
    }
    
    func findById(id:String, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {
        let select = Select(from:product).where(product.refProduct == id)
        
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        connection.execute(query: select){ result in
            switch result {
            case .error(let error):
                oncompletion(nil,error)
            case .resultSet(let resultSet):
                do {
                    try oncompletion(resultSet.singleRow(),nil)
                } catch {
                    Log.error("Malformed resulset")
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                }
            case .successNoData:
                Log.error("nothing found for id : \(id)")
                oncompletion(nil, ErrorHandler.NothingFoundFor("id : \(id)"))
            case .success:
                oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
            }
        }
    }
    
    func updateById(id: String, jsonBody: JSON, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws {
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        var updatedValue : [(Column,Any)] = [(Column,Any)]()
        
        if let name = jsonBody["name"].string {
            updatedValue.append((product.name,name))
        }
        
        if let picture = jsonBody["picture"].string {
            updatedValue.append((product.picture, picture))
        }
        
        if !updatedValue.isEmpty {
            if jsonBody.count == updatedValue.count {
                let query : Update = Update(product, set: updatedValue).where(product.refProduct == id).suffix("RETURNING *")
                
                connection.execute(query: query){ result in
                    
                    switch result {
                    case .error(let error):
                        oncompletion(nil,error)
                    case .resultSet(let resultSet):
                        do {
                            try oncompletion(resultSet.singleRow(),nil)
                        } catch {
                            Log.error("Malformed resulset")
                            oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                        }
                    case .successNoData:
                        Log.error("nothing found for id : \(id)")
                        oncompletion(nil,ErrorHandler.NothingFoundFor("id : \(id)"))
                    default:
                        oncompletion(nil,ErrorHandler.UnexpectedDataStructure)
                    }
                }
            } else {
                throw ErrorHandler.WrongParameter
            }
        } else {
            throw ErrorHandler.NothingToUpdate
        }
    }
    
    func deleteById(id:String, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws {
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }
        
        let delete = Delete(from: product).where(product.refProduct == id).suffix("RETURNING *")
        
        connection.execute(query: delete){ queryResult in
            switch(queryResult){
            case .error(let error):
                oncompletion(nil,error)
            case .resultSet(let resultSet):
                do {
                    try oncompletion(resultSet.singleRow(),nil)
                } catch {
                    Log.error("Malformed resulset")
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                }
            case .success( _):
                oncompletion(nil,ErrorHandler.UnexpectedDataStructure)
            case .successNoData:
                Log.error("nothing found for id : \(id)")
                oncompletion(nil,ErrorHandler.NothingFoundFor("id : \(id)"))
            }
        }
    }
    
    private func count(connection:Connection, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) {
        let query : String = "select count(*) from products"
        connection.execute(query){ queryResult in
            switch(queryResult){
            case .error(let error):
                oncompletion(nil,error)
            case .resultSet(let resultSet):
                do {
                    try oncompletion(resultSet.singleRow(),nil)
                } catch {
                    Log.error("Malformed resulset")
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                }
            case .success:
                oncompletion(nil,ErrorHandler.UnexpectedDataStructure)
            case .successNoData:
                oncompletion(nil,ErrorHandler.NothingFoundFor("in table \(self.product.tableName)"))
            }
        }
    }
}
