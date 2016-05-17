//
//  SecondViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UITableViewController {

    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let coreDataContext = appDelegate.managedObjectContext
           
//            if let contact = NSEntityDescription.insertNewObjectForEntityForName(String(Contact), inManagedObjectContext: coreDataContext) as? Contact {
//                contact.firstName = "Adam"
//                contact.lastName = "Evans"
//                contact.userId = "ae86"
//            }
//            do {
//                try coreDataContext.save()
//            }
//            catch {
//                print(error)
//            }
            
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            do {
                if let contacts = try coreDataContext.executeFetchRequest(fetchContactRequest) as? [Contact] {
                    self.contacts = contacts
                }
            }
            catch {
                print(error)
            }
        }
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactListTableViewCell)) as? ContactListTableViewCell else {
                print("Failed to dequeue \(String(ContactListTableViewCell))")
                return UITableViewCell()
            }
            
            cell.contactNameLabel.text = "\(contacts[indexPath.row].firstName!) \(contacts[indexPath.row].lastName!)"
            cell.contactUserIdLabel.text = "@\(contacts[indexPath.row].userId!)"
            
            return cell
        default:
            return UITableViewCell()
        }
    }


}

