//
//  User.swift
//  TicketShare
//
//  Created by dor dubnov on 2/26/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class User {
    var username:String
    var password:String
    var fullName:String
    var lastUpdateDate:Date
    
    init(username:String, password:String, fullName:String) {
        self.username = username
        self.password = password
        self.fullName = fullName
        self.lastUpdateDate = Date()
    }
}
