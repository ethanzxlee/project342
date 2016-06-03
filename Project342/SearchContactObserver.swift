//
//  ContactSearchManager.swift
//  Project342
//
//  Created by Zhe Xian Lee on 28/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import CoreData
import Firebase
import Foundation


/// SearchContactObserver is responsible to prepare and send a search request to 
/// our Firebase's search reference. It will observes the response for every request
/// made.
class SearchContactObserver {
    let appDelegate: AppDelegate
    let managedObjectContext: NSManagedObjectContext
    
    var timer: NSTimer?
    var searchString: String?
    var searchResponse: [[String: AnyObject]]
    var delegate: SearchContactObserverDelegate
    
    
    init(withDelegate: SearchContactObserverDelegate) {
        searchResponse = [[String: AnyObject]]()
        delegate = withDelegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    /**
        Search the users whose first name, last name or email address contains the provided string.
        The users who are already added the logged in users as friends or sent a contact request will 
        be excluded from the search. Calling this method continuously within 0.5 second will only 
        trigger only 1 search request. This is to reduce the situation where the older search arives 
        after the newer search, then overwrites the newer search response, resulting incorrect search
        response being displayed
     
        - Parameters:
            - string: The search string
     */
    func searchContactContainsString(string: String) {
        // Reset the timer
        timer?.invalidate()
        
        // Trim the searchString
        searchString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Start the search request after 0.5s
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.performSearchRequest), userInfo: nil, repeats: false)
    }
    
  
    /**
        This is the actuall function that sends the search request to Firebase. It will only be 
        called by the scheduled NSTimer which requires it to be exposed to Objective-C.
     */
    @objc private func performSearchRequest() {
        searchResponse.removeAll()
        
        // Make sure we have a searchString before continuing
        guard
            var searchString = searchString
            else {
                delegate.didSearchContactResponseUpdate(self, searchResponse: searchResponse)
                return
        }
        
        searchString = searchString.lowercaseString
        searchString = searchString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // If the searchString is empty after trimming
        // Clear the search results
        if searchString.characters.count == 0 {
            delegate.didSearchContactResponseUpdate(self, searchResponse: searchResponse)
            return
        }

        // Prepare the search request
        let request = prepareElasticSearchRequest(searchString)

        // Obtain the search request endpoint ref
        let searchRef = FirebaseRef.searchRequestRef?.childByAutoId()

        // Set the request
        searchRef?.setValue(request)

        // Observe the search endpoint to obtain the request ID
        searchRef?.observeSingleEventOfType(.Value) { (requestSnapshot: FIRDataSnapshot) in
            let requestId = requestSnapshot.key

            // Obtain the search response endpoint ref
            let responseRef = FirebaseRef.searchResponseRef?.child(requestId)

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { 
                NSThread.sleepForTimeInterval(0.5)
                
                // Observe the search response endpoint to obtain the response
                responseRef?.observeSingleEventOfType(.Value, withBlock: { (responseSnapshot: FIRDataSnapshot) in
                    self.didSearchResponseValueChange(responseSnapshot)
                })
            })
            
           
        }
    }
    
    
    /**
        Prepare the search request from the provided search string to ElasticSearch format
        
        - Parameters:
            - string: The search string
     
        - Returns:
            The search request in a dictionary that follows ElasticSearch format
     */
    private func prepareElasticSearchRequest(searchString: String) -> [String: AnyObject] {
        // An array that includes all the user's current contact user ID
        // Due to not having a dedicated server handling this
        var excludeIds = [[String: [String: String]]]()
        
        // Fetch the user's contact from CoreData
        let fetchRequest = NSFetchRequest(entityName: String(Contact))
        do {
            if let contacts = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact] {
                for contact in contacts {
                    if let contactUserId = contact.userId {
                        // Append the contact's user ID
                        excludeIds.append([
                            "term": [
                                "_id": contactUserId
                            ]
                        ])
                    }
                }
            }
        }
        catch {
            print(error)
        }
        
        // Exclude the logged in user ID too
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            excludeIds.append([
                "term": [
                    "_id": userId
                ]
            ])
        }
        
        return [
            "index": "firebase",
            "type": "user",
            "query": [
                "bool": [
                    "must": [
                        "query_string": [
                            "fields": ["firstName", "lastName", "email"],
                            "query": "*\(searchString)* OR *\(searchString)* OR \(searchString)"
                        ]
                    ],
                    "must_not": [
                        excludeIds
                    ]
                ]
            ]
        ]
    }
    
    
    /**
        Parse and process the search response when it arrives.
        
         - Parameters:
            - responseSnapshot: The snapshot of the search response
     */
    private func didSearchResponseValueChange(responseSnapshot: FIRDataSnapshot) {
        searchResponse.removeAll()
        
        // Make sure we have matching results from responseSnapshot
        guard
            let hits = responseSnapshot.value?["hits"] as? [AnyObject]
            else {
                // Notify even when there's no matching results
                delegate.didSearchContactResponseUpdate(self, searchResponse: searchResponse)
                return
        }
        
        // Parse the search response
        for hit in hits {
            
            // Ensure we have all the data we need
            guard
                let contact = hit["_source"] as? [String: String]
                else {
                    break
            }
            
            guard
                let userId = hit["_id"] as? String,
                let firstName = contact["firstName"],
                let lastName = contact["lastName"]
                else {
                    break
            }
            
            searchResponse.append([
                "userId": userId,
                "firstName": firstName,
                "lastName": lastName,
            ])
        }
        
        // Notify when the response is ready
        delegate.didSearchContactResponseUpdate(self, searchResponse: searchResponse)
    }
    
}

