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
    
    let firebaseRoot = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
    
    var managedObjectContext: NSManagedObjectContext
    
    var contactAddedEventHandle: FirebaseHandle?
    var contactChangedEventHandle: FirebaseHandle?
    var contactDeletedEventHandle: FirebaseHandle?
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    }
    
//    
//    func observeContactAddedEventWith(contactsRef: Firebase) {
//        contactAddedEventHandle = contactsRef.observeEventType(.ChildAdded, withBlock: { (contactsSnapshot: FDataSnapshot!) in
//            guar
//        })
//    }
//    
//    
//    func observeContactChangedEvent() {
//        
//    }
//    
//    
//    func observeContactDeletedEvent() {
//        
//    }
//    
//    
    func syncContacts() {
        guard
            let authData = firebaseRoot.authData
            else {
                print("No logged in user")
                return
        }
        
        let contactsRef = firebaseRoot.childByAppendingPath("contacts")
            .childByAppendingPath(authData.uid)
        
        contactsRef.childByAppendingPath("added")
            .observeEventType(.Value) { (contactsSnapshot: FDataSnapshot!) in
                
                guard
                    let contactsSnapshotValue = contactsSnapshot.value as? [String:AnyObject]
                    else {
                        return
                }
                
                // Clean up the database before syncing
                do {
                    let fetchExistingContactsRequest = NSFetchRequest(entityName: String(Contact))
                    
                    guard
                        let existingContacts = try self.managedObjectContext.executeFetchRequest(fetchExistingContactsRequest) as? [Contact]
                        else {
                            return
                    }
                    
                    for contact in existingContacts {
                        self.managedObjectContext.deleteObject(contact)
                    }
                    try self.managedObjectContext.save()
                }
                catch {
                    print(error)
                }
                
                // Get the user's profile of all the contacts from firebase
                for contactSnapshotValue in contactsSnapshotValue {
                    self.firebaseRoot.childByAppendingPath("users")
                        .childByAppendingPath(contactSnapshotValue.0)
                        .observeSingleEventOfType(.Value, withBlock: { (usersSnapshot) in
                            
                            guard
                                let usersSnapshotValue = usersSnapshot.value as? [String: AnyObject]
                                else {
                                    return
                            }
                            
                            do {
                                let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
                                fetchContactRequest.predicate = NSPredicate(format: "userId = %@", contactSnapshotValue.0)
                                
                                guard
                                    let contacts = try self.managedObjectContext.executeFetchRequest(fetchContactRequest) as? [Contact],
                                    let firstName = usersSnapshotValue["firstName"] as? String,
                                    let lastName = usersSnapshotValue["lastName"] as? String,
                                    let email = usersSnapshotValue["email"] as? String
                                    else {
                                        return
                                }
                                
                                if contacts.count == 1 {
                                    contacts[0].firstName = firstName
                                    contacts[0].lastName = lastName
                                    contacts[0].userId = contactSnapshotValue.0
                                }
                                else {
                                    guard
                                        let newContact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: self.managedObjectContext) as? Contact
                                        else {
                                            return
                                    }
                                    
                                    newContact.firstName = firstName
                                    newContact.lastName = lastName
                                    newContact.userId = contactSnapshotValue.0
                                }
                                
                                try self.managedObjectContext.save()
                                
                            }
                            catch {
                                print(error)
                            }
                        })
                }
        }
    }
    
}