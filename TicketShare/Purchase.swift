//
//  Purchase.swift
//  TicketShare
//
//  Created by dor dubnov on 4/22/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
class Purchase {
    var id:String
    var ticketId:String
    var ticketTitle:String
    var ticketAmount: Int
    var purchaseCost: Double
    var seller:String
    var buyer:String
    var purchaseDate:Date
    
    init(ticketId:String, ticketTitle:String, ticketAmount:Int, purchaseCost:Double, seller:String, buyer:String, id:String = "", purchaseDate:Date = Date()) {
        self.id = id
        self.ticketId = ticketId
        self.ticketTitle = ticketTitle
        self.ticketAmount = ticketAmount
        self.purchaseCost = purchaseCost
        self.seller = seller
        self.buyer = buyer
        self.purchaseDate = purchaseDate
    }
    
    init(json: Dictionary<String, Any>) {
        self.id = json["id"] as! String
        self.ticketId = json["ticketId"] as! String
        self.ticketTitle = json["ticketTitle"] as! String
        self.ticketAmount = json["ticketAmount"] as! Int
        self.purchaseCost = json["purchaseCost"] as! Double
        self.seller = json["seller"] as! String
        self.buyer = json["buyer"] as! String
        self.purchaseDate = Date.fromFirebase(json["purchaseDate"] as! Double)
    }
    
    func toFirebase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["ticketId"] = self.ticketId
        json["ticketTitle"] = self.ticketTitle
        json["ticketAmount"] = self.ticketAmount
        json["purchaseCost"] = self.purchaseCost
        json["seller"] = self.seller
        json["buyer"] = self.buyer
        json["purchaseDate"] = self.purchaseDate.toFirebase()
        
        return json
    }
    
    // SQL code
    
    static let TABLE_NAME = "PURCHASES"
    static let ID = "ID"
    static let SELLER = "SELLER"
    static let TICKET_ID = "TICKET_ID"
    static let TICKET_TITLE = "TICKET_TITLE"
    static let TICKET_AMOUNT = "TICKET_AMOUNT"
    static let PURCHASE_COST = "PURCHASE_COST"
    static let BUYER = "BUYER"
    static let PURCHASE_DATE = "PURCHASE_DATE"
    
    static func createPurchasesTable(database: OpaquePointer?) -> Bool {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Purchase.TABLE_NAME + " ( "
            + Purchase.ID + " TEXT PRIMARY KEY, "
            + Purchase.TICKET_ID + " TEXT, "
            + Purchase.TICKET_TITLE + " TEXT, "
            + Purchase.TICKET_AMOUNT + " INT, "
            + Purchase.PURCHASE_COST + " DOUBLE, "
            + Purchase.SELLER + " TEXT, "
            + Purchase.BUYER + " TEXT, "
            + Purchase.PURCHASE_DATE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addPurchaseToLocalDB(database: OpaquePointer) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Purchase.TABLE_NAME
            + "(" + Purchase.ID + ","
            + Purchase.TICKET_ID + ","
            + Purchase.TICKET_TITLE + ","
            + Purchase.TICKET_AMOUNT + ","
            + Purchase.PURCHASE_COST + ","
            + Purchase.SELLER + ","
            + Purchase.BUYER + ","
            + Purchase.PURCHASE_DATE + ") VALUES (?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = self.id.cString(using: .utf8)
            let ticketId = self.ticketId.cString(using: .utf8)
            let ticketTitle = self.ticketTitle.cString(using: .utf8)
            let ticketAmount = self.ticketAmount
            let seller = self.seller.cString(using: .utf8)
            let purchaseCost = self.purchaseCost
            let buyer = self.buyer.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, ticketId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, ticketTitle,-1,nil);
            sqlite3_bind_int(sqlite3_stmt, 4, Int32(ticketAmount));
            sqlite3_bind_double(sqlite3_stmt, 5, purchaseCost);
            sqlite3_bind_text(sqlite3_stmt, 6, seller,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 7, buyer, -1, nil)
            sqlite3_bind_double(sqlite3_stmt, 8, self.purchaseDate.toFirebase());
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getCurrentUserPurchasesFromLocalDB(database: OpaquePointer) -> [Purchase]{
        var purchases = [Purchase]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from " + Purchase.TABLE_NAME + ";",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                // using the extension method to valide utf8 string values (more explanation at the extension class)
                let id = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 0))
                let ticketId = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 1))
                let ticketTitle = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 2))
                let ticketAmount = Int(sqlite3_column_int(sqlite3_stmt, 3))
                let purchaseCost = sqlite3_column_double(sqlite3_stmt, 4)
                let seller =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 5))
                let buyer = String(validatingUTF8: sqlite3_column_text(sqlite3_stmt, 6))
                let purchaseDate = sqlite3_column_double(sqlite3_stmt, 7)
                
                let purchase = Purchase(ticketId: ticketId!, ticketTitle: ticketTitle!, ticketAmount: ticketAmount, purchaseCost: purchaseCost, seller: seller!, buyer: buyer!, id:id!, purchaseDate: Date.fromFirebase(purchaseDate))
                purchases.append(purchase)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return purchases
    }
    
    static func getCurrentUserTicketsSold(database: OpaquePointer, user:String) -> [Purchase]{
        var purchases = [Purchase]()
        let seller = user.cString(using: .utf8)
        var sqlite3_stmt: OpaquePointer? = nil
        
        let result = sqlite3_prepare_v2(database,"SELECT * from " + Purchase.TABLE_NAME + " WHERE " + Purchase.SELLER + " = ?;",-1,&sqlite3_stmt,nil)
        if (result == SQLITE_OK){
            sqlite3_bind_text(sqlite3_stmt, 1, seller, -1, nil)
            
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                // using the extension method to valide utf8 string values (more explanation at the extension class)
                let id = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 0))
                let ticketId = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 1))
                let ticketTitle = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 2))
                let ticketAmount = Int(sqlite3_column_int(sqlite3_stmt, 3))
                let purchaseCost = sqlite3_column_double(sqlite3_stmt, 4)
                let seller =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 5))
                let buyer = String(validatingUTF8: sqlite3_column_text(sqlite3_stmt, 6))
                let purchaseDate = sqlite3_column_double(sqlite3_stmt, 7)
                
                let purchase = Purchase(ticketId: ticketId!, ticketTitle: ticketTitle!, ticketAmount: ticketAmount, purchaseCost: purchaseCost, seller: seller!, buyer: buyer!, id:id!, purchaseDate: Date.fromFirebase(purchaseDate))
                purchases.append(purchase)
            }
        } else {
            print(sqlite3_errmsg(database))
            print(sqlite3_errstr(result))
        }
        sqlite3_finalize(sqlite3_stmt)
        return purchases
    }
    
    static func getCurrentUserTicketsBought(database: OpaquePointer, user:String) -> [Purchase]{
        var purchases = [Purchase]()
        let buyer = user.cString(using: .utf8)
        var sqlite3_stmt: OpaquePointer? = nil
        
        let result = sqlite3_prepare_v2(database,"SELECT * from " + Purchase.TABLE_NAME + " WHERE " + Purchase.BUYER + " = ?;",-1,&sqlite3_stmt,nil)
        
        if (result == SQLITE_OK){
            sqlite3_bind_text(sqlite3_stmt, 1, buyer, -1, nil)
            
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                // using the extension method to valide utf8 string values (more explanation at the extension class)
                let id = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 0))
                let ticketId = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 1))
                let ticketTitle = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 2))
                let ticketAmount = Int(sqlite3_column_int(sqlite3_stmt, 3))
                let purchaseCost = sqlite3_column_double(sqlite3_stmt, 4)
                let seller =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 5))
                let buyer = String(validatingUTF8: sqlite3_column_text(sqlite3_stmt, 6))
                let purchaseDate = sqlite3_column_double(sqlite3_stmt, 7)
                
                let purchase = Purchase(ticketId: ticketId!, ticketTitle: ticketTitle!, ticketAmount: ticketAmount, purchaseCost: purchaseCost, seller: seller!, buyer: buyer!, id:id!, purchaseDate: Date.fromFirebase(purchaseDate))
                purchases.append(purchase)
            }
        } else {
            print(sqlite3_errmsg(database))
            print(sqlite3_errstr(result))
        }
        sqlite3_finalize(sqlite3_stmt)
        return purchases
    }
}
