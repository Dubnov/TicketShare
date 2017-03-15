//
//  User.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User {
    var email:String
    var password:String
    var fullName:String
    var imageUrl:String?
    var lastUpdateDate:Date?
    
    init(email:String, password:String, fullName:String, imageUrl:String? = nil) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.imageUrl = imageUrl
    }
    
    init(json:Dictionary<String, Any>) {
        self.email = json["email"] as! String
        self.password = json["password"] as! String
        self.fullName = json["fullName"] as! String
        
        if let im = json["imageUrl"] as? String {
            self.imageUrl = im
        }
        if let ts = json["lastUpdateDate"] as? Double {
            self.lastUpdateDate = Date.fromFirebase(ts)
        }
    }
    
    func toFireBase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["email"] = self.email
        json["password"] = self.password
        json["fullName"] = self.fullName
        
        if imageUrl != nil {
            json["imageUrl"] = imageUrl!
        }
        
        json["lastUpdateDate"] = FIRServerValue.timestamp()
        
        return json
    }
}
