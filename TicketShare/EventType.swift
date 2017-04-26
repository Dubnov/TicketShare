//
//  Event.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class EventType {
    var id:Int
    var value:String
    var displayName:String
    
    init(id:Int, value:String, displayName:String) {
        self.id = id
        self.value = value
        self.displayName = displayName
    }
    
    init(json: Dictionary<String, Any>) {
        self.id = json["id"] as! Int
        self.value = json["value"] as! String
        self.displayName = json["displayName"] as! String
    }
}
