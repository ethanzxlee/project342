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
    var conversationListDic = [[String: AnyObject]]()
    
    // Filtered result when use search
    var filteredConversationList = [[String: AnyObject]]()
    
    // members for creation of new char
    // get from CreateNewChat
    var contactsForNewConversation: [Contact]?
    var searchActive = false
    
    let appModel = AppModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: MUST DELETE Load inital data for try
//        willDeleteAfterFinish()
        
        // Add edit button to navigation bar
        self.navigationItem.leftBarButtonItem = editButtonItem()
        let composeButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(RecentChatViewController.createNewConversation))

        self.navigationItem.rightBarButtonItem = composeButton
        
        
        /**
         Catch the recent conservation form the cored data and assign to an arry variable
         The limit of result is based on the number of loading * defaultLimit
         */
        conversationListDic = appModel.getConversationList(numberOfLoading * defaultLimit)
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
        self.tableView.contentOffset = CGPointMake(0.0, self.searchBar.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if contactsForNewConversation?.count > 0 {
            let newConversation = self.appModel.createNewConversation(contactsForNewConversation!)
            
            ConversationObserver.observer.conversationCreate(newConversation)
            contactsForNewConversation?.removeAll(keepCapacity: false)
            print(contactsForNewConversation?.count)
            self.performSegueWithIdentifier("toChatRoom", sender: newConversation.conversationID)
        }else{
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    self.conversationListDic = self.appModel.getConversationList(self.numberOfLoading * self.defaultLimit)
                    self.tableView.reloadData()

                })
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive{
            return filteredConversationList.count
        }
        return conversationListDic.count
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("recentContactReuseCell", forIndexPath: indexPath)
        var conversationDict : [String: AnyObject]?
        if searchActive{
            conversationDict = self.filteredConversationList[indexPath.row]
        }else{
            conversationDict = self.conversationListDic[indexPath.row]
        }

        /**
         NSHipster.com
         Image Resizing Techniques
         http://nshipster.com/image-resizing/
        */
        
        let image : UIImage?
        if conversationDict!["conversationPhotoPath"] as? String == "group.png"{
            image = UIImage(named: "group.png")!
        }else{
            let imgName = conversationDict!["conversationPhotoPath"] as? String
            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentDirectory = documentPath[0]
            image = UIImage(named: "\(documentDirectory)/\(imgName)")
        }

        
        let size = CGSize(width: 50, height: 50)
        let hasAlpha = false
        let scale:CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        image?.drawInRect(CGRect(origin: CGPointZero, size: size))
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
        cell.textLabel?.text = conversationDict!["conversationName"] as? String
        print(conversationDict!["conversationName"])
        
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
            let conversationDict = conversationListDic[indexPath.row]
            if conversationDict["type"] as? Int == ConversationType.Group.rawValue{
                let alertDialog = UIAlertController(title: "Delete Group Message", message: "You will be assume left the group if you delete the group message. Do you would like to continue carry out the deletion process?", preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Leave and Delete", style: .Default, handler: { (_) in
                    
                    self.appModel.deleteConversation(conversationDict["conversationID"] as! String)
                    self.conversationListDic.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                })
                
                let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
                
                alertDialog.addAction(noAction)
                alertDialog.addAction(yesAction)
                
                self.presentViewController(alertDialog, animated: true, completion: nil)
            }else{
                self.appModel.deleteConversation(conversationDict["conversationID"] as! String)
                self.conversationListDic.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
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
        if conversationListDic.count == appModel.getConversationMaxRange() {
            nextPage = conversationListDic.count
        }else{
            nextPage = conversationListDic.count - 3
        }
        if indexPath.row == nextPage{
            loadingConservationFromCoreData()
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchActive {
            self.performSegueWithIdentifier("toChatRoom", sender: filteredConversationList[indexPath.row]["conversationID"] as! String)
        }else{
            self.performSegueWithIdentifier("toChatRoom", sender: conversationListDic[indexPath.row]["conversationID"] as! String)
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
                
                self.nextPage = self.conversationListDic.count - 3
                // this runs on the main queue
                self.conversationListDic.removeAll(keepCapacity: true)
                self.conversationListDic = self.appModel.getConversationList(self.numberOfLoading * self.defaultLimit)
                if self.conversationListDic.count == self.appModel.getConversationMaxRange() {
                    self.nextPage = self.conversationListDic.count
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
        self.conversationListDic = self.appModel.getConversationList(numberOfLoading*defaultLimit)
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
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatRoom" {
            if let navigationController = segue.destinationViewController as? UINavigationController{
                if let destionation = navigationController.topViewController as? ChatRoomViewController{
                    destionation.conversationID = sender as? String
                }
            }
        }
     }
 
    // MARK: Segue
    @IBAction func getBackFromCreateNewChat(sender: UIStoryboardSegue){}
    
    @IBAction func unwindFromChatRoom(sender: UIStoryboardSegue){}
    
    
    // MARK: - Bar Button Functions
    func createNewConversation(){
        self.performSegueWithIdentifier("goToCreateNewChat", sender: self)
    }
    
    
    // Function for 'Delete All' button when tableview enter edit mode
    func deleteAllConversations(){
        let alertDialog = UIAlertController(title: "Delete All Chats", message: "The group chats setting will assume you leave the group once delete the conversation. Dou you would like to carry out the deletions? ", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Delete All", style: .Default) { (_) in
            self.appModel.deleteAllConversations()
            self.conversationListDic.removeAll()
            self.tableView.reloadData()
        }
        let noAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertDialog.addAction(noAction)
        alertDialog.addAction(yesAction)
        
        self.presentViewController(alertDialog, animated: true, completion: nil)

    }
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        let searchText = searchBar.text
        if searchText == "" {
            // Search Text Empty, so it will take the origin conversation list
            searchActive = false
        }else{
            filteredConversationList = self.appModel.searchResult(searchText!)
        }
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        if searchText == "" {
            // Search Text Empty, so it will take the origin conversation list
            searchActive = false
        }else{
            filteredConversationList = self.appModel.searchResult(searchText)
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tableView.contentOffset = CGPointMake(0.0, -self.searchBar.frame.size.height/2)
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        searchActive = true
        filteredConversationList = self.appModel.searchResult(text)
        self.tableView.reloadData()
        return true
    }
    
    
    // TODO: MUST DELETE
    func willDeleteAfterFinish(){
//        let contactList = appModel.getContactList()
//        var contactArry = [Contact]()
//        contactArry.append(contactList[1])
//        contactArry.append(contactList[3])
//        contactArry.append(contactList[2])
//        contactArry.append(contactList[4])
//        contactArry.append(contactList[5])
//        contactArry.append(contactList[6])
//        contactArry.append(contactList[7])
//        contactArry.append(contactList[8])
//        contactArry.append(contactList[9])
//        contactArry.append(contactList[10])
//        contactArry.append(contactList[11])
//        contactArry.append(contactList[12])
//        let success = self.appModel.createNewConversation(contactArry)
//        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let context = appDelegate.managedObjectContext
            for a in 0...30{
                if let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as? Contact {
                    contact.firstName = "kkkk \(a)"
                    contact.lastName = "hello"
                    contact.imagePath = "pic.png"
                    let dateFormater = NSDateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd"
                    let date = dateFormater.stringFromDate(NSDate())
                    let rand = Int(arc4random_uniform(9999))
                    contact.userId = "kkkk\(a)_\(date)_\(rand)"
                    // Try to save
                    do {
                        try context.save()
                    }
                    catch {
                        
                    }
                }
            }
        }
        
//        let contactList = appModel.getContactList()
//        for a in 0...30{
//                       var contactArry = [Contact]()
//            contactArry.append(contactList[a])
//contactArry.append(contactList[3])
//            contactArry.append(contactList[2])
//            let success = self.appModel.createNewConversation(contactArry)
//        }
        
//        if let msg = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedContext) as? Message {
//            msg.content = "whatever"
//            msg.sentDate = NSDate()
//            msg.conversation = conversation
//            var msgArray = [Message]()
//            msgArray.append(msg)
//            conversation.messages = NSSet(array: msgArray)
//        }

    }


}

