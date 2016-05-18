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

class RecentChatViewController: UITableViewController {
    var conversationList = [Conversation]()
    let appModel = AppModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load inital data for try
        willDeleteAfterFinish()
        
        // Add edit button to navigation bar
        self.navigationItem.leftBarButtonItem = editButtonItem()
        
        /**
         Catch the recent conservation form the cored data and assign to an arry variable
         */
        conversationList = appModel.getConversationList()
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
        return conversationList.count
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("recentContactReuseCell", forIndexPath: indexPath)
        let conversation = self.conversationList[indexPath.row]
        /** 
         NSHipster.com
         Image Resizing Techniques
         http://nshipster.com/image-resizing/
        */
        // FIXME temporay set user name
        let members = conversation.members?.allObjects as! [Contact]
        
        // FIXME get the image from Directory
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
    
    func willDeleteAfterFinish(){
        let contactList = appModel.getContactList()
        for eachContact in contactList{
            var contactArry = [Contact]()
            contactArry.append(eachContact)
            contactArry.append(contactList[3])
            let success = appModel.createNewConversation(contactArry)
            print(success)
        }
    }


}

