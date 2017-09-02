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
    var currAuthUser: User? = nil;
    var bIsFromFacebook: Bool = false;
    
    init(){
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
    }
    
    lazy var storageRef = FIRStorage.storage().reference(forURL: "gs://ticketshare-5ca22.appspot.com/")

    func getCurrentAuthUserName() -> String? {
        return self.currAuthUser?.fullName
    }
    
    func getCurrentAuthUserEmail() -> String? {
        return self.currAuthUser?.email
    }
    
    func isLoginFromFacebook() -> Bool {
        return self.bIsFromFacebook
    }
    
    func getCurrentAuthUserUID() -> String? {
        return self.currAuthUser?.uid
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            self.currAuthUser = nil
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    func editUser(name: String, email: String, completionBlock:@escaping (Error?)->Void){
        FIRAuth.auth()?.currentUser?.updateEmail(email) { error in
            if (error != nil) {
                completionBlock(error)
            } else {
                FIRDatabase.database().reference().child("users")
                    .child((FIRAuth.auth()?.currentUser?.uid)!).child("email").setValue(email)
                FIRDatabase.database().reference().child("users")
                    .child((FIRAuth.auth()?.currentUser?.uid)!).child("fullName").setValue(name)
                self.currAuthUser?.email = email
                self.currAuthUser?.fullName = name
                completionBlock(nil)
            }
        }
    }
    
    func addUser(user:User, completionBlock:@escaping (Error?)->Void){
        FIRAuth.auth()?.createUser(withEmail: user.email, password: user.password) { (authUser, error) in
            
            if error == nil {
                user.uid = (authUser?.uid)!
                
                let ref = FIRDatabase.database().reference().child("users").child(user.uid)
                
                ref.setValue(user.toFireBase()){(error, dbref) in
                    if error == nil {
                        dbref.observeSingleEvent(of: .value, with: {(snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let user = User(json: value as! Dictionary<String, Any>)
                            self.currAuthUser = user
                        })
                        
                        FIRAuth.auth()!.signIn(withEmail: user.email, password: user.password) { (loggedInUser, error) in
                            completionBlock(error)
                            /*if error == nil {
                                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                                changeRequest?.displayName = user.fullName
                                changeRequest?.commitChanges() {(err) in
                                    if err == nil {
                                        self.getUserFromFirebaseDB(uid: (loggedInUser?.uid)!, callback: { (error, user) in
                                            if (error != nil) {
                                                completionBlock(error)
                                            } else if (user != nil){
                                                self.currAuthUser = user
                                            }
                                        })
                                    }
                                    completionBlock(err)
                                }
                            } else {
                                completionBlock(error)
                            }*/
                        }
                    } else {
                        completionBlock(error)
                    }
                }
            } else {
                completionBlock(error)
            }
        }
        
        
    }
    
    func loginFromFB(accessToken: String, email: String, name: String, completionBlock:@escaping (Any?)->Void) {
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credentials) { (authUser, error) in
            if error == nil {
                self.currAuthUser = User(email: email, password: "aaa", fullName: name, dateOfBirth: Date(), location: nil, uid:(authUser?.uid)!)
                self.bIsFromFacebook = true;
                let ref = FIRDatabase.database().reference().child("users").child((self.currAuthUser?.uid)!)
                ref.setValue(self.currAuthUser?.toFireBase()){(error, dbref) in
                    completionBlock(error)
                }
            } else {
                completionBlock(error)
            }
        }
    }
    
    func getUserFromFirebaseDB(uid:String, callback:@escaping (Error?, User?) -> Void){
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if (value != nil) {
                let user = User(json: value as! Dictionary<String, Any>)
                callback(nil, user)
            } else {
                callback(nil, nil)
            }
        }) { (error) in
            callback(error, nil)
        }
    }
    
    func getTicketFromFirebaseDB(uid:String, callback:@escaping (Error?, Ticket?) -> Void){
        let ref = FIRDatabase.database().reference().child("tickets").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get ticket value
            let value = snapshot.value as? NSDictionary
            if (value != nil) {
                value?.setValue(uid, forKey: "id")
                let ticket = Ticket(json: value as! Dictionary<String, Any>)
                callback(nil, ticket)
            } else {
                callback(nil, nil)
            }
        }) { (error) in
            callback(error, nil)
        }
    }
    
    func loginUser(email:String, password:String, completionBlock:@escaping (Any?)->Void) {
        FIRAuth.auth()!.signIn(withEmail: email, password: password) {(userAuth, error) in
            if error == nil {
                self.getUserFromFirebaseDB(uid: (userAuth?.uid)!, callback: { (error, user) in
                    if (error != nil) {
                        completionBlock(error)
                    } else if (user != nil){
                        self.currAuthUser = user
                        completionBlock(nil)
                    } else {
                        completionBlock("No user was found")
                    }
                })
                
            } else {
                completionBlock(error)
            }
        }
    }
    
    func addTicket(tick:Ticket, completionBlock:@escaping (Error?)->Void){
        let ref = FIRDatabase.database().reference().child("tickets").childByAutoId()
        
        // set the new ticket's data on the record ref
        ref.setValue(tick.toFireBase()){(error, dbref) in
            completionBlock(error)
        }
    }
    
    func editTicket(ticket: Ticket, completionBlock:@escaping (Error?)->Void) {
        let ref = FIRDatabase.database().reference().child("tickets").child(ticket.id)
        
        // set the new ticket's data on the record ref
        ref.setValue(ticket.toFireBase()) {(err, dbref) in
            completionBlock(err)
        }
    }
    
    func addPurchase(purchase:Purchase, completionBlock:@escaping (Error?)->Void){
        let ref = FIRDatabase.database().reference().child("purchases").childByAutoId()
        
        ref.setValue(purchase.toFirebase()) {(error, dbref) in
            completionBlock(error)
        }
    }
    
    func buyTicket(ticket:Ticket, completionBlock:@escaping (Error?)->Void) {
        let ref = FIRDatabase.database().reference().child("tickets").child(ticket.id)
        
        ref.updateChildValues(["isSold": true, "lastUpdateDate": Date().toFirebase()]){(error, dbref) in
            completionBlock(error)
        }
    }
    
    func saveUserPreferences(preferences:[PreferencesOption], callback:@escaping (Error?) -> Void) {
        let ref = FIRDatabase.database().reference().child("usersPreferences").child(self.getCurrentAuthUserUID()!)
        
        var prefsDictionary:Dictionary<String, Int> = [:]
        
        for prefOpt in preferences {
            prefsDictionary[prefOpt.value] = prefOpt.id
        }
        
        ref.setValue(prefsDictionary) {(error, dbref) in
            callback(error)
        }
    }
    
    func saveFavoriteTicketForUser(favTicket:Ticket, callback:@escaping (Error?) -> Void) {
        let ref = FIRDatabase.database().reference().child("usersFavorites").child(self.getCurrentAuthUserUID()!).child(favTicket.id)
        
        ref.setValue(favTicket.toFireBase()){(error, dbref) in
            callback(error)
        }
    }
    
    func removeFavoriteTicketForUser(ticketId:String, callback:@escaping (Error?) -> Void) {
        let ref = FIRDatabase.database().reference().child("usersFavorites").child(self.getCurrentAuthUserUID()!).child(ticketId)
        
        ref.removeValue() { (error, ref) in
            callback(error)
        }
    }
    
    func getUserFavoriteTickets(userId:String?, callback:@escaping ([Ticket]) -> Void) {
        let userid = userId ?? self.getCurrentAuthUserUID()!
        let ref = FIRDatabase.database().reference().child("usersFavorites").child(userid)
        
        ref.observe(FIRDataEventType.value, with: { snapshot in
            var tickets = [Ticket]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    if var json = childData.value as? Dictionary<String,Any>{
                        json["id"] = childData.key
                        let tick = Ticket(json: json)
                        tickets.append(tick)
                    }
                }
            }
            
            callback(tickets)
        })
    }
    
    func getUserPreferences(callback: @escaping ([PreferencesOption]) -> Void) {
        let ref = FIRDatabase.database().reference().child("usersPreferences").child(self.getCurrentAuthUserUID()!)
        
        ref.observe(FIRDataEventType.value, with: { snapshot in
            var userPrefs = [PreferencesOption]()
            
            for child in snapshot.children.allObjects {
                if let childData = child as? FIRDataSnapshot {
                    let preferencesOption = PreferencesOption(id: childData.value as! Int, value: childData.key )
                    userPrefs.append(preferencesOption)
                }
            }
            
            callback(userPrefs)
        })
    }
    
    func getRecommendedTicketsForUser(userId:String, callback:@escaping ([String]) -> Void) {
        let handler = {(snapshot:FIRDataSnapshot) in
            var ticketsIds = [String]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    ticketsIds.append((childData.value as? String)!)
                }
            }
            
            callback(ticketsIds)
        }
        
        let recommendationsRef = FIRDatabase.database().reference().child("recommendations")
        
        recommendationsRef.child(userId).observe(FIRDataEventType.value, with: handler)
    }
    
    func getCurrentUserPurchases(_ lastUpdateDate:Date?, callback:@escaping ([Purchase]) -> Void) {
        let handler = {(snapshot:FIRDataSnapshot) in
            var purchases = [Purchase]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    if var json = childData.value as? Dictionary<String,Any>{
                        json["id"] = childData.key
                        let purch = Purchase(json: json)
                        
                        if (purch.seller == self.getCurrentAuthUserUID() || purch.buyer == self.getCurrentAuthUserUID()) {
                            purchases.append(purch)
                        }
                    }
                }
            }
            
            callback(purchases)
        }
        
        // create a ref to the tickets store
        let ref = FIRDatabase.database().reference().child("purchases")
        
        // observe the tickets store
        if (lastUpdateDate != nil){
            let fbQuery = ref.queryOrdered(byChild:"purchaseDate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(FIRDataEventType.value, with: handler)
        }else{
            ref.observe(FIRDataEventType.value, with: handler)
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
                    if var json = childData.value as? Dictionary<String,Any>{
                        json["id"] = childData.key
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
    
    func getPreferencesOptions(callback:@escaping ([PreferencesOption]) -> Void) {
        let ref = FIRDatabase.database().reference().child("preferencesOptions")
        
        ref.observe(FIRDataEventType.value, with: {(snapshot) in
            var preferencesOptions = [PreferencesOption]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let preferencesOption = PreferencesOption(json: json)
                        preferencesOptions.append(preferencesOption)
                    }
                }
            }
            
            callback(preferencesOptions)
        })
    }
    
    func getEventTypes(callback:@escaping ([EventType])->Void) {
        let ref = FIRDatabase.database().reference().child("eventTypes")
        
        ref.observe(FIRDataEventType.value, with: {(snapshot) in
            var eventTypes = [EventType]()
            for child in snapshot.children.allObjects{
                if let childData = child as? FIRDataSnapshot{                    
                    if let json = childData.value as? Dictionary<String,Any>{                        
                        let eventType = EventType(json: json)
                        eventTypes.append(eventType)
                    }
                }
            }
            
            callback(eventTypes)
        })
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



