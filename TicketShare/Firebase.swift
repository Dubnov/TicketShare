//
//  Firebase.swift
//  TicketShare
//
//  Created by dor dubnov on 2/27/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class Firebase{
    
    init(){
        FIRApp.configure()
    }
    
    func addUser(user:User, completionBlock:@escaping (Error?)->Void){
        let ref = FIRDatabase.database().reference().child("users").child(user.id)
        ref.setValue(user.toFireBase()){(error, dbref) in
            completionBlock(error)
        }
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
