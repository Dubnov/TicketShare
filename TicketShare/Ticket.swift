//
//  Ticket.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class Ticket {
    var seller:String
    var title:String
    var amount:Int
    var description:String?
    var imageUrl:String?
    var lastUpdteDate:Date
    var event:String
    
    init(seller:String, title:String, event:String, amount:Int, description:String?, imageUrl:String?) {
        self.lastUpdteDate = Date()
        self.seller = seller
        self.title = title
        self.amount = amount
        self.event = event
        self.imageUrl = imageUrl
        self.description = description
    }
}
