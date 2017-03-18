//
//  Event.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class Event {
    var id:String
    var title:String
    var type:String
    var startDate:Date
    var endDate:Date
    var lastUpdateDate:Date
    
    init(id:String, title:String, type:String, startDate:Date, endDate:Date) {
        self.lastUpdateDate = Date()
        self.id = id
        self.title = title
        self.type = type
        self.startDate = startDate
        self.endDate = endDate 
    }
}
