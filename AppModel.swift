//
//  AppModel.swift
//  Project342
//
//  Created by Fagan Ooi on 18/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData

class AppModel:NSManagedObjectModel{
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    // MARK: -Conversation
    /**
     Get a list of conversation for display in 'Recently Contact' tab
     */
    func getConversationList()->[Conversation]{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                return getConversationList
            }
        }catch{}
        return []
    }
    
    /**
     Create new conversation
     Return true: success
     Return false: fail
     */
    func createNewConversation(members:[Contact])->Bool{
        if let conversation = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: managedContext)as? Conversation{
            
            /**
             Update the conservation list of each user before add them into a new conversation
             */
            for eachMember in members{
                var memberConversationList = eachMember.conversations?.allObjects as! [Conversation]
                memberConversationList.append(conversation)
                eachMember.conversations = NSSet(array: memberConversationList)
            }
            
            /**
             Add the members into conversation list
             */
            conversation.members = NSSet(array: members)
            
            do{
                try managedContext.save()
            }catch{
                return false
            }
            
        }
        return true
    }
    
    // Get name of conversation
    func getConversationName(members: [Contact])->String{
        var name: String = ""
        for eachMember in members{
            let firstName = eachMember.firstName!
            name = "\(name), \(firstName)"
        }
        
        // Remove the ',' and ' ' in the string
        name.removeAtIndex(name.startIndex)
        name.removeAtIndex(name.startIndex)

        return name
    }
    
    // Delete particular conversation
    func deleteConversation(conversation: Conversation){
        do{
            managedContext.deleteObject(conversation)
            try managedContext.save()
        }catch{}
        
    }
    
    // Delete all conversations
    func deleteAllConversations(){
        do{
            let conversationList = self.getConversationList()
            for conversation in conversationList{
                managedContext.deleteObject(conversation)
            }
            try managedContext.save()
        }catch{}
        
    }
    
    // Do predicate search
    // FIXME: temporary use the members name not group name
    func searchResult(str: String)->[Conversation]{
//        let predicate = NSPredicate(format: "(lastName CONTAIN %@) OR (firstName CONTAIN %@) OR (userID CONTAIN %@) OR (lastName CONTAIN %@) OR (firstName CONTAIN %@) OR (userID CONTAIN %@) OR (lastName CONTAIN %@) OR (firstName CONTAIN %@) OR (userID CONTAIN %@)", str, str, str, str.lowercaseString, str.lowercaseString, str.lowercaseString, str.uppercaseString, str.uppercaseString, str.uppercaseString)
//        
//        var resultArray = [Conversation]()
//        do{
//            let fecthRequest = NSFetchRequest(entityName: "Conversation")
//        }
        return []
    }
    
    
    // MARK: -Contact
    /**
     Get a list of contact
     */
    func getContactList()->[Contact]{
        
        let getContactRequest = NSFetchRequest(entityName: "Contact")
        do{
            if let getContactList = try managedContext.executeFetchRequest(getContactRequest) as? [Contact]{
                return getContactList
            }
        }catch{}
        return []
    }


}
