//
//  StockService.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 14/04/2017.
//
//

import Foundation
import Dispatch
import Kitura
import LoggerAPI
import SwiftKuery
import SwiftyJSON

class StockService {
    
    let product = Product()
    let stock = Stock()
    let store = Store()
    
    let db : Database
    let ref : Reference
    
    init(database:Database){
        self.db = database
        self.ref = Reference.sharedInstance
    }
    
    
    func updateProductInStock (storeId: String, productId: String, body: JSON, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()){
        guard !body.isEmpty else {
            completionHandler(nil, ErrorHandler.EmptyBody)
            return
        }
        
        var (productJson, stockJson) = self.prepare(json: body, required: false)
        
        if productJson.count + stockJson.count == body.count {
            
            let connection = self.db.connection as Connection
            
            connection.connect(){ error in
                guard error == nil else {
                    completionHandler(nil,error)
                    return
                }
                
                connection.startTransaction() { result in
                    let group = DispatchGroup()
                    let queue = DispatchQueue(label:"update",attributes: .concurrent)
                    var errorG : ErrorHandler? = nil
                    
                    queue.async(group: group) {
                        if !productJson.isEmpty {
                            let productUpdate : Update = Update(self.product, set: productJson).where("products.refproduct = '\(productId)'").suffix("Returning *")
                            connection.execute(query: productUpdate){ result in
                                if let error = result.asError {
                                    errorG = ErrorHandler.DatabaseError(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    queue.async(group: group) {
                        if !stockJson.isEmpty {
                            stockJson.append((self.stock.lastUpdate,Date()))
                            let stockUpdate : Update = Update(self.stock, set: stockJson).where("stock.refproduct = '\(productId)' and stock.refstore = '\(storeId)'").suffix("Returning *")
                            connection.execute(query: stockUpdate){ result in
                                if let error = result.asError {
                                    errorG = ErrorHandler.DatabaseError(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    group.notify(queue: queue) {
                        if let errorG = errorG {
                                connection.rollback(){ rollbackStatus in
                                completionHandler(nil, ErrorHandler.DatabaseError(errorG.localizedDescription))
                            }
                            connection.closeConnection()
                        }
                        else {
                            connection.commit(){ result in
                                guard result.success else {
                                    connection.rollback(){ rollbackStatus in
                                        completionHandler(nil, ErrorHandler.DatabaseError("Impossible to commit"))
                                    }
                                    connection.closeConnection()
                                    return
                                }
                                connection.closeConnection()
                                self.getProductInStock(storeId: storeId, productId: productId){ dictionary, error in
                                    completionHandler(dictionary, error)
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        } else {
            Log.error("Bad parameters")
            completionHandler(nil, ErrorHandler.badRequest)
        }
    }
    
    func deleteProductInStock (storeId: String, productId: String, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) {
        
        let connection = self.db.connection as Connection
        
        connection.connect(){ error in
            guard error == nil else {
                completionHandler(nil,error)
                return
            }
            
            defer{
                connection.closeConnection()
            }
            
            connection.startTransaction(){ result in
                let deleteS = Delete(from: self.stock, where: self.stock.refStore == storeId && self.stock.refProduct == productId).suffix("RETURNING *")
                
                var dict = Dictionary<String,Any>()
                connection.execute(query: deleteS){ result in
                    guard result.success else {
                        connection.rollback(){ rollbackStatus in
                            Log.error("Impossible to delete stock in database - ROLLBACK")
                            completionHandler(nil, ErrorHandler.DatabaseError(result.asError.debugDescription))
                        }
                        return
                    }
                    
                    if let result = result.asResultSet{
                        var stockDict = Dictionary<String,Any>()
                        
                        do {
                            let singleRow = try result.singleRow()
                            stockDict = singleRow
                        } catch {
                            completionHandler(nil,error)
                        }
                        
                        let deleteP = Delete(from: self.product, where: self.product.refProduct == productId).suffix("RETURNING *")
                        
                        connection.execute(query: deleteP){ deletedResult in
                            
                            guard deletedResult.success else {
                                connection.rollback(){ rollbackStatus in
                                    Log.error("Impossible to delete product in database - ROLLBACK")
                                    completionHandler(nil, ErrorHandler.DatabaseError(deletedResult.asError.debugDescription))
                                }
                                return
                            }
                            
                            if let result = deletedResult.asResultSet{
                                var productDict =  Dictionary<String,Any>()
                                do {
                                    let singleRow = try result.singleRow()
                                    productDict = singleRow
                                } catch {
                                    completionHandler(nil,error)
                                }
                                
                                connection.commit(){ result in
                                    guard result.success else {
                                        connection.rollback(){ rollbackStatus in
                                            Log.error("Impossible to commit transaction in database - ROLLBACK")
                                            completionHandler(nil, ErrorHandler.DatabaseError(result.asError.debugDescription))
                                        }
                                        return
                                    }
                                    
                                    for (key,value) in stockDict{
                                        dict[key] = value
                                    }
                                    
                                    for (key,value) in productDict {
                                        dict["product_\(key)"] = value
                                    }
                                    
                                    completionHandler(dict,nil)
                                }
                            } else {
                                connection.rollback(){ rollbackStatus in
                                    Log.error("Impossible to handle database response- ROLLBACK")
                                    completionHandler(nil, ErrorHandler.NothingFoundFor(""))
                                }
                            }
                        }
                    } else {
                        connection.rollback(){ rollbackStatus in
                            Log.error("Impossible to handle database response- ROLLBACK")
                            completionHandler(nil,  ErrorHandler.NothingFoundFor(""))
                        }
                    }
                }
            }
        }
    }
    
    func createProductInStock (storeId: String, requestBody: JSON, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) {
        checkIfExist(id: storeId, table: store, column: store.refStore ){ exist in
            if exist {
                var (productJson, stockJson) = self.prepare(json: requestBody)
                
                guard !productJson.isEmpty && !stockJson.isEmpty else {
                    completionHandler(nil,ErrorHandler.WrongParameter)
                    return
                }
                
                let connection = self.db.connection as Connection
                
                connection.startTransaction(){ result in
                    
                    let productReference = self.ref.generateRef()
                    productJson.append((self.product.refProduct, productReference))
                    productJson.append((self.product.creationDate,Date()))
                    
                    let insertP =  Insert(into: self.product, valueTuples: productJson).suffix("RETURNING *")
                    
                    connection.execute(query: insertP){ result in
                        guard result.success else {
                            connection.rollback(){ result in
                                Log.error("Impossible to create product in database - ROLLBACK")
                                completionHandler(nil, ErrorHandler.DatabaseError(result.asError.debugDescription))
                            }
                            return
                        }
                        
                        var result_product : Dictionary<String,Any>? = nil
                        
                        do {
                            result_product = try result.asResultSet?.singleRow()
                        } catch {
                            completionHandler(nil, error)
                        }
                        
                        stockJson.append((self.stock.refStore, storeId))
                        stockJson.append((self.stock.refProduct, productReference))
                        stockJson.append((self.stock.creationDate, Date()))
                        let insertS =  Insert(into: self.stock, valueTuples: stockJson).suffix("RETURNING *")
                        
                        connection.execute(query: insertS){ result in
                            
                            let resultSet = result.asResultSet
                            
                            guard result.success else {
                                let error = result.asError
                                connection.rollback(){ result in
                                    Log.error("Impossible to create stock in database - ROLLBACK")
                                    completionHandler(nil, ErrorHandler.DatabaseError(String(describing: error)))
                                }
                                return
                            }
                            
                            connection.commit(){ result in
                                if result.success{
                                    do {
                                        if var result_data = try resultSet?.singleRow(),
                                            let dict_product = result_product {
                                            for data in dict_product.enumerated() {
                                                result_data["product_\(data.element.key)"] = data.element.value
                                            }
                                            completionHandler(result_data,nil)
                                        } else {
                                            completionHandler(nil, ErrorHandler.UnknowError)
                                        }
                                    } catch {
                                        completionHandler(nil, ErrorHandler.ParsingResponse)
                                    }
                                } else {
                                    let error = result.asError
                                    connection.rollback(){ result in
                                        Log.error("Impossible to create stock in database - ROLLBACK")
                                        completionHandler(nil, ErrorHandler.DatabaseError(String(describing: error)))
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(nil,ErrorHandler.NothingFoundFor("id : \(storeId)"))
            }
        }
    }
    
    
    func getProductInStock(limit:Int = 0, offset:Int = 0, storeId: String, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()) {
        checkIfExist(id: storeId, table: store, column: store.refStore ){ exist in
            if exist {
                let count = "select count(*) from stock where stock.refStore = '\(storeId)'"
                
                self.db.executeQuery(query: count){ result in
                    do {
                        var count = Dictionary<String,Any>()
                        if let countResponse = try result.asResultSet?.singleRow(),
                            let countInt = countResponse["count"] as? Int64
                        {
                            count["Total"] = Int(countInt)
                        } else {
                            Log.error("failed to retrieve count")
                            throw ErrorHandler.UnexpectedDataStructure
                        }
                        
                        let select = Select(from:self.stock).where(self.stock.refStore == storeId).join(self.product).on(self.stock.refProduct == self.product.refProduct).order(by: .ASC(self.product.name))
                        
                        var rawQuery : String = ""
                        
                        if limit > 0 {
                            rawQuery = try self.db.connection.descriptionOf(query: select.limit(to: limit))
                        } else if limit < 0 {
                            completionHandler(nil,ErrorHandler.WrongParameter)
                        } else {
                            rawQuery = try self.db.connection.descriptionOf(query: select)
                        }
                        
                        if offset > 0 {
                            rawQuery += " OFFSET \(offset)"
                        } else if offset < 0 {
                            completionHandler(nil,ErrorHandler.WrongParameter)
                        }
                        
                        
                        self.db.executeQuery(query: rawQuery){ result in
                            var dict = count
                            
                            if limit > 0 {
                                dict["limit"] = limit
                            }
                            
                            if offset > 0 {
                                dict["offset"] = offset
                            }
                            switch(result){
                            case .error(let error):
                                completionHandler(nil,error)
                            case .resultSet(let resultSet):
                                dict["data"] = resultSet.asDictionaries()
                                completionHandler(dict,nil)
                            case .successNoData:
                                dict["data"] = []
                                completionHandler(dict, nil)
                            default:
                                completionHandler(nil,ErrorHandler.UnexpectedDataStructure)
                            }
                        }
                    } catch {
                        completionHandler(nil,error)
                    }
                }
            }
            else {
                completionHandler(nil,ErrorHandler.NothingFoundFor("id : \(storeId)"))
            }
        }
    }
    
    func getProductInStock(storeId: String,productId:String, completionHandler: @escaping (Dictionary<String,Any>?,Error?) -> ()){
        checkIfExist(id: storeId, table: store, column: store.refStore){ exist in
            if exist{
                
                let query = "Select stock.*, products.name as product_name, products.refproduct as product_refproduct, products.creationdate as product_creationdate, products.picture as product_picture from \(self.stock.tableName) inner join \(self.product.tableName) on stock.refproduct=products.refproduct where stock.refstore='\(storeId)' and products.refproduct='\(productId)'"
                
                self.db.executeQuery(query: query){ result in
                    switch(result){
                    case .error(let error):
                        completionHandler(nil, error)
                    case .resultSet(let resultSet):
                        do {
                            let obj = try resultSet.singleRow()
                            completionHandler(obj, nil)
                        } catch {
                            completionHandler(nil, error)
                        }
                    case .successNoData:
                        completionHandler(nil,ErrorHandler.NothingFound)
                    default:
                        completionHandler(nil,ErrorHandler.UnexpectedDataStructure)
                    }
                }
            } else {
                completionHandler(nil,ErrorHandler.NothingFoundFor("id : \(storeId)"))
            }
        }
    }
    
    
    private func checkIfExist( id: String, table: Table, column: Column, completionHandler: @escaping (Bool) -> () ) {
        var bool = false
        let query = "select 1 from \(table.nameInQuery) where \(table.nameInQuery).\(column.name) = '\(id)' limit 1"
        db.executeQuery(query: query){ result in
            if (result.asResultSet != nil) {
                bool = true
            }
            completionHandler( bool )
        }
    }
    
    private func prepare(json: JSON, required: Bool = true ) -> (product: [(Column,Any)], stock: [(Column,Any)]){
        var arrProduct : [(Column,Any)] = [(Column,Any)]()
        var arrStock : [(Column,Any)] = [(Column,Any)]()
        
        if required == true {
            guard let name = json["product_name"].string,
                let quantity = json["quantity"].int,
                let vat = json["vat"].float,
                let priceHT = json["priceht"].float else {
                    return (arrProduct,arrStock)
            }
            arrProduct.append((product.name,name))
            arrStock.append((stock.quantity,quantity))
            arrStock.append((stock.vat,vat))
            arrStock.append((stock.priceHT,priceHT))
        } else {
            if let name = json["product_name"].string { arrProduct.append((product.name,name)) }
            if let quantity = json["quantity"].int { arrStock.append((stock.quantity,quantity)) }
            if let vat = json["vat"].float { arrStock.append((stock.vat,vat)) }
            if let priceHT = json["priceht"].float { arrStock.append((stock.priceHT,priceHT)) }
        }
        
        
        if let picture = json["product_picture"].string {
            arrProduct.append((product.picture, picture))
        }
        
        
        if let status = json["status"].string {
            arrStock.append((stock.status,status))
        }
        
        return (arrProduct,arrStock)
    }
}

