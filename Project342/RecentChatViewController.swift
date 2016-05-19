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
import QuartzCore

class RecentChatViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    // Set the number of loading needed for query data from core data
    // Set the default values needed add for the increasing of number of loading
    var numberOfLoading = 1
    let defaultLimit = 20
    
    var nextPage = 0
    
    // Recently conversation list
    var conversationList = [Conversation]()
    
    // Filtered result when use search
    var filteredConversationList = [Conversation]()
    
    // members for creation of new char
    // get from CreateNewChat
    var contactsForNewConversation: [Contact]?
    var searchBegin = false
    
    let appModel = AppModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load inital data for try
        //willDeleteAfterFinish()
        
        // Add edit button to navigation bar
        self.navigationItem.leftBarButtonItem = editButtonItem()
        let composeButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(RecentChatViewController.createNewConversation))

        self.navigationItem.rightBarButtonItem = composeButton
        
        
        /**
         Catch the recent conservation form the cored data and assign to an arry variable
         The limit of result is based on the number of loading * defaultLimit
         */
        conversationList = appModel.getConversationList(numberOfLoading * defaultLimit)
        numberOfLoading += 1
        
        
        searchBar.delegate = self
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl?.addTarget(self, action: #selector(RecentChatViewController.refreshToGetNewFunction(_:)), forControlEvents: .ValueChanged)
        self.tableView.contentOffset = CGPointMake(0, -(self.refreshControl?.frame.size.height)!)
        
        /**
         Aaoli from stackoverflow.com
         Show UISearchController when tableView swipe down
         http://stackoverflow.com/questions/32923091/show-uisearchcontroller-when-tableview-swipe-down
         */
        self.tableView.contentOffset = CGPointMake(0.0, 44.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchBegin{
            return filteredConversationList.count
        }
        return conversationList.count
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("recentContactReuseCell", forIndexPath: indexPath)
        var conversation : Conversation?
        if searchBegin{
            conversation = self.filteredConversationList[indexPath.row]
        }else{
            conversation = self.conversationList[indexPath.row]
        }
        
        /** 
         NSHipster.com
         Image Resizing Techniques
         http://nshipster.com/image-resizing/
        */
        // FIXME: temporay set user name
        let members = conversation!.members?.allObjects as! [Contact]
        
        // FIXME: get the image from Directory
        let image = UIImage(named: members[0].imagePath!)!
        
        let size = CGSize(width: 50, height: 50)
        let hasAlpha = false
        let scale:CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.imageView?.image = scaledImage
        
        /**
         Adi Nugroho
         Circular UIImageView in UITableView Cell
         https://medium.com/@adinugroho/circular-uiimageview-in-uitableview-cell-e1a7e1b6fe63#.2g5l01siu
         Used for: Solve the problem of round image delay
         */
        cell.imageView?.layer.cornerRadius = scaledImage.size.width/2
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.contentMode = .ScaleAspectFit
        cell.textLabel?.text = appModel.getConversationName(members)
     
        return cell
     }

    
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
         return true
     }
 
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
             // Delete the row from the data source
            appModel.deleteConversation(conversationList[indexPath.row])
            conversationList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
         } else if editingStyle == .Insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
    
    /**
     Beslan Tularov from stakeoverflow.com
     load more for UITableView in swift
     http://stackoverflow.com/questions/27079253/load-more-for-uitableview-in-swift
     */
    // Function for Swipe-up to load more information
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //if the row reach max, it will remain at the max number of conversation in core data else it will load the data
        if conversationList.count == appModel.getConversationMaxRange() {
            nextPage = conversationList.count
        }else{
            nextPage = conversationList.count - 3
        }
        if indexPath.row == nextPage{
            loadingConservationFromCoreData()
        }
        
    }
    
    /**
     vacawama from stakeoverflow.com
     Load More After Coming to Bottom of UITableView
     http://stackoverflow.com/questions/32425466/load-more-after-coming-to-bottom-of-uitableview
     */
    // Load data from Core Data and save the time in interface
    // Thus, acitvity indicator is no needed
    func loadingConservationFromCoreData(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                
                self.nextPage = self.conversationList.count - 3
                // this runs on the main queue
                self.conversationList.removeAll(keepCapacity: true)
                self.conversationList = self.appModel.getConversationList(self.numberOfLoading * self.defaultLimit)
                if self.conversationList.count == self.appModel.getConversationMaxRange() {
                    self.nextPage = self.conversationList.count
                }
                self.numberOfLoading += 1
                self.tableView.reloadData()
            }
        }
    }

    // Change the right bar button when it is in editing mode or normal mode
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing{
            
            let deleteAllButton = UIBarButtonItem(title: "Delete All", style: .Done, target: self, action: #selector(RecentChatViewController.deleteAllConversations))
            self.navigationItem.rightBarButtonItem = deleteAllButton
            self.refreshControl?.endRefreshing()
        }else{
            let composeButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(RecentChatViewController.createNewConversation))
            self.navigationItem.rightBarButtonItem = composeButton
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    // Function for Pull to refresh
    func refreshToGetNewFunction(sender:AnyObject) {
        self.conversationList = self.appModel.getConversationList(numberOfLoading*defaultLimit)
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Bar Button Functions
    func createNewConversation(){
        self.performSegueWithIdentifier("goToCreateNewChat", sender: self)
        print("createNewConversation()")
    }
    
    
    // Function for 'Delete All' button when tableview enter edit mode
    func deleteAllConversations(){
        self.appModel.deleteAllConversations()
        self.conversationList.removeAll()
        self.tableView.reloadData()

    }
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBegin = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBegin = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBegin = false
        let searchText = self.searchBar.text
        if searchText == "" {
            searchBegin = true
        }else{
            filteredConversationList = self.appModel.searchResult(searchText!)
        }
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        filteredConversationList = self.appModel.searchResult(text)
        return true
    }
    
    // MARK: Segue
    @IBAction func getBackFromCreateNewChat(sender: UIStoryboardSegue){
        print("1")
        print(sender.identifier)
        print(sender.accessibilityValue)
        print("2")
        hello()
        
        // FIXME: segue perform to ChatRoom
        if contactsForNewConversation?.count > 0 {
            self.appModel.createNewConversation(contactsForNewConversation!)
        }
    }
    
    
    
    // MARK: MUST DELETE
    func willDeleteAfterFinish(){
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let context = appDelegate.managedObjectContext
            for a in 0...20{
                if let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as? Contact {
                    contact.firstName = "qasw \(a)"
                    contact.lastName = "hello"
                    contact.imagePath = "defaultPicture.png"
                    // Try to save
                    do {
                        try context.save()
                    }
                    catch {
                        
                    }
                }
            }
        }
        
        let contactList = appModel.getContactList()
        for eachContact in contactList{
            var contactArry = [Contact]()
            contactArry.append(eachContact)
            contactArry.append(contactList[15])
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                let context = appDelegate.managedObjectContext
            if let msg = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as? Message {
                
                    // Try to save
                    do {
                        try context.save()
                    }
                    catch {
                        
                    }
                }
            }

            let success = appModel.createNewConversation(contactArry)
            print(success)
        }
    }
    
    func hello(){
        print("hello")
    }


}

