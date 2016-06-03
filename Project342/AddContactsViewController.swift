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

class AddContactsViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, SearchContactObserverDelegate {
    
    var searchContactObserver: SearchContactObserver?
    var searchController: UISearchController!
    var searchResponse: [[String: AnyObject]]?
    var cache: NSCache?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache = NSCache()
        searchContactObserver = SearchContactObserver(withDelegate: self)
        
        tableView.tableFooterView = UIView()
        
        // Setup the search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.translucent = true
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.barTintColor = UIColor.searchBarBackgroundColor()
        searchController.searchBar.tintColor = UIColor.themeColor()
        searchController.searchBar.backgroundColor = UIColor.searchBarBackgroundColor()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        // Display the search bar if user choose normal search
        tableView.tableHeaderView = searchController.searchBar
        searchController.active = true
        
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
            let userId = contact["userId"] as? String
            else {
                return cell
        }
        
        // Configure the table cell
        cell.contactNameLabel.text = "\(firstName) \(lastName)"
        cell.addButton.alpha = 1
        cell.requestSentLabel.alpha = 0
        cell.contactImageView.image = nil
        
        // Download their profile picture
        StorageRef.profilePicRef.child(userId).downloadURLWithCompletion { (url, error) in
            guard
                let url = url
                where error == nil
                else {
                    print(error)
                    return
            }
            
            if let profilePicData = self.cache?.objectForKey(url.path!) as? NSData {
                if tableView.cellForRowAtIndexPath(indexPath) == cell {
                    dispatch_async(dispatch_get_main_queue(), { 
                        cell.contactImageView.image = UIImage(data: profilePicData)
                    })
                }
            }
            else {
                let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                    guard
                        let data = data,
                        let response = response
                        where error == nil
                        else {
                            print(error)
                            return
                    }
                    
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.cache?.setObject(data, forKey: url.path!)
                        }
                        if let cellAtIndexPath = tableView.cellForRowAtIndexPath(indexPath) as? AddContactTableViewCell {
                            if cell == cellAtIndexPath && cell.contactNameLabel.text == cellAtIndexPath.contactNameLabel.text {
                                dispatch_async(dispatch_get_main_queue(), {
                                    cell.contactImageView.image = UIImage(data: data)
                                })
                            }
                        }
                    }
                })
                downloadTask.resume()
            }
        }
        
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
    
   
    // MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    func didDismissSearchController(searchController: UISearchController) {
        performSegueWithIdentifier("UnwindToContactsViewController", sender: nil)
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
