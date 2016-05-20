//
//  AddContactsViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class AddContactsViewController: UITableViewController {
    
  //  var searchController = UISearchController(searchResultsController: nil)
   
    var contactCount = 0
    var loadedContactCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//       // self.tableView.tableHeaderView = self.searchController.searchBar
//        let ref = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
//        
////        ref.observeAuthEventWithBlock { (authData) in
////            if let authData = authData {
////                print(authData)
////            }
////        }
//        
////        
//        
//        // Delete all the existing contact
//        guard
//            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
//        else {
//            return
//        }
//        
//        let managedObjectContext = appDelegate.managedObjectContext
//        
//        let fetchRequest = NSFetchRequest(entityName: String(Contact))
//        
//        do {
//            guard let contacts = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact] else {
//                return
//            }
//            
//            for contact in contacts {
//                managedObjectContext.deleteObject(contact)
//            }
//            
//            try managedObjectContext.save()
//        }
//        catch {
//            print(error)
//        }
//        
//        let contactRef = ref.childByAppendingPath("contacts")
//        let myContactRef = contactRef.childByAppendingPath(ref.authData.uid)
//
//        // Prepare data
//        let myContacts = ["added":["f074d315-1f40-4bcf-aefe-50fc89790e04":true, "405c1f50-fae1-422d-9383-c9c4c426e65b":true], // apple already accepts
//            "blocked": ["e87c26ce-02df-47cc-87de-a129eb9808a6":true],
//            "request": ["316504bc-8d74-429b-aa56-9eb8b98735f1":true]] // abc2   // request receive from abc2
//        
//        myContactRef.setValue(myContacts)
//        
//        // Get all the added contacts
//        myContactRef.childByAppendingPath("added")
//            .observeEventType(.Value) { (dataSnapshot: FDataSnapshot!) in
//            
//                if let contacts = dataSnapshot.value as? NSDictionary {
//                    
//                    do {
//                        guard let contacts = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact] else {
//                            return
//                        }
//                        
//                        for contact in contacts {
//                            managedObjectContext.deleteObject(contact)
//                        }
//                        
//                        try managedObjectContext.save()
//                    }
//                    catch {
//                        print(error)
//                    }
//                    
//                    // Get information of the contacts
//                    for contactSnapshot in contacts {
//                        
//                        ref.childByAppendingPath("users")
//                            .childByAppendingPath(String(contactSnapshot.key))
//                            .observeSingleEventOfType(.Value, withBlock: { (dataSnapshot: FDataSnapshot!) in
//                                guard
//                                    let firstName = dataSnapshot.value.objectForKey("firstName") as? String,
//                                    let lastName = dataSnapshot.value.objectForKey("lastName") as? String,
//                                    let email = dataSnapshot.value.objectForKey("email") as? String
//                                else {
//                                    return
//                                }
//                                
//                                let userId = dataSnapshot.key as String
//                                let fetchRequest = NSFetchRequest(entityName: String(Contact))
//                                fetchRequest.predicate = NSPredicate(format: "userId = %@", userId)
//                                
//                                do {
//                                    if let existingRecords = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact] {
//                                        for existingRecord in existingRecords {
//                                            managedObjectContext.deleteObject(existingRecord)
//                                        }
//                                    }
//                                }
//                                catch {
//                                    print(error)
//                                }
//                                
//                                if let contact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: managedObjectContext) as? Contact {
//                                    contact.firstName = firstName
//                                    contact.lastName = lastName
//                                    contact.userId = userId
//                                }
//                                print(firstName)
//                                do {
//                                    try managedObjectContext.save()
//                                }
//                                catch {
//                                    print(error)
//                                }
//                        })
//                    }
//                }
//        
//        }
//        
        
//        ref.authUser("zxlee618@gmail.com", password: "10Zhexian01") { (error, authData) in
//            guard let authData = authData where error == nil else {
//                print(error)
//                return
//            }
//            let user = ["provider" : "password", "email": "abc@example.com", "firstName" : "AB", "lastName": "C", "profilePic" : "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"]
//            ref.childByAppendingPath("users").childByAppendingPath("405c1f50-fae1-422d-9383-c9c4c426e65b").setValue(user);
//        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
