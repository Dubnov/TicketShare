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
        FIRAuth.auth()?.createUser(withEmail: user.email, password: user.password) { (authUser, error) in
            
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: user.email, password: user.password) { (loggedInUser, error) in
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = user.fullName
                    changeRequest?.commitChanges()
                }
            } else {
                // TODO: Pop the error
                // error?.localizedDescription
            }
        }
        
        /*let ref = FIRDatabase.database().reference().child("users").child(user.id)
        ref.setValue(user.toFireBase()){(error, dbref) in
            completionBlock(error)
        }*/
    }
    
    func loginUser(email:String, password:String, completionBlock:@escaping (Error?)->Void) {
        FIRAuth.auth()!.signIn(withEmail: email, password: password) {(user, error) in
            if error != nil {
                // TODO: Pop the error
                //print((error?.localizedDescription)!)
            }
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
