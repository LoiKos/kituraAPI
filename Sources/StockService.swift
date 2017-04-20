//
//  StockService.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 14/04/2017.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftKuery
import SwiftyJSON

class StockService {
    
    let product = Product()
    let stock = Stock()
    let store = Store()
    
    let db : Database
    
    init(database:Database){
        self.db = database
    }
    
    
    func updateProductInStock (storeId: String, productId: String, body: JSON, completionHandler: @escaping ([String:Any?]?,Error?) -> ()){
            
            var (productJson, stockJson) = self.prepare(json: body, required: false)
            
            if productJson.count + stockJson.count == body.count {
                
                var productUpdate : Update? = nil
                var stockUpdate : Update? = nil
                
                if !productJson.isEmpty {
                    productUpdate = Update(product, set: productJson).suffix("Returning *")
                }
                
                if !stockJson.isEmpty {
                    stockJson.append((stock.lastUpdate,Date()))
                    stockUpdate = Update(stock, set: stockJson).suffix("Returning *")
                }
                
                if let productUpdate = productUpdate {
                    db.executeQuery(query: productUpdate){ result in
                        if let error = result.asError{
                            completionHandler(nil, error)
                        } else if let productSet = result.asResultSet {
                            if let stockUpdate = stockUpdate {
                                self.db.executeQuery(query: stockUpdate){ result in
                                    if let error = result.asError{
                                        completionHandler(nil, error)
                                    } else if let stockSet = result.asResultSet {
                                        do {
                                            if let stockDict = try stockSet.uniqueSingleRow(),
                                                let productDict = try productSet.uniqueSingleRow(){
                                                
                                                var returnValue = [String:Any?]()
                                                for (key,value) in stockDict {
                                                    returnValue[key] = value
                                                }
                                                for (key,value) in productDict {
                                                    returnValue[key] = value
                                                }
                                                completionHandler(returnValue,nil)
                                            }
                                        } catch {
                                            completionHandler(nil,error)
                                        }
                                    } else {
                                        completionHandler(nil,ErrorHandler.UnexpectedDataStructure)
                                    }
                                }
                            } else {
                                do {
                                    let productDict = try productSet.uniqueSingleRow()
                                    completionHandler(productDict,nil)
                                } catch {
                                    completionHandler(nil,error)
                                }
                            }
                        } else {
                            completionHandler(nil,ErrorHandler.UnexpectedDataStructure)
                        }
                    }
                } else {
                    if let stockUpdate = stockUpdate {
                        db.executeQuery(query: stockUpdate){ result in
                            if let error = result.asError{
                                completionHandler(nil, error)
                            } else if let stockSet = result.asResultSet {
                                do {
                                    let stockDict = try stockSet.uniqueSingleRow()
                                    completionHandler(stockDict,nil)
                                } catch {
                                    completionHandler(nil,error)
                                }
                            } else {
                                completionHandler(nil,ErrorHandler.UnexpectedDataStructure)
                            }
                        }
                    }
                }
        }
    }
    
    func deleteProductInStock (storeId: String, productId: String, completionHandler: @escaping ([String:Any?]?,Error?) -> ()) {
        
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
                
                var dict = [String:Any?]()
                connection.execute(query: deleteS){ result in
                    guard result.success else {
                        connection.rollback(){ rollbackStatus in
                            Log.error("Impossible to delete stock in database - ROLLBACK")
                            completionHandler(nil, ErrorHandler.DatabaseError(result.asError.debugDescription))
                        }
                        return
                    }

                    if let result = result.asResultSet{
                        var stockDict = [String:Any]()
                        
                        do {
                            if let singleRow = try result.uniqueSingleRow() {
                                stockDict = singleRow
                            }
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
                                var productDict =  [String:Any]()
                                do {
                                    if let singleRow = try result.uniqueSingleRow() {
                                        productDict = singleRow
                                    }
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
                                        dict[key] = value
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
    
    func createProductInStock (storeId: String, requestBody: JSON, completionHandler: @escaping ([String:Any?]?,Error?) -> ()) {
        checkIfExist(id: storeId, table: store, column: store.refStore ){ exist in
            if exist {
                var (productJson, stockJson) = self.prepare(json: requestBody)
                
                guard !productJson.isEmpty && !stockJson.isEmpty else {
                    completionHandler(nil,ErrorHandler.WrongParameter)
                    return
                }
                
                let connection = self.db.connection as Connection
                
                connection.startTransaction(){ result in
                    
                    let productReference = generateRef()
                    productJson.append((self.product.refProduct, productReference))
                    productJson.append((self.product.creationDate,Date()))
                    
                    let insertP =  Insert(into: self.product, valueTuples: productJson)
                    
                    connection.execute(query: insertP){ result in
                        guard result.success else {
                            connection.rollback(){ result in
                                Log.error("Impossible to create product in database - ROLLBACK")
                                completionHandler(nil, ErrorHandler.DatabaseError(result.asError.debugDescription))
                            }
                            return
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
                                        try completionHandler(resultSet?.uniqueSingleRow(),nil)
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
    
    
    func getProductInStock(limit:Int = 0, offset:Int = 0, storeId: String, completionHandler: @escaping ([String:Any?]?,Error?) -> ()) {
        checkIfExist(id: storeId, table: store, column: store.refStore ){ exist in
            if exist {
                let count = "select count(*) from stock where stock.refStore = '\(storeId)'"
                
                self.db.executeQuery(query: count){ result in
            
                    do {
                        var count = [String:Any?]()
                        if let countResponse = try result.asResultSet?.uniqueSingleRow(),
                           let countString = countResponse["count"] as? String,
                           let countInt = Int(countString) {
                                count["Total"] = countInt
                        } else {
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
            guard let name = json["name"].string,
                let quantity = json["quantity"].int,
                let vat = json["vat"].float,
                let priceHT = json["priceHT"].float else {
                    return (arrProduct,arrStock)
                }
            arrProduct.append((product.name,name))
            arrStock.append((stock.quantity,quantity))
            arrStock.append((stock.vat,vat))
            arrStock.append((stock.priceHT,priceHT))
        } else {
            if let name = json["name"].string { arrProduct.append((product.name,name)) }
            if let quantity = json["quantity"].int { arrStock.append((stock.quantity,quantity)) }
            if let vat = json["vat"].float { arrStock.append((stock.vat,vat)) }
            if let priceHT = json["priceHT"].float { arrStock.append((stock.priceHT,priceHT)) }
        }
        
       
        if let picture = json["picture"].string {
           arrProduct.append((product.picture, picture))
        }
        
        
        if let status = json["status"].string {
            arrStock.append((stock.status,status))
        }
        
        return (arrProduct,arrStock)
    }
}

