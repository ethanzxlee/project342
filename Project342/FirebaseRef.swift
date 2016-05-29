//
//  FirebaseRef.swift
//  Project342
//
//  Created by Zhe Xian Lee on 28/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Firebase

/// All the Firebase References
struct FirebaseRef {
    
    /** Points to the node that contains all the users' info */
    static var usersInfoRef: FIRDatabaseReference? {
        return FIRDatabase.database().reference().child("users")
    }
    
    /** Points to the node that contains all the users' contacts */
    static var contactsRef: FIRDatabaseReference? {
        return FIRDatabase.database().reference().child("contacts")
    }
    
    /** Points to the node that contains the logged in user's contacts */
    static var userContactsRef: FIRDatabaseReference? {
        guard
            let currentUser = FIRAuth.auth()?.currentUser
            else {
                print("No logged in user")
                return nil
        }
        
        let userContactsRef = contactsRef?.child(currentUser.uid)
        return userContactsRef
    }
    
    /** Points to the node that stores all the searches */
    static var searchRef: FIRDatabaseReference? {
        return FIRDatabase.database().reference().child("search")
    }
    
    /** Points to the node where search request is to be made to ElasticSearch  */
    static var searchRequestRef: FIRDatabaseReference? {
        return searchRef?.child("request")
    }
    
    /** Points to the node where ElasticSearch returns the search response */
    static var searchResponseRef: FIRDatabaseReference? {
        return searchRef?.child("response")
    }
    
}

struct StorageRef {
    
    static var profilePicRef: FIRStorageReference {
        return FIRStorage.storage().reference().child("ProfilePic")
    }
    
}