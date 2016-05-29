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

class AddContactsViewController: UITableViewController, UISearchResultsUpdating, SearchContactObserverDelegate {
    
    var searchContactObserver: SearchContactObserver?
    var searchController: UISearchController!
    var searchResponse: [[String: AnyObject]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchContactObserver = SearchContactObserver(withDelegate: self)
        
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
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard
                let searchResponse = searchResponse
                else {
                    return 0
            }
                
            return searchResponse.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(AddContactTableViewCell)) as? AddContactTableViewCell,
            let contact = searchResponse?[indexPath.row]
            else {
                return UITableViewCell()
        }
        
        guard
            let firstName = contact["firstName"] as? String,
            let lastName = contact["lastName"] as? String,
            let profilePicData = contact["profilePicData"] as? NSData,
            let userId = contact["userId"] as? String
            else {
                return cell
        }
        
        // Configure the table cell
        cell.contactNameLabel.text = "\(firstName) \(lastName)"
        cell.contactImageView.image = UIImage(data: profilePicData)
        cell.addButton.alpha = 1
        cell.requestSentLabel.alpha = 0
        
        cell.addButtonAction = {() -> Void in
            ContactObserver.observer.addContact(userId)
            UIView.animateWithDuration(1, animations: {
                cell.addButton.alpha = 0
                cell.requestSentLabel.alpha = 1
            }, completion: { (complete) in
                if complete {
                self.searchResponse?.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            })
        }
        
        return cell
        
    }
    
   
    
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard
            let searchString = searchController.searchBar.text
            else {
                return
        }
        
        searchContactObserver?.searchContactContainsString(searchString)
    }
    
    
    // MARK: - SearchContactObserverDelegate
    
    func didSearchContactResponseUpdate(observer: SearchContactObserver, searchResponse: [[String : AnyObject]]) {
        self.searchResponse = searchResponse
        tableView.reloadData()
    }
}
