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
        
        return contactsRef
    }
    
    var managedObjectContext: NSManagedObjectContext
    
    var contactValueChangedEventHandle: FirebaseHandle?
    
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        firebaseRoot.authUser("zxlee618@gmail.com", password: "10Zhexian01") { (error, authData) in}
    }
    
    
    func observeContactsEvents() {
        // Remove any existing observer
        stopObservingContactsEvents()
        
        contactValueChangedEventHandle = contactsRef?.observeEventType(.Value, withBlock: { (contactsSnapshot: FDataSnapshot!) in
            self.didFirebaseContactsValueChange(contactsSnapshot)
        })
    }
    
    
    func stopObservingContactsEvents() {
        guard
            let contactValueChangedEventHandle = contactValueChangedEventHandle
            else {
                return
        }
        contactsRef?.removeObserverWithHandle(contactValueChangedEventHandle)
    }
    
    
    func didFirebaseContactsValueChange(contactsSnapshot: FDataSnapshot) {
        guard
            let contactsSnapshotValues = contactsSnapshot.value as? [String: AnyObject]
            else {
                return
        }
        
        let currentContactsUserId = [String](contactsSnapshotValues.keys)
        
        do {
            // Remove the contacts no longer exist
            let fetchRemovedContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchRemovedContactRequest.predicate = NSPredicate(format: "NOT (userId IN %@)", currentContactsUserId)
            
            guard
                let removedContacts = try managedObjectContext.executeFetchRequest(fetchRemovedContactRequest) as? [Contact]
                else {
                    return
            }
            
            for removedContact in removedContacts {
                managedObjectContext.deleteObject(removedContact)
            }
            
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
        
        // Update the user info of the current contacts
        for contactSnapshotValue in contactsSnapshotValues {
            let contactUserId = contactSnapshotValue.0
            let contactUserRef = usersRef?.childByAppendingPath(contactUserId)
            
            contactUserRef?.observeSingleEventOfType(.Value, withBlock: { (userSnapshot: FDataSnapshot!) in
                self.didFirebaseContactUserInfoChange(userSnapshot)
            })
        }
    }
    
    
    func didFirebaseContactUserInfoChange(userSnapshot: FDataSnapshot) {
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
    
    
    
    
    func removeContact(contactId: String) {
        
    }
    
    func confirmContact(contactId: String) {
        
    }
}