//
//  ContactUserInfoObserver.swift
//  Project342
//
//  Created by Zhe Xian Lee on 29/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Firebase
import CoreData


/// A singleton class that responsible to observe the contact's user information, such as
/// first name, last name etc. Then, sync the changes to CoreData
class ContactUserObserver {
    
    static let observer = ContactUserObserver()
    
    let managedObjectContext: NSManagedObjectContext
    
    var handles: [String: FIRDatabaseHandle]
    
    
    private init() {
        handles = [String: FIRDatabaseHandle]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    
    func observeContactUserInfoForContactId(contactId: String) {
        if handles.indexForKey(contactId) == nil {
            let ref = FirebaseRef.usersInfoRef?.child(contactId)
            handles[contactId] = ref?.observeEventType(.Value, withBlock: { (userSnapshot) in
                self.didFirebaseContactUserInfoChange(userSnapshot)
            })
        }
    }
    
    
    func stopObservingContactUserInfoForContact(contactId: String) {
        guard
            let handle = handles[contactId]
            else {
                return
        }
        
        FirebaseRef.usersInfoRef?.child(contactId).removeObserverWithHandle(handle)
    }
    
    
    func stopObservingAllContactUserInfo() {
        for handle in handles {
            FirebaseRef.usersInfoRef?.child(handle.0).removeObserverWithHandle(handle.1)
        }
    }
    
    
    private func didFirebaseContactUserInfoChange(userSnapshot: FIRDataSnapshot) {
        do {
            guard
                let userSnapshotValue = userSnapshot.value as? [String: AnyObject]
                else {
                    return
            }

            // Fetch the contact
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.predicate = NSPredicate(format: "userId = %@", userSnapshot.key)

            // Make sure we have all the data needed
            guard
                let contact = (try managedObjectContext.executeFetchRequest(fetchContactRequest) as? [Contact])?.first,
                let firstName = userSnapshotValue["firstName"] as? String,
                let lastName = userSnapshotValue["lastName"] as? String
                else {
                    return
            }
            
            // Otherwise update the contact user info
            contact.firstName = firstName
            contact.lastName = lastName
            contact.userId = userSnapshot.key
            contact.profilePicStatus = "downloading"

            // Transform the names into latin characters to make sorting easier
            let sectionTitleFirstName = NSMutableString(UTF8String: firstName)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformToLatin, false)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformStripCombiningMarks, false)
            CFStringTransform(sectionTitleFirstName, nil, kCFStringTransformToUnicodeName, false)
            contact.sectionTitleFirstName = sectionTitleFirstName?.substringToIndex(1).uppercaseString
            
            let sectionTitleLastName = NSMutableString(UTF8String: firstName)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformToLatin, false)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformStripCombiningMarks, false)
            CFStringTransform(sectionTitleLastName, nil, kCFStringTransformToUnicodeName, false)
            contact.sectionTitleLastName = sectionTitleLastName?.substringToIndex(1).uppercaseString
            
            // Try to save the Contact
            try self.managedObjectContext.save()
            
            let profilePicRef = StorageRef.profilePicRef.child(userSnapshot.key)
            
            guard
                let profilePicDirectory = Directories.profilePicDirectory?.URLByAppendingPathComponent(userSnapshot.key)
                else {
                    return
            }
            
            let downloadTask = profilePicRef.writeToFile(profilePicDirectory)
            downloadTask.observeStatus(.Success, handler: { (profilePicSnapshot) in
                contact.profilePicStatus = "success"
                do {
                    try self.managedObjectContext.save()
                }
                catch {
                    print(error)
                }
            })

        }
        catch {
            print(error)
        }
        
    }

}