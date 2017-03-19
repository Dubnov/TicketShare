//
//  Model.swift
//  TicketShare
//
//  Created by Chen g on 15/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
import UIKit

let notifyTicketListUpdate = "com.ticketShare.notifyTicketListUpdate"

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
    
    lazy private var sqlModel:SQLite? = SQLite()
    lazy private var firebaseModel:Firebase? = Firebase()
    
    private init(){}
    
    func addUser(user:User, completionBlock:@escaping (Error?)->Void){
        firebaseModel?.addUser(user: user){(error) in
            completionBlock(error)
        }
    }
    
    func loginUser(email:String, password:String, completionBlock:@escaping (Error?)->Void) {
        firebaseModel?.loginUser(email: email, password: password){(error) in
            completionBlock(error)
        }
    }
    
    func addTicket(ticket: Ticket) {
        self.firebaseModel?.addTicket(tick: ticket){ (error) in
        }
    }
    
    func getAllTicketsAndObserve() {
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: sqlModel?.database,
                                                               table: Ticket.TABLE_NAME)
        firebaseModel?.getAllTicketsAndObserve(lastUpdateDate, callback: { (tickets) in
            var lastUpdate:Date?
            for ticket in tickets{
                ticket.addTicketToLocalDB(database: (self.sqlModel?.database)!)
                if lastUpdate == nil{
                    lastUpdate = ticket.lastUpdateDate
                }else{
                    if lastUpdate!.compare(ticket.lastUpdateDate!) == ComparisonResult.orderedAscending{
                        lastUpdate = ticket.lastUpdateDate
                    }
                }
            }
            
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.sqlModel!.database, table: Ticket.TABLE_NAME, lastUpdate: lastUpdate!)
            }
            
            let totalList = Ticket.getAllTicketsFromLocalDB(database: (self.sqlModel?.database)!)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: notifyTicketListUpdate), object:nil , userInfo:["tickets":totalList])
        })
    }
    
    func saveImage(image:UIImage, name:String, callback:@escaping (String?)->Void){
        firebaseModel?.saveImageToFirebase(image: image, name: name, callback: {(url) in
            if (url != nil){
                self.saveImageToFile(image: image, name: name)
            }
            
            callback(url)
        })
    }
    
    func getImage(urlStr:String, callback:@escaping (UIImage?)->Void){
        let url = URL(string: urlStr)
        let localImageName = url!.lastPathComponent
        if let image = self.getImageFromFile(name: localImageName) {
            callback(image)
        } else {
            firebaseModel?.getImageFromFirebase(url: urlStr, callback:{ (image) in
                if (image != nil){
                    self.saveImageToFile(image: image!, name: localImageName)
                }
                
                callback(image)
            })
        }
    }
    
    private func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
    private func saveImageToFile(image:UIImage, name:String){
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getCurrentAuthUserName() -> String? {
        return firebaseModel?.getCurrentAuthUserName()
    }
    
}
