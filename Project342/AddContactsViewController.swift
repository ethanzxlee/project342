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

class AddContactsViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController!
    var searchEventHandle: FirebaseHandle?
    var searchResult: [[String: String]]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResult = [[String: String]]()
        
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
                let searchResult = searchResult
                else {
                    return 0
            }
                
            return searchResult.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(AddContactTableViewCell)) as? AddContactTableViewCell,
            let contact = searchResult?[indexPath.row]
            else {
                return UITableViewCell()
        }
        
        // Configure the table cell
        cell.contactNameLabel.text = "\(contact["firstName"]!) \(contact["lastName"]!)"
        
        return cell
        
    }

    var timer : NSTimer?
    
    func search() {
        print("searching now")
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard
            var searchTerm = searchController.searchBar.text
            else {
                return
        }
        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(self.search), userInfo: nil, repeats: false)
        
        
        // Trim the searchTerm
        searchTerm = searchTerm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//
//        // If the searchTerm is empty after trimming,
//        // do not send a search request
//        if searchTerm.characters.count == 0 {
//            searchResult?.removeAll()
//            tableView.reloadData()
//            return
//        }
//        
//        // Prepare the search request
//        // Add '*' at the beginning and end of the searchterm
//        // So that it returns results that match any part of the search term
//        let request = [
//            "index": "firebase",
//            "type": "user",
//            "query": [
//                "query_string": [
//                    "query": "*\(searchTerm)*"
//                ]
//            ]
//        ]
//        
//        // Obtain the search request endpoint ref
//        let searchRef = ContactManager.sharedManager.firebaseRoot.childByAppendingPath("search")
//                        .childByAppendingPath("request").childByAutoId()
//        
//        // Set the request
//        searchRef.setValue(request)
//        
//        // Observe the search endpoint to obtain the request ID
//        searchRef.observeSingleEventOfType(.Value) { (requestSnapshot: FDataSnapshot!) in
//            let requestId = requestSnapshot.key
//            
//            // Obtain the search response endpoint ref
//            let responseRef = ContactManager.sharedManager.firebaseRoot.childByAppendingPath("search")
//                                .childByAppendingPath("response").childByAppendingPath(requestId)
//            
//            // Observe the search response endpoinf to obtain the response
//            responseRef.observeSingleEventOfType(.Value, withBlock: { (responseSnapshot) in
//                
//                guard
//                    let hits = responseSnapshot.value["hits"] as? [AnyObject]
//                    else {
//                        // If there's no results
//                        self.searchResult?.removeAll()
//                        dispatch_async(dispatch_get_main_queue(), {
//                            self.tableView.reloadData()
//                        })
//                        
//                        return
//                }
//                
//                // Remove all the existing search results
//                self.searchResult?.removeAll()
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//                
//                // Parse the result
//                for hit in hits {
//                    guard
//                        let contact = hit["_source"] as? [String: String]
//                        else {
//                            return
//                    }
//                    
//                    guard
//                        let userId = hit["_id"] as? String,
//                        let firstName = contact["firstName"],
//                        let lastName = contact["lastName"]
//                        else {
//                            return
//                    }
//                    
//                    self.searchResult?.append([
//                        "userId": userId,
//                        "firstName": firstName,
//                        "lastName": lastName
//                    ])
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//                
//            })
//        }
//        
//        
        
    }
}
