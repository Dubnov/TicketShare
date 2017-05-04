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
    var uid:String
    var email:String
    var password:String
    var fullName:String
    var dateOfBirth: Date
    var lastLocation: String?
    var imageUrl:String?
    
    init(email:String, password:String, fullName:String, dateOfBirth:Date, location:String? = nil, uid:String = "", imageUrl:String? = nil) {
        self.uid = uid
        self.email = email
        self.password = password
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.lastLocation = location
        self.imageUrl = imageUrl
    }
    
    init(json:Dictionary<String, Any>) {
        self.uid = json["uid"] as! String
        self.email = json["email"] as! String
        self.password = json["password"] as! String
        self.fullName = json["fullName"] as! String
        self.dateOfBirth = Date.fromFirebase(json["dateOfBirth"] as! Double)
        
        if let loc = json["lastLocation"] as? String {
            self.lastLocation = loc
        }
        
        if let im = json["imageUrl"] as? String {
            self.imageUrl = im
        }
    }
    
    func toFireBase() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["uid"] = self.uid
        json["email"] = self.email
        json["password"] = self.password
        json["fullName"] = self.fullName
        json["dateOfBirth"] = self.dateOfBirth.toFirebase()
        
        if self.lastLocation != nil {
            json["lastLocation"] = self.lastLocation!
        }
        
        if self.imageUrl != nil {
            json["imageUrl"] = self.imageUrl!
        }
        
        return json
    }
    
    // SQLite Code
    static let TABLE_NAME = "USERS"
    static let EMAIL = "EMAIL"
    static let PASSWORD = "PASSWORD"
    static let FULLNAME = "FULLNAME"
    static let IMAGE_URL = "IMAGE_URL"
    
    static func createUsersTable(database: OpaquePointer?) -> Bool {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " ( "
            + EMAIL + " TEXT PRIMARY KEY, "
            + PASSWORD + " TEXT, "
            + FULLNAME + " TEXT, "
            + IMAGE_URL + " TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
}
