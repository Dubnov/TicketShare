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
    var currAuthUser: FIRUser? = nil;
    
    init(){
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
    }
    
    lazy var storageRef = FIRStorage.storage().reference(forURL: "gs://ticketshare-5ca22.appspot.com/")

    
    
    func addUser(user:User, completionBlock:@escaping (Error?)->Void){
        FIRAuth.auth()?.createUser(withEmail: user.email, password: user.password) { (authUser, error) in
            
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: user.email, password: user.password) { (loggedInUser, error) in
                    if error == nil {
                        let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                        changeRequest?.displayName = user.fullName
                        changeRequest?.commitChanges() {(err) in
                            completionBlock(err)
                        }
                        
                    } else {
                        completionBlock(error)
                    }
                }
            } else {
                completionBlock(error)
            }
        }
        
        /*let ref = FIRDatabase.database().reference().child("users").child(user.id)
        ref.setValue(user.toFireBase()){(error, dbref) in
            completionBlock(error)
        }*/
    }
    
    func loginUser(email:String, password:String, completionBlock:@escaping (Error?)->Void) {
        FIRAuth.auth()!.signIn(withEmail: email, password: password) {(user, error) in
            completionBlock(error)
        }
    }
    
    func addTicket(tick:Ticket, completionBlock:@escaping (Error?)->Void){
        let ref = FIRDatabase.database().reference().child("tickets").childByAutoId()
        
        // set the new ticket's data on the record ref
        ref.setValue(tick.toFireBase()){(error, dbref) in
            completionBlock(error)
        }
    }
    
    func getAllTickets(_ lastUpdateDate:Date? , callback:@escaping ([Ticket])->Void){
        let handler = {(snapshot:FIRDataSnapshot) in
            var tickets = [Ticket]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let tick = Ticket(json: json)
                        tickets.append(tick)
                    }
                }
            }
            callback(tickets)
        }
        
        let ref = FIRDatabase.database().reference().child("tickets")
        
        if (lastUpdateDate != nil){
            let fbQuery = ref.queryOrdered(byChild:"lastUpdateDate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observeSingleEvent(of: .value, with: handler)
        }else{
            ref.observeSingleEvent(of: .value, with: handler)
        }
    }
    
    func getAllTicketsAndObserve(_ lastUpdateDate:Date? , callback:@escaping ([Ticket])->Void) {
        // creating the code that will parse the data returned from the observe function
        // that loads the tickets from firebase (it will be called on the first call and
        // for each change to the data in the firebase server)
        let handler = {(snapshot:FIRDataSnapshot) in
            var tickets = [Ticket]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let tick = Ticket(json: json)
                        tickets.append(tick)
                    }
                }
            }
            callback(tickets)
        }
        
        // create a ref to the tickets store
        let ref = FIRDatabase.database().reference().child("tickets")
        
        // observe the tickets store
        if (lastUpdateDate != nil){
            let fbQuery =
                ref.queryOrdered(byChild:"lastUpdateDate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(FIRDataEventType.value, with: handler)
        }else{
            ref.observe(FIRDataEventType.value, with: handler)
        }
    }
    
    func saveImageToFirebase(image:UIImage, name:(String), callback:@escaping (String?)->Void){
        let filesRef = storageRef.child(name)

        if let data = UIImageJPEGRepresentation(image, 0.8) {
            filesRef.put(data, metadata: nil) { metadata, error in
                if (error != nil) {
                    callback(nil)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    callback(downloadURL?.absoluteString)
                }
            }
        }
    }
    
    func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = FIRStorage.storage().reference(forURL: url)
        
        ref.data(withMaxSize: 10000000, completion: {(data, error) in
            if (error == nil && data != nil){
                let image = UIImage(data: data!)
                callback(image)
            }else{
                callback(nil)
            }
        })
    }}



