//
//  StoreHandler.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 05/04/2017.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftKuery
import SwiftyJSON

class StoreService {
    
    let store = Store()
    let db : Database
    
    init(database:Database){
        self.db = database
    }
    
    func create(body:JSON, oncompletion: @escaping ([String : Any?]?, Error?) -> ()) throws {
        
        guard let name = body["name"].string else {
            throw ErrorHandler.MissingRequireProperty("name")
        }
        var tuples : [(Column,Any)] = [(Column,Any)]()

        tuples.append((store.name,name))
        
        if let picture = body["picture"].string {
            tuples.append((store.picture, picture))
        }
        if let vat = body["vat"].string {
            tuples.append((store.vat, vat))
        }
        if let merchantKey = body["merchantKey"].string {
             tuples.append((store.merchantKey, merchantKey))
        }
        
        guard body.count == tuples.count else {
            throw ErrorHandler.WrongParameter
        }
        
        let id = generateRef()
        tuples.append((store.refStore, id))
        
        let query = Insert(into: store, valueTuples: tuples).suffix("RETURNING refStore")
        
        db.executeQuery(query: query) { result in
            switch result {
                case .error(let error):
                    oncompletion(nil,error)
                case .resultSet(let resultSet):
                    do {
                        try oncompletion(resultSet.uniqueSingleRow(),nil)
                    } catch {
                        Log.error("Malformed resulset")
                        oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                    }
                default:
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
            }
        }
    }
    
    
    func findAll(limit:Int = 0, offset:Int = 0, oncompletion: @escaping ([String : Any?]?, Error?) -> ()) throws {
        
        let query : Select = Select(from: store).order(by: .ASC(store.name))
        var rawQuery : String = ""

        if limit > 0 {
            rawQuery = try db.connection.descriptionOf(query: query.limit(to: limit))
        } else if limit < 0 {
            throw ErrorHandler.WrongParameter
        } else {
            rawQuery = try db.connection.descriptionOf(query: query)
        }
        
        if offset > 0 {
            rawQuery += " OFFSET \(offset)"
        } else if offset < 0 {
            throw ErrorHandler.WrongParameter
        }
        
        count(){ countResult, errorCount in
            guard let numberElement = countResult?["count"] else {
                if let error = errorCount {
                    oncompletion(nil, error)
                } else {
                    oncompletion(nil, ErrorHandler.DatabaseError("Impossible to retrieve database response"))
                }
                return
            }
            
            self.db.executeQuery(query: rawQuery){ result in
                switch result {
                    case .error(let error):
                        oncompletion( nil, error )
                    case .successNoData:
                        var dict : [String: Any?] = [String: Any?]()
                        dict["total"] = numberElement
                        if limit != 0 {
                            dict["limit"] = limit
                        }
                        if offset != 0 {
                            dict["offset"] = offset
                        }
                        dict["data"] = [[String: Any?]]()
                        oncompletion(dict, nil)
                    case .resultSet(let resultSet):
                        var dict : [String: Any?] = [String: Any?]()
                        
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
    
    
    
    func findById(id:String, oncompletion: @escaping ([String:Any?]?, Error?) -> ()){
        let select = Select(from:store).where(store.refStore == id)
        
        db.executeQuery(query: select){ result in
            switch result {
                case .error(let error):
                    oncompletion(nil,error)
                case .resultSet(let resultSet):
                    do {
                        try oncompletion(resultSet.uniqueSingleRow(),nil)
                    } catch {
                        Log.error("Malformed resulset")
                        oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                    }
                case .successNoData:
                    oncompletion(nil, ErrorHandler.NothingFoundFor("id : \(id)"))
                case .success:
                    oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
            }
        }
    }
    
    func updateById(id: String, jsonBody: JSON, oncompletion: @escaping ([String:Any?]?,Error?) -> ()) throws {
        var updatedValue : [(Column,Any)] = [(Column,Any)]()
        
        if let name = jsonBody["name"].string {
            updatedValue.append((store.name,name))
        }
        if let picture = jsonBody["picture"].string {
            updatedValue.append((store.picture,picture))
        }
        
        if let vat = jsonBody["vat"].float {
            updatedValue.append((store.vat,vat))
        }
        if let merchantKey = jsonBody["merchantKey"].string {
            updatedValue.append((store.merchantKey,merchantKey))
        }
        
        if !updatedValue.isEmpty {
            if jsonBody.count == updatedValue.count {
                let query : Update = Update(store, set: updatedValue).where(store.refStore == id).suffix("RETURNING *")
                
                db.executeQuery(query: query){ result in
                    
                    switch result {
                        case .error(let error):
                            oncompletion(nil,error)
                        case .resultSet(let resultSet):
                            do {
                                try oncompletion(resultSet.uniqueSingleRow(),nil)
                            } catch {
                                Log.error("Malformed resulset")
                                oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                            }
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
    
    func deleteById(id:String, oncompletion: @escaping ([String:Any?]?,Error?) -> ()){
       
        let delete = Delete(from: store).where(store.refStore == id).suffix("RETURNING *")
        
        db.executeQuery(query: delete){ queryResult in
            switch(queryResult){
                case .error(let error):
                    oncompletion(nil,error)
                case .resultSet(let resultSet):
                    do {
                        try oncompletion(resultSet.uniqueSingleRow(),nil)
                    } catch {
                        Log.error("Malformed resulset")
                        oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                    }
                case .success(let result):
                     oncompletion(nil,ErrorHandler.UnexpectedDataStructure)
                case .successNoData:
                     oncompletion(nil,ErrorHandler.NothingFoundFor("id : \(id)"))
            }
        }
    }
    
    private func count(oncompletion: @escaping ([String:Any?]?,Error?) -> ()){
        let query : String = "select count(*) from stores"
        db.executeQuery(query:query) { queryResult in
            switch(queryResult){
                case .error(let error):
                    oncompletion(nil,error)
                case .resultSet(let resultSet):
                    do {                    
                        try oncompletion(resultSet.uniqueSingleRow(),nil)
                    } catch {
                        Log.error("Malformed resulset")
                        oncompletion(nil, ErrorHandler.UnexpectedDataStructure)
                    }
                case .success:
                    oncompletion(nil,ErrorHandler.UnexpectedDataStructure)
                case .successNoData:
                    oncompletion(nil,ErrorHandler.NothingFoundFor("in table \(self.store.tableName)"))
            }
        }
    }
}
