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

class StoreService : Service {

    let store : Store
    let ref : Reference
    let pool : ConnectionPool

    init(pool:ConnectionPool) {
        self.ref = Reference.sharedInstance
        self.pool = pool
        self.store = Store()
    }

    func create(body:JSON, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {

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
        if let merchantKey = body["merchantkey"].string {
             tuples.append((store.merchantKey, merchantKey))
        }
        if let currency = body["currency"].string {
            tuples.append((store.currency, currency))
        }

        guard body.count == tuples.count else {
            throw ErrorHandler.WrongParameter
        }

        let id = ref.generateRef()
        tuples.append((store.refStore, id))

        let query = Insert(into: store, valueTuples: tuples).suffix("RETURNING *")

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


    func all(limit:Int = 0, offset:Int = 0, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {

        let query : Select = Select(from: store).order(by: .ASC(store.name))
        var rawQuery : String = ""

        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }

        connection.startTransaction(){ result in
            guard result.success else {
                return oncompletion(nil,result.asError)
            }

            self.count(connection:connection) { data, error in
                guard let count = data else {
                    connection.rollback{ result in
                        if (result.asError != nil) {
                            Log.error(String(describing:result.asError))
                        }
                        oncompletion(nil,error)
                    }
                    return
                }

                let query : Select = Select(from: self.store)
                    .limit(to: limit > 0 ? limit : count)
                    .offset(offset)

                connection.execute(query: query){ result in
                    guard result.success else {
                        connection.rollback{ result in
                            if (result.asError != nil) {
                                Log.error(String(describing:result.asError))
                            }
                            oncompletion(nil,error)
                        }
                        return
                    }
                    var dict = Dictionary<String,Any>()

                    dict["total"] = count

                    dict["limit"] = limit > 0 ? limit : nil

                    dict["offset"] = offset > 0 ? offset : nil

                    dict["data"] = result.asResultSet?.asDictionaries() ?? [[String: Any?]]()

                    connection.commit(){ result in
                        guard result.success else {
                            connection.rollback{ result in
                                if (result.asError != nil) {
                                    Log.error(String(describing:result.asError))
                                }
                                oncompletion(nil,error)
                            }
                            return
                        }
                        oncompletion(dict,nil)
                    }
                }
            }
        }

    }



    func getOne(id:String, oncompletion: @escaping (Dictionary<String,Any>?, Error?) -> ()) throws {
        let select = Select(from:store).where(store.refStore == id)

        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }

        connection.execute(query: select){ result in
            switch result {
                case .error(let error):
                    oncompletion(nil,error)
                case .resultSet(let resultSet):
                    do {
                        print("resultSet \(resultSet)")
                        try oncompletion(resultSet.singleRow(),nil)
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

    func update(id: String, jsonBody: JSON, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws {
        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }

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
        if let merchantKey = jsonBody["merchantkey"].string {
            updatedValue.append((store.merchantKey,merchantKey))
        }

        if let currency = jsonBody["currency"].string {
            updatedValue.append((store.currency, currency))
        }

        if !updatedValue.isEmpty {
            if jsonBody.count == updatedValue.count {
                let query : Update = Update(store, set: updatedValue).where(store.refStore == id).suffix("RETURNING *")

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
                            oncompletion(nil, ErrorHandler.NothingFoundFor(id))
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

    func delete(id:String, oncompletion: @escaping (Dictionary<String,Any>?,Error?) -> ()) throws {

        let delete = Delete(from: store).where(store.refStore == id).suffix("RETURNING *")

        guard let connection = pool.getConnection() else {
            throw ErrorHandler.DBPoolEmpty
        }

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
                     oncompletion(nil,ErrorHandler.NothingFoundFor("id : \(id)"))
            }
        }
    }

    private func count(connection:Connection,oncompletion: @escaping (Int?,Error?) -> ()) {
        let query = Select(RawField("count(*)"), from: store)
        connection.execute(query:query) { result in
            switch (result) {
            case .error(let error):
                oncompletion(nil,error)
            case .resultSet(let resultSet):
                do {
                    switch(try resultSet.singleRow()["count"]){
                        case let result as Int64:
                            oncompletion(Int(result),nil)
                            break
                        case let result as Int:
                            oncompletion(result,nil)
                            break
                        default:
                            throw ErrorHandler.UnexpectedDataStructure
                    }
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
