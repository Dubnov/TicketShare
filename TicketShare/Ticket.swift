//
//  Ticket.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Ticket {
    var id:String
    var seller:String
    var title:String
    var eventType:Int
    var amount:Int
    var price:Double
    var isSold:Bool
    var description:String?
    var address:String
    var imageUrl:String?
    var lastUpdateDate:Date?
    var distanceFromUser:Double
    var latitude:Double
    var longitude:Double
    
    init(){
        self.id = ""
        self.seller = ""
        self.title = ""
        self.amount = 0
        self.price = 0
        self.address = ""
        self.eventType = 0
        self.isSold = false
        self.distanceFromUser = 999999.0
        self.latitude = 51.483271
        self.longitude = 0.0
    }
    
    init(seller:String, title:String, price:Double, amount:Int, eventType:Int, address:String, isSold:Bool, description:String?, imageUrl:String?, id:String = "", lastUpdateDate:Date = Date(), latitude:Double, longitude:Double) {
        self.id = id
        self.seller = seller
        self.address = address
        self.title = title
        self.amount = amount
        self.eventType = eventType
        self.price = price
        self.isSold = isSold
        self.imageUrl = imageUrl
        self.description = description
        self.lastUpdateDate = lastUpdateDate
        self.distanceFromUser = 999999.0
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(json: Dictionary<String, Any>) {
        self.id = json["id"] as! String
        self.title = json["title"] as! String
        self.seller = json["seller"] as! String
        self.price = json["price"] as! Double
        self.address = json["address"] as! String
        self.amount = json["amount"] as! Int
        self.eventType = json["eventType"] as! Int
        self.isSold = json["isSold"] as! Bool
        
        if let des = json["description"] as? String {
            self.description = des
        }
    
        if let im = json["imageUrl"] as? String {
            self.imageUrl = im
        }
        if let ts = json["lastUpdateDate"] as? Double {
            self.lastUpdateDate = Date.fromFirebase(ts)
        }
        self.distanceFromUser = 999999.0
        self.latitude = json["latitude"] as! Double
        self.longitude = json["longitude"] as! Double
    }
    
    func toFireBase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["title"] = self.title
        json["seller"] = self.seller
        json["amount"] = self.amount        
        json["price"] = self.price
        json["address"] = self.address
        json["eventType"] = self.eventType
        json["isSold"] = self.isSold
        
        if self.description != nil {
            json["description"] = self.description!
        }
        if imageUrl != nil {
            json["imageUrl"] = imageUrl!
        }
        
        json["lastUpdateDate"] = FIRServerValue.timestamp()
        
        json["latitude"] = self.latitude
        json["longitude"] = self.longitude
        
        return json
    }
    
    // SQLite code
    
    static let TABLE_NAME = "TICKETS"
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
    static let LAST_UPDATE_DATE = "LAST_UPDATE_DATE"
    static let LATITUDE = "LATITUDE"
    static let LONGITUDE = "LONGITUDE"
    
    static func createTicketsTable(database: OpaquePointer?) -> Bool {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " ( "
            + ID + " TEXT PRIMARY KEY, "
            + TITLE + " TEXT, "
            + EVENT_TYPE + " INT, "
            + AMOUNT + " INT, "
            + SELLER + " TEXT, "
            + ADDRESS + " TEXT, "
            + DESCRIPTION + " TEXT, "
            + PRICE + " DOUBLE, "
            + IS_SOLD + " INT, "
            + IMAGE_URL + " TEXT, "
            + LAST_UPDATE_DATE + " DOUBLE, "
            + LATITUDE + " DOUBLE, "
            + LONGITUDE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addTicketToLocalDB(database: OpaquePointer) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Ticket.TABLE_NAME
            + "(" + Ticket.ID + ","
            + Ticket.TITLE + ","
            + Ticket.EVENT_TYPE + ","
            + Ticket.AMOUNT + ","
            + Ticket.SELLER + ","
            + Ticket.ADDRESS + ","
            + Ticket.DESCRIPTION + ","
            + Ticket.PRICE + ","
            + Ticket.IS_SOLD + ","
            + Ticket.IMAGE_URL + ","
            + Ticket.LAST_UPDATE_DATE + ","
            + Ticket.LATITUDE + ","
            + Ticket.LONGITUDE + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = self.id.cString(using: .utf8)
            let title = self.title.cString(using: .utf8)
            let eventType = self.eventType
            let seller = self.seller.cString(using: .utf8)
            let amount = self.amount
            let address = self.address.cString(using: .utf8)
            let description = self.description?.cString(using: .utf8)
            let price = self.price
            let isSold = self.isSold
            var imageUrl = "".cString(using: .utf8)
            if self.imageUrl != nil {
                imageUrl = self.imageUrl!.cString(using: .utf8)
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
            
            if (self.lastUpdateDate == nil){
                self.lastUpdateDate = Date()
            }
            sqlite3_bind_double(sqlite3_stmt, 11, self.lastUpdateDate!.toFirebase());
            
            let latitude = self.latitude
            let longitude = self.longitude
            
            sqlite3_bind_double(sqlite3_stmt, 12, latitude);
            sqlite3_bind_double(sqlite3_stmt, 13, longitude);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllTicketsFromLocalDB(database: OpaquePointer) -> [Ticket]{
        var tickets = [Ticket]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from " + Ticket.TABLE_NAME + ";",-1,&sqlite3_stmt,nil) == SQLITE_OK){
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
                let lastUpdateDate = sqlite3_column_double(sqlite3_stmt, 10)
                let latitude =  sqlite3_column_double(sqlite3_stmt, 11)
                let longitude =  sqlite3_column_double(sqlite3_stmt, 12)
                
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                let ticket = Ticket(seller: seller!, title: title!, price: price, amount: amount, eventType: eventType, address: address!, isSold:isSold, description: description, imageUrl: imageUrl, id: id!, lastUpdateDate: Date.fromFirebase(lastUpdateDate), latitude: latitude, longitude: longitude)
                tickets.append(ticket)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return tickets
    }
    
    static func getTicketByIdFromLocalDB(database: OpaquePointer, ticketId:String) -> Ticket?{
        var ticket:Ticket? = nil
        
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from " + Ticket.TABLE_NAME + " WHERE " + Ticket.ID + " = ?;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            let id = ticketId.cString(using: .utf8)
            sqlite3_bind_text(sqlite3_stmt, 1, id, -1, nil)
            
            if (sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
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
                let lastUpdateDate = sqlite3_column_double(sqlite3_stmt, 10)
                let latitude =  sqlite3_column_double(sqlite3_stmt, 11)
                let longitude =  sqlite3_column_double(sqlite3_stmt, 12)
                
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                ticket = Ticket(seller: seller!, title: title!, price: price, amount: amount, eventType: eventType, address: address!, isSold:isSold, description: description, imageUrl: imageUrl, id: id!, lastUpdateDate: Date.fromFirebase(lastUpdateDate), latitude: latitude, longitude: longitude)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return ticket
    }
    
    static func getUserTicketsForSell(database: OpaquePointer, user: String) -> [Ticket]{
        var tickets = [Ticket]()
        let seller = user.cString(using: .utf8)
        var sqlite3_stmt: OpaquePointer? = nil
        let result = sqlite3_prepare_v2(database,"SELECT * from " + Ticket.TABLE_NAME + " WHERE " + Ticket.IS_SOLD + " = 0 AND " + Ticket.SELLER + " = ?;",-1,&sqlite3_stmt,nil)
        if (result == SQLITE_OK){
            sqlite3_bind_text(sqlite3_stmt, 1, seller, -1, nil)
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
                let lastUpdateDate = sqlite3_column_double(sqlite3_stmt, 10)
                let latitude =  sqlite3_column_double(sqlite3_stmt, 11)
                let longitude =  sqlite3_column_double(sqlite3_stmt, 12)
                
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                let ticket = Ticket(seller: seller!, title: title!, price: price, amount: amount, eventType: eventType, address: address!, isSold:isSold, description: description, imageUrl: imageUrl, id: id!, lastUpdateDate: Date.fromFirebase(lastUpdateDate), latitude: latitude, longitude: longitude)
                tickets.append(ticket)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return tickets
    }
}
