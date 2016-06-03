//
//  SettingsViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 03/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didLogoutButtonPressed(sender: AnyObject) {
        do {
            let fetchConversation = NSFetchRequest(entityName: String(Conversation))
            let deleteConversation = NSBatchDeleteRequest(fetchRequest: fetchConversation)
            
            let fetchAttachment = NSFetchRequest(entityName: String(Attachment))
            let deleteAttachement = NSBatchDeleteRequest(fetchRequest: fetchAttachment)
            
            let fetchMessage = NSFetchRequest(entityName: String(Message))
            let deleteMessage = NSBatchDeleteRequest(fetchRequest: fetchMessage)
            
            let fetchContact = NSFetchRequest(entityName: String(Contact))
            let deleteContact = NSBatchDeleteRequest(fetchRequest: fetchContact)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            try appDelegate.managedObjectContext.executeRequest(deleteConversation)
            try appDelegate.managedObjectContext.executeRequest(deleteAttachement)
            try appDelegate.managedObjectContext.executeRequest(deleteMessage)
            try appDelegate.managedObjectContext.executeRequest(deleteContact)
            try appDelegate.managedObjectContext.save()
            
            try FIRAuth.auth()?.signOut()
            performSegueWithIdentifier("unwindToLaunch", sender: nil)
            
        } catch {
            print(error)
        }
    }
    
}
