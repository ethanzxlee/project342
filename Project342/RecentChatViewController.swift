//
//  FirstViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class RecentChatViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let context = appDelegate.managedObjectContext
            if let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as? Contact {
                contact.name = "Test \(NSDate())"
                // Try to save
                do {
                    try context.save()
                }
                catch {
                    
                }
                
                // Try to fetch
                let fetchRequest = NSFetchRequest(entityName: "Contact")
                do {
                    if let fetchedContacts = try context.executeFetchRequest(fetchRequest) as? [Contact] {
                        for fetchedContact in fetchedContacts {
                            print(fetchedContact.name)
                        }
                    }
                }
                catch {
                    
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

