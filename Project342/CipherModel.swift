//
//  CipherModel.swift
//  Project342
//
//  Created by Zhe Xian Lee on 19/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class CipherModel {
    
    static var sharedModel = CipherModel()
    
    let firebaseRoot = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
    
    var usersRef: Firebase? {
        return firebaseRoot.childByAppendingPath("users")
    }
    
    var contactsRef: Firebase? {
        guard
            let authData = firebaseRoot.authData
            else {
                print("No logged in user")
                return nil
        }
        
        let contactsRef = firebaseRoot.childByAppendingPath("contacts")
            .childByAppendingPath(authData.uid)
            .childByAppendingPath("added")
        contactsRef.keepSynced(true)
        
        return contactsRef
    }
    
    var managedObjectContext: NSManagedObjectContext
    
    var contactAddedEventHandle: FirebaseHandle?
    var contactChangedEventHandle: FirebaseHandle?
    var contactRemovedEventHandle: FirebaseHandle?
    
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        firebaseRoot.authUser("zxlee618@gmail.com", password: "10Zhexian01") { (error, authData) in}
    }
    
    
    func observeContactsEvents() {
        if let handle = contactAddedEventHandle {
            contactsRef?.removeObserverWithHandle(handle)
        }
        if let handle = contactChangedEventHandle {
            contactsRef?.removeObserverWithHandle(handle)
        }
        if let handle = contactRemovedEventHandle {
            contactsRef?.removeObserverWithHandle(handle)
        }
        
        contactAddedEventHandle = contactsRef?.observeEventType(.ChildAdded, withBlock: { (contactSnapshot: FDataSnapshot!) -> Void in
            self.didFirebaseUpdateContactEntry(contactSnapshot)
        })
        contactChangedEventHandle = contactsRef?.observeEventType(.ChildChanged, withBlock: { (contactSnapshot: FDataSnapshot!) -> Void in
            self.didFirebaseUpdateContactEntry(contactSnapshot)
        })
        contactRemovedEventHandle = contactsRef?.observeEventType(.ChildRemoved, withBlock: { (contactSnapshot: FDataSnapshot!) -> Void in
            self.didFirebaseRemoveContactEntry(contactSnapshot)
        })
    
    }
    
    
    func didFirebaseUpdateContactEntry(contactSnapshot: FDataSnapshot) {
        let contactUserId = contactSnapshot.key
        let contactUserRef = usersRef?.childByAppendingPath(contactUserId)
        
        contactUserRef?.observeSingleEventOfType(.Value, withBlock: { (userSnapshot: FDataSnapshot!) in
            self.didFirebaseUpdateContactUserInfo(userSnapshot)
        })
    }

        
    func didFirebaseUpdateContactUserInfo(userSnapshot: FDataSnapshot) {
        do {
            guard
                let userSnapshotValue = userSnapshot.value as? [String: AnyObject]
                else {
                    return
            }
            
            // Try to find if the contact exists in our database
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.predicate = NSPredicate(format: "userId = %@", userSnapshot.key)
            
            guard
                let existingContact = try self.managedObjectContext.executeFetchRequest(fetchContactRequest) as? [Contact],
                let firstName = userSnapshotValue["firstName"] as? String,
                let lastName = userSnapshotValue["lastName"] as? String,
                let email = userSnapshotValue["email"] as? String
                else {
                    return
            }
            
            var contact: Contact?
            
            if existingContact.count == 1 {
                // If the Contact exist
                contact = existingContact[0]
            }
            else {
                // Otherwise create a Contact
                contact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: self.managedObjectContext) as? Contact
            }
            
            // Assigning values to the Contact
            contact?.firstName = firstName
            contact?.lastName = lastName
            contact?.userId = userSnapshot.key
            
            // Try to save the Contact
            try self.managedObjectContext.save()
        }
        catch {
            print(error)
        }

    }

    
    func didFirebaseRemoveContactEntry(contactSnapshot: FDataSnapshot) {
        let contactUserId = contactSnapshot.key
        do {
            // Try to find if the contact exists in our database
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.predicate = NSPredicate(format: "userId = %@", contactUserId)
            
            guard
                let existingContact = try managedObjectContext.executeFetchRequest(fetchContactRequest) as? [Contact]
                else {
                    return
            }
            
            // Delete the contact if it is found
            if existingContact.count == 1 {
                managedObjectContext.deleteObject(existingContact[0])
            }
            
            // Try to save the Contact
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
    
    
    func removeContact(contactId: String) {
        
    }
    
    func confirmContact(contactId: String) {
        
    }
}