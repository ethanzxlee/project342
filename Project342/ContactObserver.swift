//
//  CipherModel.swift
//  Project342
//
//  Created by Zhe Xian Lee on 19/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//
//  References:
//  http://nshipster.com/cfstringtransform/
//

import CoreData
import Firebase


/// This singleton class will observe the user's contacts in Firebase and then
/// synchronise the changes to CoreData. Besides, it handles the interactions
/// between the app and Firebase
class ContactObserver {
    
    static let observer = ContactObserver()
    
    let managedObjectContext: NSManagedObjectContext
    var contactValueChangedEventHandle: FIRDatabaseHandle?
    
    
    private init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    
    /**
        Delete a contact from the user's contact list. The current user will be removed from the specified
        contact's contact list too.
     
        - Parameters:
            contactId: The user ID of the contact to be deleted
     */
    func deleteContact(contactId: String) {
        FirebaseRef.userContactsRef?.child(contactId).removeValue()
    }
    
    
    /**
        Accept a contact request, so that they can start communicating
        
        - Parameters:
            contactId: The user ID of the contact to be accepted
    */
    func acceptContactRequest(contactId: String) {
        guard
            let userId = FIRAuth.auth()?.currentUser?.uid
            else {
                return
        }
        
        FirebaseRef.contactsRef?.child(contactId).child(userId).setValue(ContactStatus.Added.rawValue)
        FirebaseRef.userContactsRef?.child(contactId).setValue(ContactStatus.Added.rawValue)
    }
    
    
    /**
        Add the specified user ID as contact, however, the contact's status will still
        be pending until the user accepts the contact request.
     
        - Parameters:
            contactId: The user ID of the contact to be added
     */
    func addContact(contactId: String) {
        guard
            let userId = FIRAuth.auth()?.currentUser?.uid
            else {
                return
        }
        
        FirebaseRef.contactsRef?.child(contactId).child(userId).setValue(ContactStatus.Request.rawValue)
        FirebaseRef.userContactsRef?.child(contactId).setValue(ContactStatus.Pending.rawValue)
    }
    
    
    /**
        Observe the current user's contact list on Firebase. This would be called in AppDelegate where the 
        application becomes active.
     */
    func observeContactsEvents() {
        // Remove any existing observer
        stopObservingContactsEvents()
        
        contactValueChangedEventHandle = FirebaseRef.userContactsRef?.observeEventType(.Value, withBlock: { (contactsSnapshot) in
            self.didFirebaseContactsValueChange(contactsSnapshot)
        })
    }
    
    
    /**
        Stop observing the changes in the user's contact list on Firebase. This would be called in AppDelegate
        where the application goes into background or inactive
     */
    func stopObservingContactsEvents() {
        guard
            let contactValueChangedEventHandle = contactValueChangedEventHandle
            else {
                return
        }
        FirebaseRef.userContactsRef?.removeObserverWithHandle(contactValueChangedEventHandle)
    }
    
    
    /**
        This method would be called when there's a change in the user's contact list, regardless of
        addition or removal of a contact. Firebase will always give us the latest snapshot of the
        contact list.
     
        - Parameters:
            contactsSnapshot: The snapshot of the contacts that the user currently has
     */
    private func didFirebaseContactsValueChange(contactsSnapshot: FIRDataSnapshot) {
        guard
            let contactsSnapshotValues = contactsSnapshot.value as? [String: String]
            else {
                return
        }
        
        let currentContactsUserId = [String](contactsSnapshotValues.keys)
        
        // Remove the contacts no longer exist
        do {
            let fetchRemovedContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchRemovedContactRequest.predicate = NSPredicate(format: "NOT (userId IN %@)", currentContactsUserId)
            
            guard
                let removedContacts = try managedObjectContext.executeFetchRequest(fetchRemovedContactRequest) as? [Contact]
                else {
                    return
            }
            
            for removedContact in removedContacts {
                // Remove the contact from CoreData
                managedObjectContext.deleteObject(removedContact)
                
                // Remove their profile picture as well
                let profilePicFileURL = Directories.profilePicDirectory?.URLByAppendingPathComponent(removedContact.userId!)
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(profilePicFileURL!)
                }
                catch {
                    print(error)
                }
            }
            
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
        
        // Update the contacts and their statuses
        for contactSnapshotValue in contactsSnapshotValues {
            var contact: Contact?
            let contactUserId = contactSnapshotValue.0
            let contactStatus = contactSnapshotValue.1
            
            // Check if the contact exists
            let fetchRequest = NSFetchRequest(entityName: String(Contact))
            fetchRequest.predicate = NSPredicate(format: "userId = %@", contactUserId)
            
            do {
                contact = (try managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact])?.first
            }
            catch {
                print(error)
            }
            
            // Create a new contact in CoreData if it doesn't exists
            if contact == nil {
                contact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: managedObjectContext) as? Contact
            }
            
            // Update their statuses
            contact?.userId = contactUserId
            contact?.status = contactStatus
            
            // Save it
            do {
                try managedObjectContext.save()
            }
            catch {
                print(error)
            }
        }
    }
}
