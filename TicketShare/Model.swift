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
let notifyTicketsSoldUpdate = "com.ticketShare.notifyTicketsSoldUpdate"
let notifyBoughtTicketsUpdate = "com.ticketShare.notifyBoughtTicketsUpdate"
let notifyTicketsForSell = "com.ticketShare.notifyTicketsForSell"
let notifyRecommendedTickets = "com.ticketShare.notifyRecommendedTickets"

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
    static var eventTypes:[EventType] = [EventType]()
    
    lazy private var sqlModel:SQLite? = SQLite()
    lazy private var firebaseModel:Firebase? = Firebase()
    
    private init(){}
    
    func addUser(user:User, completionBlock:@escaping (Error?)->Void){
        firebaseModel?.addUser(user: user){(error) in
            completionBlock(error)
        }
    }
    
    func loginUser(email:String, password:String, completionBlock:@escaping (Any?)->Void) {
        firebaseModel?.loginUser(email: email, password: password){(error) in
            completionBlock(error)
        }
    }
    
    func addTicket(ticket: Ticket) {
        self.firebaseModel?.addTicket(tick: ticket){ (error) in
            self.getCurrentUserTicketsForSell()
        }
    }
    
    func getAllTicketsAndObserve() {
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: sqlModel?.database, table: Ticket.TABLE_NAME)
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
        
        firebaseModel?.getEventTypes(callback: {(eveTypes) in
            Model.eventTypes = eveTypes
        })
    }
    
    func getCurrentUserPurchases(callback:@escaping()->Void) {
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: sqlModel?.database, table: Purchase.TABLE_NAME)
        
        firebaseModel?.getCurrentUserPurchases(lastUpdateDate, callback: { (purchases) in
            var lastUpdate:Date?
            for purchase in purchases{
                purchase.addPurchaseToLocalDB(database: (self.sqlModel?.database)!)
                if lastUpdate == nil{
                    lastUpdate = purchase.purchaseDate
                }else{
                    if lastUpdate!.compare(purchase.purchaseDate) == ComparisonResult.orderedAscending{
                        lastUpdate = purchase.purchaseDate
                    }
                }
            }
            
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.sqlModel!.database, table: Purchase.TABLE_NAME, lastUpdate: lastUpdate!)
            }
            
            callback()
            
            // return Purchase.getCurrentUserPurchasesFromLocalDB(database: (self.sqlModel?.database)!)
        })
        
    }
    
    func getCurrentUserTicketsSold(){
        //self.getCurrentUserPurchases {
        let userTicketsSold = //Purchase.getCurrentUserPurchasesFromLocalDB(database: self.sqlModel!.database!)
            Purchase.getCurrentUserTicketsSold(database: self.sqlModel!.database!, user: self.getCurrentAuthUserUID()!)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notifyTicketsSoldUpdate), object:nil , userInfo:["tickets":userTicketsSold])
        //}
    }
    
    func getCurrentUserTicketsBought(){
        //self.getCurrentUserPurchases {
        let userBoughtTickets = //Purchase.getCurrentUserPurchasesFromLocalDB(database: self.sqlModel!.database!)
            Purchase.getCurrentUserTicketsBought(database: self.sqlModel!.database!, user: self.getCurrentAuthUserUID()!)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notifyBoughtTicketsUpdate), object:nil , userInfo:["tickets":userBoughtTickets])
        //}
    }
    
    func getCurrentUserTicketsForSell(){
        let ticketForSell = Ticket.getUserTicketsForSell(database: self.sqlModel!.database!, user: self.getCurrentAuthUserUID()!)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: notifyTicketsForSell), object:nil , userInfo:["tickets":ticketForSell])
    }
    
    func getUserFavoriteTickets(user:String?) -> [Ticket] {
        let tickets = Favorite.getAllFavorites(database: self.sqlModel!.database!)
        
        // self.firebaseModel!.currAuthUser!.addFavorites(tickets: tickets)
        return tickets
    }
    
    func addFavoriteTicket(ticket:Ticket) {
        self.firebaseModel!.currAuthUser!.addFavorite(ticket: ticket)
        Favorite.addFavorite(database: self.sqlModel!.database!, ticket: ticket)
    }
    
    func removeFavoriteTicket(ticketId:String) {
        self.firebaseModel!.currAuthUser!.removeFavorite(ticketId: ticketId)
        Favorite.removeFavorite(database: self.sqlModel!.database!, ticketId: ticketId)
    }
    
    func isTicketInUserFavorites(ticket: Ticket) -> Bool {
        for tick in self.firebaseModel!.currAuthUser!.favorites {
            if (ticket.id == tick.key) {
                return true
            }
        }
        
        return false
    }
    
    func getRecommendedTickets() {
        self.firebaseModel!.getRecommendedTicketsForUser(userId: self.getCurrentAuthUserUID()!){ ticketsIds in
            var tickets = [Ticket]()
            for id in ticketsIds {
                let tick = Ticket.getTicketByIdFromLocalDB(database: self.sqlModel!.database!, ticketId: id)
                
                if (tick != nil) {
                    tickets.append(tick!)
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: notifyRecommendedTickets), object:nil , userInfo:["tickets":tickets])
        }
    }
    
    
    func buyTicket(ticket:Ticket) {
        self.firebaseModel?.buyTicket(ticket: ticket) { error in
            if (error == nil) {
                let purch:Purchase = Purchase(ticketId: ticket.id, ticketTitle: ticket.title, ticketAmount: ticket.amount, purchaseCost: Double(ticket.amount) * ticket.price, seller: ticket.seller, buyer: self.getCurrentAuthUserUID()!)
                self.firebaseModel?.addPurchase(purchase: purch) {error in
                    print(error ?? "")
                }
            }
        }
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
    
    func getCurrentAuthUserEmail() -> String? {
        return firebaseModel?.getCurrentAuthUserEmail()
    }
    
    func getCurrentAuthUserUID() -> String? {
        return firebaseModel?.getCurrentAuthUserUID()
    }
    
    func signOut() {
        firebaseModel?.signOut()
    }
    
}
