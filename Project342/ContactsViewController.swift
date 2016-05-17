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

    var contacts = [String: [Contact]]()
    
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
            
            // TODO: Will be moved into the AppModel
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            do {
                if var contacts = try coreDataContext.executeFetchRequest(fetchContactRequest) as? [Contact] {
                    // Sort all the contacts by their first name
                    // TODO: IDEA? this preference can be override in our app settings page
                    contacts = contacts.sort({ (a, b) -> Bool in
                        a.firstName!.localizedCompare(b.firstName!) == .OrderedAscending
                    })
                    
                    
                    // Regroup the contacts into a dictionary according to their first names' first character
                    for contact in contacts {
                        // Convert the first character so that the grouping is case-insensitive
                        let firstCharacter = String(contact.firstName![contact.firstName!.startIndex]).uppercaseString
                        
                        // Init the group if it doesn't exist
                        if (self.contacts[firstCharacter] == nil) {
                            self.contacts[firstCharacter] = [Contact]()
                        }
                        
                        // Append the contact into the group
                        self.contacts[firstCharacter]?.append(contact)
                    }
                    
                }
            }
            catch {
                print(error)
            }
        }
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.contacts.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keyFromIndex = self.contacts.sortedKeys[section]
        return self.contacts[keyFromIndex]!.count
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.contacts.sortedKeys[section]
    }
    
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.contacts.sortedKeys
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactListTableViewCell)) as? ContactListTableViewCell else {
                print("Failed to dequeue \(String(ContactListTableViewCell))")
                return UITableViewCell()
            }
        
            let keyFromIndex = self.contacts.sortedKeys[indexPath.section]
        
            cell.contactNameLabel.text = "\(contacts[keyFromIndex]![indexPath.row].firstName!) \(contacts[keyFromIndex]![indexPath.row].lastName!)"
            cell.contactUserIdLabel.text = "\(contacts[keyFromIndex]![indexPath.row].userId!)"
            
            return cell
    }


}

