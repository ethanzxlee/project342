//
//  FirebaseRef.swift
//  Project342
//
//  Created by Zhe Xian Lee on 28/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Firebase

struct FirebaseRef {
    
    static var usersInfoRef: FIRDatabaseReference? {
        return FIRDatabase.database().reference().child("users")
    }
    
    static var contactsRef: FIRDatabaseReference? {
        guard
            let currentUser = FIRAuth.auth()?.currentUser
            else {
                print("No logged in user")
                return nil
        }
        
        let contactsRef = FIRDatabase.database().reference().child("contacts")
            .child(currentUser.uid)
        
        return contactsRef
    }
    
    static var searchRef: FIRDatabaseReference? {
        return FIRDatabase.database().reference().child("search")
    }
    
    static var searchRequestRef: FIRDatabaseReference? {
        return searchRef?.child("request")
    }
    
    static var searchResponseRef: FIRDatabaseReference? {
        return searchRef?.child("response")
    }
    
}
