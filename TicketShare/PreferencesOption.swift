//
//  PreferencesOption.swift
//  TicketShare
//
//  Created by dor dubnov on 8/22/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class PreferencesOption {
    var id:Int
    var value:String
    
    init(id:Int, value:String) {
        self.id = id
        self.value = value
    }
    
    init(json: Dictionary<String, Any>) {
        self.id = json["id"] as! Int
        self.value = json["value"] as! String
    }
    
    func toFireBase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["id"] = self.id
        json["value"] = self.value
        return json
    }
}
