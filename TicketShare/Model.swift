//
//  Model.swift
//  TicketShare
//
//  Created by Chen g on 15/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    func toFirebase()->Double{
        return self.timeIntervalSince1970 * 1000
    }
    
    static func fromFirebase(_ interval:String)->Date{
        return Date(timeIntervalSince1970: Double(interval)!)
    }
    
    static func fromFirebase(_ interval:Double)->Date{
        if (interval>9999999999){
            return Date(timeIntervalSince1970: interval/1000)
        }else{
            return Date(timeIntervalSince1970: interval)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
}

class Model{
    static let instance = Model()
    
    lazy private var modelSql:SQLite? = SQLite()
    lazy private var modelFirebase:Firebase? = Firebase()
    
    private init(){
    }
    
    func addUser(user:User){
        modelFirebase?.addUser(user: user){(error) in

        }
    }
    
}
