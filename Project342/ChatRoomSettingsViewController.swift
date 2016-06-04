//
//  ChatRoomSettingsViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData

class ChatRoomSettingsViewController: UITableViewController {
    
    @IBOutlet weak var setPasscodeCell: UITableViewCell!
    @IBOutlet weak var setCoverCodeCell: UITableViewCell!
    @IBOutlet weak var deleteChatCell: UITableViewCell!
    
    var conversation: Conversation?
    var conversationID: String?
    var managedObjectContext: NSManagedObjectContext?
    var appModel: AppModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
        
        // Fetch the conversation object
        do {
            if let conversationID = conversationID {
                let fetchRequest = NSFetchRequest(entityName: String(Conversation))
                fetchRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
                
                if let fetchedConversation = try (managedObjectContext?.executeFetchRequest(fetchRequest) as? [Conversation])?.first {
                    conversation = fetchedConversation
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
            else {
                return
        }
        
        switch (selectedCell) {
        case setPasscodeCell:
            // Prepare alert
            let alertTitle = NSLocalizedString("Set passcode", comment: "Set passcode alert title")
            let alertBody = NSLocalizedString("Setting a passcode requires you to enter the passcode every time you open this conversation", comment: "Set passcode alert body")
            
            let alert = TintedAlertViewController(title: alertTitle, message: alertBody, preferredStyle: .Alert)
            
            // Alert text field
            alert.addTextFieldWithConfigurationHandler({ (textField) in
                textField.placeholder = NSLocalizedString("Passcode", comment: "passcode")
                textField.secureTextEntry = true
            })
            
            // Cancel action 
            let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel")
            let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // Alert action
            let setTitle = NSLocalizedString("Set", comment: "set")
            let setAction = UIAlertAction(title: setTitle, style: .Default, handler: {(action) -> Void in
                guard let passcodeTextField = alert.textFields?.first else {
                    return
                }
                guard
                    let conversationID = self.conversationID,
                    let passcode = passcodeTextField.text
                    else {
                    return
                }

                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(passcode, forKey: conversationID)
            })
            
            alert.addAction(setAction)
            
            presentViewController(alert, animated: true, completion: nil)
            
        case setCoverCodeCell:
            // Prepare alert
            let alertTitle = NSLocalizedString("Set cover code", comment: "Set cover code alert title")
            let alertBody = NSLocalizedString("Set the code of covered messaged", comment: "Set cover alert body")
            
            let alert = TintedAlertViewController(title: alertTitle, message: alertBody, preferredStyle: .Alert)
            
            // Alert text field
            alert.addTextFieldWithConfigurationHandler({ (textField) in
                textField.placeholder = NSLocalizedString("Cover code", comment: "cover code")
                textField.secureTextEntry = true
            })
            
            // Cancel action
            let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel")
            let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // Alert action
            let setTitle = NSLocalizedString("Set", comment: "set")
            let setAction = UIAlertAction(title: setTitle, style: .Default, handler: {(action) -> Void in
                guard let coverCodeTextField = alert.textFields?.first else {
                    return
                }
                guard
                    let conversation = self.conversation,
                    let coverCode = coverCodeTextField.text
                    else {
                        return
                }
                
                conversation.coverCode = coverCode
                do {
                    try self.managedObjectContext?.save()
                }
                catch {
                    print(error)
                }
            })
            
            alert.addAction(setAction)
            presentViewController(alert, animated: true, completion: nil)
            
        case deleteChatCell:
            // Prepare alert
            let alertTitle = NSLocalizedString("Delete Conversation", comment: "Delete conversation alert title")
            let alertBody = NSLocalizedString("Are you sure?", comment: "Delete conversation alert body")
            
            let alert = TintedAlertViewController(title: alertTitle, message: alertBody, preferredStyle: .Alert)
        
            // Cancel action
            let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel")
            let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // Alert action
            let deleteTitle = NSLocalizedString("Delete", comment: "Delete")
            let deleteAction = UIAlertAction(title: deleteTitle, style: .Destructive, handler: {(action) -> Void in
                guard
                    let conversationID = self.conversationID,
                    let appModel = self.appModel
                    else {
                        return
                }
                
                appModel.deleteConversation(conversationID)
                self.performSegueWithIdentifier("unwindFromConversationSetting", sender: nil)
            })
            
            alert.addAction(deleteAction)
            presentViewController(alert, animated: true, completion: nil)

            
        default:
            return
        }
    }
    
}
