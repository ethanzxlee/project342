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
    
    // MARK: Firebase event handles
    
    var contactValueChangedEventHandle: FIRDatabaseHandle?
    
    
    private init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // TODO: Remove this one the login VC is done
        FIRAuth.auth()?.signInWithEmail("zxlee618@gmail.com", password: "10Zhexian01", completion: nil)
    }
    
    
    func deleteContact(contactId: String) {
        FirebaseRef.userContactsRef?.child(contactId).removeValue()
    }
    
    
    func acceptContactRequest(contactId: String) {
        guard
            let userId = FIRAuth.auth()?.currentUser?.uid
            else {
                return
        }
        
        FirebaseRef.contactsRef?.child(contactId).child(userId).setValue(ContactStatus.Added.rawValue)
        FirebaseRef.userContactsRef?.child(contactId).setValue(ContactStatus.Added.rawValue)
    }
    
    
    func addContact(contactId: String) {
        guard
            let userId = FIRAuth.auth()?.currentUser?.uid
            else {
                return
        }
        
        FirebaseRef.contactsRef?.child(contactId).child(userId).setValue(ContactStatus.Request.rawValue)
        FirebaseRef.userContactsRef?.child(contactId).setValue(ContactStatus.Pending.rawValue)
    }
    
    
    func observeContactsEvents() {
        // Remove any existing observer
        stopObservingContactsEvents()
        
        contactValueChangedEventHandle = FirebaseRef.userContactsRef?.observeEventType(.Value, withBlock: { (contactsSnapshot) in
            self.didFirebaseContactsValueChange(contactsSnapshot)
        })
    }
    
    
    func stopObservingContactsEvents() {
        guard
            let contactValueChangedEventHandle = contactValueChangedEventHandle
            else {
                return
        }
        FirebaseRef.userContactsRef?.removeObserverWithHandle(contactValueChangedEventHandle)
    }
    
    
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
                // Remove the contact from core data
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
