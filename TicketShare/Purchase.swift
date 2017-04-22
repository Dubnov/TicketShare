//
//  Purchase.swift
//  TicketShare
//
//  Created by dor dubnov on 4/22/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
class Purchase {
    var ticketId:String
    var ticketAmount: Int
    var purchaseCost: Double
    var seller:String
    var buyer:String
    var purchaseDate:Date
    
    init(ticketId:String, ticketAmount:Int, purchaseCost:Double, seller:String, buyer:String) {
        self.ticketId = ticketId
        self.ticketAmount = ticketAmount
        self.purchaseCost = purchaseCost
        self.seller = seller
        self.buyer = buyer
        self.purchaseDate = Date()
    }
    
    init(json: Dictionary<String, Any>) {
        self.ticketId = json["ticketId"] as! String
        self.ticketAmount = json["ticketAmount"] as! Int
        self.purchaseCost = json["purchaseCost"] as! Double
        self.seller = json["seller"] as! String
        self.buyer = json["buyer"] as! String
        self.purchaseDate = Date.fromFirebase(json["purchaseDate"] as! Double)
    }
    
    func toFirebase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["ticketId"] = self.ticketId
        json["ticketAmount"] = self.ticketAmount
        json["purchaseCost"] = self.purchaseCost
        json["seller"] = self.seller
        json["buyer"] = self.buyer
        json["purchaseDate"] = Date.toFirebase(self.purchaseDate)
        
        return json
    }
}
