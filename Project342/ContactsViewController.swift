//
//  SecondViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ContactsViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    enum ContactSegment: Int {
        case AllContacts = 0
        case Request = 1
    }
    
    var contactFetchedResultController: NSFetchedResultsController?
    var requestFetchedResultController: NSFetchedResultsController?
    var searchController: UISearchController!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let managedObjectContext = appDelegate.managedObjectContext
            
            let fetchContactRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequest.sortDescriptors = [NSSortDescriptor(key: "sectionTitleFirstName", ascending: true)]
            contactFetchedResultController = NSFetchedResultsController(fetchRequest: fetchContactRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "sectionTitleFirstName", cacheName: nil)
            
            let fetchContactRequestRequest = NSFetchRequest(entityName: String(Contact))
            fetchContactRequestRequest.sortDescriptors = [NSSortDescriptor(key: "status", ascending: false)]
            requestFetchedResultController = NSFetchedResultsController(fetchRequest: fetchContactRequestRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        }
    
        // Setup tableView appearance
        tableView.backgroundView = UIView()
        
        // Hide the divider between empty cells
        tableView.tableFooterView = UIView()
        
        // Setup the search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.translucent = true
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.barTintColor = UIColor.searchBarBackgroundColor()
        searchController.searchBar.tintColor = UIColor.themeColor()
        searchController.searchBar.backgroundColor = UIColor.searchBarBackgroundColor()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setupTableViewData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let contacts = contactFetchedResultController?.fetchedObjects as? [Contact] {
            for contact in contacts {
                ContactUserObserver.observer.observeContactUserInfoForContactId(contact.userId!)
            }
        }
        
        if let requests = requestFetchedResultController?.fetchedObjects as? [Contact] {
            for request in requests {
                ContactUserObserver.observer.observeContactUserInfoForContactId(request.userId!)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        ContactUserObserver.observer.stopObservingAllContactUserInfo()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            guard
                let sectionCount = contactFetchedResultController?.sections?.count
                else {
                    return 0
            }
            return sectionCount
        }
        else if segmentedControl.selectedSegmentIndex == ContactSegment.Request.rawValue {
            guard
                let sectionCount = requestFetchedResultController?.sections?.count
                else {
                    return 0
            }
            return sectionCount
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            guard
                let sections = contactFetchedResultController?.sections
                else {
                    return 0
            }
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        else if segmentedControl.selectedSegmentIndex == ContactSegment.Request.rawValue {
            guard
                let sections = requestFetchedResultController?.sections
                else {
                    return 0
            }
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            guard
                let sections = contactFetchedResultController?.sections
                else {
                    return nil
            }
            
            let sectionInfo = sections[section]
            return sectionInfo.name
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            return contactFetchedResultController!.sectionForSectionIndexTitle(title, atIndex: index)
        }
        return index
    }
    
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            return contactFetchedResultController?.sectionIndexTitles
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            guard
                let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactListTableViewCell)) as? ContactListTableViewCell,
                let contact = contactFetchedResultController?.objectAtIndexPath(indexPath) as? Contact,
                let profilePicDirectory = Directories.profilePicDirectory
                else {
                    return UITableViewCell()
            }
            
            guard
                let firstName = contact.firstName,
                let lastName = contact.lastName
                else {
                    return cell
            }
            
            let profilePicFileURL = profilePicDirectory.URLByAppendingPathComponent(contact.userId!)
            cell.contactProfileImageView.image = UIImage(contentsOfFile: profilePicFileURL.path!)
            cell.contactNameLabel.text = "\(firstName) \(lastName)"
            
            return cell
        }
        else if segmentedControl.selectedSegmentIndex == ContactSegment.Request.rawValue {
            guard
                let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactRequestTableViewCell)) as? ContactRequestTableViewCell,
                let contact = requestFetchedResultController?.objectAtIndexPath(indexPath) as? Contact,
                let profilePicDirectory = Directories.profilePicDirectory
                else {
                    return UITableViewCell()
            }
            
            guard
                let firstName = contact.firstName,
                let lastName = contact.lastName
                else {
                    return cell
            }
            
            let profilePicFileURL = profilePicDirectory.URLByAppendingPathComponent(contact.userId!)
            cell.contactProfileImageView.image = UIImage(contentsOfFile: profilePicFileURL.path!)
            cell.contactNameLabel.text = "\(firstName) \(lastName)"
            cell.didAcceptButtonPressedAction = { () -> (Void) in
                self.acceptContactAt(indexPath)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        // Change the header text color
        headerView.textLabel?.textColor = UIColor.themeColor()
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteContactAt(indexPath)
        }
    }
    
    
    // MARK: - NSFetchedResultControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
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
            if let contact = anObject as? Contact {
                if let userId = contact.userId {
                    ContactUserObserver.observer.observeContactUserInfoForContactId(userId)
                }
            }
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            if let contact = anObject as? Contact {
                if let userId = contact.userId {
                    ContactUserObserver.observer.stopObservingContactUserInfoForContact(userId)
                }
            }
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            if let contact = anObject as? Contact {
                if let userId = contact.userId {
                    ContactUserObserver.observer.observeContactUserInfoForContactId(userId)
                }
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.active {
            guard
                let searchText = searchController.searchBar.text
                else {
                    return
            }
            let predicate = NSPredicate(format: "((firstName CONTAINS[c] %@) or (lastName CONTAINS[c] %@)) and status = %@", searchText, searchText, ContactStatus.Added.rawValue)
            contactFetchedResultController?.fetchRequest.predicate = predicate
            
        }
        else {
            let predicate = NSPredicate(format: "status = %@", ContactStatus.Added.rawValue)
            contactFetchedResultController?.fetchRequest.predicate = predicate
        }
        
        // Update the contactFetchedResultController and tableview
        do {
            try contactFetchedResultController?.performFetch()
            tableView.reloadData()
        }
        catch {
            print(error)
        }
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.hidesBottomBarWhenPushed = true
        
        if segue.identifier == "ShowChatRoomViewController" {
            guard
                let chatRoomViewController = segue.destinationViewController as? ChatRoomViewController,
                let selectedIndexPath = tableView.indexPathForSelectedRow
                else {
                    return
            }
            guard
                let selectedContact = contactFetchedResultController?.objectAtIndexPath(selectedIndexPath) as? Contact
                else {
                    return
            }
            
            let conversation = chatRoomViewController.appModel.createNewConversation([selectedContact])
            chatRoomViewController.conversationID = conversation.conversationID
            
        }
    }
    
    
    @IBAction func unwindToContactsViewController(segue: UIStoryboardSegue) {
    }
    
    
    // MARK: - IBActions
    
    @IBAction func didSegmentedControlValueChange(sender: UISegmentedControl) {
        setupTableViewData()
    }
    
    
    @IBAction func didTouchAddContactButton(sender: UIBarButtonItem) {
        // Prepare the action sheet controller
        let actionSheetTitle = NSLocalizedString("Add contact", comment: "Add contact")
        let searchContactActionTitle = NSLocalizedString("From search", comment: "From search")
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "Cancel")
        
        let actionSheetController = TintedAlertViewController(title: actionSheetTitle, message: nil, preferredStyle: .ActionSheet)
        
        let searchContactAction = UIAlertAction(title: searchContactActionTitle, style: .Default) { (_) in
            self.performSegueWithIdentifier("ShowAddContactViewController", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .Cancel, handler: nil)
        
        actionSheetController.addAction(searchContactAction)
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.barButtonItem = sender
        
        // Present the action sheet controller
        presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    // MARK: - Functions
    
    func setupTableViewData()  {
        if (segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue) {
            contactFetchedResultController?.delegate = self
            requestFetchedResultController?.delegate = nil
            
            do {
                let predicate = NSPredicate(format: "status = %@", ContactStatus.Added.rawValue)
                contactFetchedResultController?.fetchRequest.predicate = predicate
                
                try contactFetchedResultController?.performFetch()
                tableView.tableHeaderView = searchController.searchBar
                tableView.reloadData()
                searchController.searchBar.sizeToFit()
                tableView.allowsSelection = true
            }
            catch {
                print(error)
            }
            
        }
        else if (segmentedControl.selectedSegmentIndex == ContactSegment.Request.rawValue) {
            contactFetchedResultController?.delegate = nil
            requestFetchedResultController?.delegate = self
            do {
                let predicate = NSPredicate(format: "status BEGINSWITH[c] %@", ContactStatus.Request.rawValue)
                requestFetchedResultController?.fetchRequest.predicate = predicate
                
                try requestFetchedResultController?.performFetch()
                tableView.tableHeaderView = nil
                tableView.reloadData()
                tableView.allowsSelection = false
            }
            catch {
                print(error)
            }
        }
        
        if let contacts = contactFetchedResultController?.fetchedObjects as? [Contact] {
            for contact in contacts {
                ContactUserObserver.observer.observeContactUserInfoForContactId(contact.userId!)
            }
        }
        
        if let requests = requestFetchedResultController?.fetchedObjects as? [Contact] {
            for request in requests {
                ContactUserObserver.observer.observeContactUserInfoForContactId(request.userId!)
            }
        }

    }
    
    
    func deleteContactAt(indexPath: NSIndexPath) {
        if segmentedControl.selectedSegmentIndex == ContactSegment.AllContacts.rawValue {
            guard
                let contact = contactFetchedResultController?.objectAtIndexPath(indexPath) as? Contact
                else {
                    return
            }
            ContactObserver.observer.deleteContact(contact.userId!)
        }
        else if segmentedControl.selectedSegmentIndex == ContactSegment.Request.rawValue {
            guard
                let contact = requestFetchedResultController?.objectAtIndexPath(indexPath) as? Contact
                else {
                    return
            }
            ContactObserver.observer.deleteContact(contact.userId!)
        }
    }
    
    
    func acceptContactAt(indexPath: NSIndexPath) {
        guard
            let contact = requestFetchedResultController?.objectAtIndexPath(indexPath) as? Contact
            else {
                return
        }
        ContactObserver.observer.acceptContactRequest(contact.userId!)
    }
}


