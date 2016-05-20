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
            
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.sortDescriptors = [NSSortDescriptor(key: "sectionTitleFirstName", ascending: true)]
            
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchContactRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "sectionTitleFirstName", cacheName: nil)
            fetchedResultController.delegate = self
            
            do {
                try fetchedResultController.performFetch()
            }
            catch {
                print(error)
            }
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
        guard
            let sections = fetchedResultController.sections
            else {
                return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard
            let sections = fetchedResultController.sections
            else {
                return nil
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.name
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultController!.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultController.sectionIndexTitles
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactListTableViewCell)) as? ContactListTableViewCell,
            let contact = fetchedResultController.objectAtIndexPath(indexPath) as? Contact
            else {
                print("Failed to dequeue \(String(ContactListTableViewCell))")
                return UITableViewCell()
        }
        
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
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    
    // MARK: Navigation
    
    @IBAction func unwindToContactsViewController(segue: UIStoryboardSegue) {
        
    }
    
    
}


