//
//  Firebase.swift
//  TicketShare
//
//  Created by dor dubnov on 2/27/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation

class Firebase{
    static let instance = Firebase()
    
    private init(){
        
    }
    
    func addTicket(tick:Ticket){
        
    }
    
    func getTicketById(id:String) -> Ticket? {
        return nil
    }
    
    func getAllTickets() -> [Ticket] {
        return [Ticket]()
    }
}
