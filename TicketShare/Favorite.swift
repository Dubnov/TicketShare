//
//  Favorite.swift
//  TicketShare
//
//  Created by dor dubnov on 6/2/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
class Favorite {
    static let TABLE_NAME = "FAVORITES"
    static let ID = "ID"
    static let SELLER = "SELLER"
    static let TITLE = "TITLE"
    static let AMOUNT = "AMOUNT"
    static let ADDRESS = "ADDRESS"
    static let EVENT_TYPE = "EVENT_TYPE"
    static let DESCRIPTION = "DESCRIPTION"
    static let IMAGE_URL = "IMAGE_URL"
    static let PRICE = "PRICE"
    static let IS_SOLD = "IS_SOLD"
    
    static func createFavoritesTable(database: OpaquePointer?) -> Bool {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Favorite.TABLE_NAME + " ( "
            + Favorite.ID + " TEXT PRIMARY KEY, "
            + Favorite.TITLE + " TEXT, "
            + Favorite.EVENT_TYPE + " INT, "
            + Favorite.AMOUNT + " INT, "
            + Favorite.SELLER + " TEXT, "
            + Favorite.ADDRESS + " TEXT, "
            + Favorite.DESCRIPTION + " TEXT, "
            + Favorite.PRICE + " DOUBLE, "
            + Favorite.IS_SOLD + " INT, "
            + Favorite.IMAGE_URL + " TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    static func addFavorite(database: OpaquePointer, ticket:Ticket) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Favorite.TABLE_NAME
            + "(" + Favorite.ID + ","
            + Favorite.TITLE + ","
            + Favorite.EVENT_TYPE + ","
            + Favorite.AMOUNT + ","
            + Favorite.SELLER + ","
            + Favorite.ADDRESS + ","
            + Favorite.DESCRIPTION + ","
            + Favorite.PRICE + ","
            + Favorite.IS_SOLD + ","
            + Favorite.IMAGE_URL + ") VALUES (?,?,?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = ticket.id.cString(using: .utf8)
            let title = ticket.title.cString(using: .utf8)
            let eventType = ticket.eventType
            let seller = ticket.seller.cString(using: .utf8)
            let amount = ticket.amount
            let address = ticket.address.cString(using: .utf8)
            let description = ticket.description?.cString(using: .utf8)
            let price = ticket.price
            let isSold = ticket.isSold
            var imageUrl = "".cString(using: .utf8)
            if ticket.imageUrl != nil {
                imageUrl = ticket.imageUrl!.cString(using: .utf8)
            }
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, title,-1,nil);
            sqlite3_bind_int(sqlite3_stmt, 3, Int32(eventType));
            sqlite3_bind_int(sqlite3_stmt, 4, Int32(amount));
            sqlite3_bind_text(sqlite3_stmt, 5, seller,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 6, address, -1, nil)
            sqlite3_bind_text(sqlite3_stmt, 7, description,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 8, price);
            sqlite3_bind_int(sqlite3_stmt, 9, Int32(NSNumber(booleanLiteral: isSold)));
            sqlite3_bind_text(sqlite3_stmt, 10, imageUrl,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added successfully")
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func removeFavorite(database: OpaquePointer, ticketId:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, "DELETE FROM " + Favorite.TABLE_NAME + " WHERE " + Favorite.ID + " = ?;", -1, &sqlite3_stmt, nil) == SQLITE_OK) {
            let id = ticketId.cString(using: .utf8)
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            
            if (sqlite3_step(sqlite3_stmt) == SQLITE_DONE) {
                print("row deleted successfully")
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllFavorites(database: OpaquePointer) -> [Ticket]{
        var tickets = [Ticket]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from " + Favorite.TABLE_NAME + ";",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                // using the extension method to valide utf8 string values (more explanation at the extension class)
                let id = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 0))
                let title = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 1))
                let eventType = Int(sqlite3_column_int(sqlite3_stmt, 2))
                let amount =  Int(sqlite3_column_int(sqlite3_stmt, 3))
                let seller =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 4))
                let address = String(validatingUTF8: sqlite3_column_text(sqlite3_stmt, 5))
                let description =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 6))
                let price =  sqlite3_column_double(sqlite3_stmt, 7)
                let isSold =  Bool((sqlite3_column_int(sqlite3_stmt, 8) != 0))
                var imageUrl = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt, 9))
                
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                let ticket = Ticket(seller: seller!, title: title!, price: price, amount: amount, eventType: eventType, address: address!, isSold:isSold, description: description, imageUrl: imageUrl, id: id!)
                tickets.append(ticket)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return tickets
    }
}
