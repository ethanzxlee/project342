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
    var contactUserInfoValueChangedHandles: [String: FIRDatabaseHandle]
    
    // MARK: Directory URLs
    
    var documentDirectory: NSURL? {
        do {
            return try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    var profilePicDirectory: NSURL? {
        let profilePicDirectory = documentDirectory?.URLByAppendingPathComponent("ProfilePic")
        if !NSFileManager.defaultManager().fileExistsAtPath(profilePicDirectory!.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(profilePicDirectory!, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print(error)
            }
        }
        return profilePicDirectory
    }
    
    
    private init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        contactUserInfoValueChangedHandles = [String: FIRDatabaseHandle]()
        FIRAuth.auth()?.signInWithEmail("zxlee618@gmail.com", password: "10Zhexian01", completion: nil)
    }
    
    
    // MARK: - Contact
    
    // TODO: Allow observe only contact, without contact's user info
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
        
        for handle in contactUserInfoValueChangedHandles {
            FirebaseRef.usersInfoRef?.child(handle.0).removeObserverWithHandle(handle.1)
        }
    }
    
    
    func didFirebaseContactsValueChange(contactsSnapshot: FIRDataSnapshot) {
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
                managedObjectContext.deleteObject(removedContact)
                
                // Remove their profile picture as well
                let profilePicFileURL = profilePicDirectory?.URLByAppendingPathComponent(removedContact.userId!)
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
        
        // Observe the user info of the current contacts
        for contactSnapshotValue in contactsSnapshotValues {
            let contactUserId = contactSnapshotValue.0
            let contactUserRef = FirebaseRef.usersInfoRef?.child(contactUserId)
            
           
            let contactUserInfoEventHandle = contactUserRef?.observeEventType(.Value, withBlock: { (userSnapshot) in
                self.didFirebaseContactUserInfoChange(userSnapshot, status: contactSnapshotValue.1)
            })
            
            if contactUserInfoEventHandle != nil {
                contactUserInfoValueChangedHandles[contactUserId] = contactUserInfoEventHandle
            }
        }
    }
    
    
    func didFirebaseContactUserInfoChange(userSnapshot: FIRDataSnapshot, status: String) {
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
                let existingContact = try managedObjectContext.executeFetchRequest(fetchContactRequest) as? [Contact],
                let firstName = userSnapshotValue["firstName"] as? String,
                let lastName = userSnapshotValue["lastName"] as? String,
                let profilePicBase64String = userSnapshotValue["profilePic"] as? String,
                let createdAtString = userSnapshotValue["createdAt"] as? String,
                let updatedAtString = userSnapshotValue["updatedAt"] as? String
                else {
                    return
            }
            
            let dateFormatter = NSDateFormatter.ISO8601DateFormatter()
            
            guard
                let createdAt = dateFormatter.dateFromString(createdAtString),
                let updatedAt = dateFormatter.dateFromString(updatedAtString)
                else {
                    return
            }
            
            var contact: Contact?
            
            // If the Contact exist
            if existingContact.count == 1 {
                contact = existingContact[0]
                
                // If the contact is already up-to-date
                if contact?.updatedAt?.timeIntervalSince1970 >= updatedAt.timeIntervalSince1970 && contact?.status == status {
                    return
                }
            }
            // Otherwise create a Contact
            else {
                contact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: self.managedObjectContext) as? Contact
            }
            
            // Assigning values to the Contact
            contact?.firstName = firstName
            contact?.lastName = lastName
            contact?.userId = userSnapshot.key
            contact?.updatedAt = updatedAt
            contact?.createdAt = createdAt
            contact?.status = status
            
            // Transform the names into latin to make sorting easier
            let sectionTitleFirstName = NSMutableString(UTF8String: firstName)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformToLatin, false)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformStripCombiningMarks, false)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformToUnicodeName, false)
            contact?.sectionTitleFirstName = sectionTitleFirstName?.substringToIndex(1).uppercaseString
            
            let sectionTitleLastName = NSMutableString(UTF8String: firstName)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformToLatin, false)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformStripCombiningMarks, false)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformToUnicodeName, false)
            contact?.sectionTitleLastName = sectionTitleLastName?.substringToIndex(1).uppercaseString
            
            // Try to save the Contact
            try self.managedObjectContext.save()
            
            // Try to save the image
            if
                let profilePicData = NSData(base64EncodedString: profilePicBase64String, options: NSDataBase64DecodingOptions(rawValue: 0)),
                let profilePicDirectory = profilePicDirectory {
                
                let profilePicFileURL = profilePicDirectory.URLByAppendingPathComponent(userSnapshot.key)
                
                do {
                    try profilePicData.writeToURL(profilePicFileURL, options: .DataWritingFileProtectionComplete)
                }
                catch {
                    print(error)
                }
                
            }
            
        }
        catch {
            print(error)
        }
        
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
    
}
