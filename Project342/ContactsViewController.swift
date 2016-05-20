//
//  SecondViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var contacts = [String: [Contact]]()
    var fetchedResultController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let managedObjectContext = appDelegate.managedObjectContext
            
            // TODO: Will be moved into the AppModel
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
            
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchContactRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultController.delegate = self
            
            do {
                try fetchedResultController.performFetch()
            }
            catch {
                print(error)
            }
            //            do {
            //                if var contacts = try coreDataContext.executeFetchRequest(fetchContactRequest) as? [Contact] {
            //                    // Sort all the contacts by their first name
            //                    // TODO: IDEA? this preference can be override in our app settings page
            //                    contacts = contacts.sort({ (a, b) -> Bool in
            //                        a.firstName!.localizedCompare(b.firstName!) == .OrderedAscending
            //                    })
            //
            //                    // Regroup the contacts into a dictionary according to their first names' first character
            //                    for contact in contacts {
            //                        // Convert the first character so that the grouping is case-insensitive
            //                        let firstCharacter = String(contact.firstName![contact.firstName!.startIndex]).uppercaseString
            //
            //                        // Init the group if it doesn't exist
            //                        if (self.contacts[firstCharacter] == nil) {
            //                            self.contacts[firstCharacter] = [Contact]()
            //                        }
            //
            //                        // Append the contact into the group
            //                        self.contacts[firstCharacter]?.append(contact)
            //                    }
            //
            //                }
            //            }
            //            catch {
            //                print(error)
            //            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CipherModel.sharedModel.observeContactsEvents()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        CipherModel.sharedModel.stopObservingContactsEvents()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let keyFromIndex = self.contacts.sortedKeys[section]
        //        return self.contacts[keyFromIndex]!.count
        guard
            let sections = fetchedResultController.sections
            else {
                return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    //
    //    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return self.contacts.sortedKeys[section]
    //    }
    //
    //
    //    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    //        return self.contacts.sortedKeys
    //    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactListTableViewCell)) as? ContactListTableViewCell,
            let contact = fetchedResultController.objectAtIndexPath(indexPath) as? Contact
            else {
                print("Failed to dequeue \(String(ContactListTableViewCell))")
                return UITableViewCell()
        }
        
        // let keyFromIndex = self.contacts.sortedKeys[indexPath.section]
        //
        // cell.contactNameLabel.text = "\(contacts[keyFromIndex]![indexPath.row].firstName!) \(contacts[keyFromIndex]![indexPath.row].lastName!)"
        
        cell.contactNameLabel.text = contact.firstName
        
        
        return cell
    }
    
    
    // MARK: - NSFetchedResultControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if controller == fetchedResultController {
            tableView.beginUpdates()
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller == fetchedResultController {
            tableView.endUpdates()
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            guard
                let contact = anObject as? Contact,
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as? ContactListTableViewCell
                else {
                    break
            }
            cell.contactNameLabel.text = contact.firstName
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            
        }
    }
    
    
    // MARK: Navigation
    
    @IBAction func unwindToContactsViewController(segue: UIStoryboardSegue) {
        
    }
    
    
}

