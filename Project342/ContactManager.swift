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

import Foundation
import CoreData
import Firebase

class ContactManager {
    
    static var sharedManager = ContactManager()
    var managedObjectContext: NSManagedObjectContext
    
    // MARK: Firebase ref
    
    var firebaseRoot = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
    
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
        
        return contactsRef
    }
    
    // Firebase event handles
    
    var contactValueChangedEventHandle: FirebaseHandle?
    var contactUserInfoValueChangedHandles: [String: FirebaseHandle]
    
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
    
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        contactUserInfoValueChangedHandles = [String: FirebaseHandle]()
        firebaseRoot.authUser("zxlee618@gmail.com", password: "10Zhexian01") { (error, authData) in}
    }
    
    
    // MARK: - Contact
    
    func observeContactsEvents() {
        // Remove any existing observer
        stopObservingContactsEvents()
        
        contactValueChangedEventHandle = contactsRef?.observeEventType(.Value, withBlock: { (contactsSnapshot) in
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
        
        for handle in contactUserInfoValueChangedHandles {
            usersRef?.childByAppendingPath(handle.0).removeObserverWithHandle(handle.1)
        }
    }
    
    
    func didFirebaseContactsValueChange(contactsSnapshot: FDataSnapshot) {
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
            let contactUserRef = usersRef?.childByAppendingPath(contactUserId)
            
           
            let contactUserInfoEventHandle = contactUserRef?.observeEventType(.Value, withBlock: { (userSnapshot) in
                self.didFirebaseContactUserInfoChange(userSnapshot, status: contactSnapshotValue.1)
            })
            
            if contactUserInfoEventHandle != nil {
                contactUserInfoValueChangedHandles[contactUserId] = contactUserInfoEventHandle
            }
        }
    }
    
    
    func didFirebaseContactUserInfoChange(userSnapshot: FDataSnapshot, status: String) {
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
            
            guard
                let createdAt = NSDateFormatter.dateFromISO8601String(createdAtString),
                let updatedAt = NSDateFormatter.dateFromISO8601String(updatedAtString)
                else {
                    return
            }
            
            var contact: Contact?
            
            // If the Contact exist
            if existingContact.count == 1 {
                contact = existingContact[0]
                
                // If the contact is already up-to-date
                print("\(firstName)   \(contact?.updatedAt) __ \(updatedAtString)")
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
        contactsRef?.childByAppendingPath(contactId).removeValue()
    }
    
    
    func acceptContactRequest(contactId: String) {
        contactsRef?.childByAppendingPath(contactId).setValue(ContactStatus.Added.rawValue)
    }
    
}
